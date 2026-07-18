import '../context/conversation_context_manager.dart';
import '../controller/audio_description_controller.dart';
import '../controller/audio_description_state.dart';
import '../models/audio_description_enums.dart';
import '../models/exhibit_id.dart';
import '../models/exhibit_metadata.dart';
import 'audio_description_interaction.dart';
import 'audio_description_interaction_result.dart';

// Note: this file imports `package:museum_app/voice/...` types only through the
// already-narrow seams above; the one voice concept it needs (mapping a parsed
// command intent) is passed in as a value, so no voice-stack wiring leaks here.
import 'package:museum_app/voice/voice.dart';

/// Forwards an exhibit-grounded follow-up prompt to the app's EXISTING AI/chat
/// path and resolves to the answer text. Injected as a seam so this layer adds
/// no second AI client and implements no AI itself. Throwing signals an AI-path
/// failure the controller turns into a structured failed result.
typedef NarrationFollowUpResponder = Future<String> Function(
    String enrichedPrompt);

/// Persists a bookmark for an exhibit. Task 8 exposes this as a callback ONLY —
/// no storage is implemented here; a later task supplies the real handler.
typedef ExhibitBookmarkHandler = Future<void> Function(
    ExhibitId exhibitId, ExhibitMetadata? metadata);

/// The seam to the EXISTING narration-length / policy flow. It is implemented by
/// whatever owns [NarrationPreferences] + `NarrationProfileMapper`; this
/// interaction layer only asks it to step the desired length and NEVER computes
/// a policy, clamps a length, or edits a prompt itself — that keeps all policy
/// logic in Task 2's tested mapper. Each method returns the resulting length so
/// the caller can react, but the decision lives behind this abstraction.
abstract class NarrationDetailPreference {
  /// The current effective narration length.
  NarrationLength get current;

  /// Step one level toward more detail (clamped by the implementation).
  NarrationLength increase();

  /// Step one level toward less detail (clamped by the implementation).
  NarrationLength decrease();

  /// Jump to the fullest telling — used by "tell me more".
  NarrationLength maximize();
}

/// Orchestrates in-narration visitor interactions (repeat, tell-me-more, ask a
/// follow-up, skip, bookmark, increase/decrease detail).
///
/// It is ONLY a router: every capability is delegated to an existing component —
/// re-narration to [AudioDescriptionController], conversational grounding to
/// [ConversationContextManager], stopping audio to the [NarrationVoiceOutput]
/// seam, the AI answer to an injected [NarrationFollowUpResponder], length to the
/// injected [NarrationDetailPreference] flow, and persistence to an injected
/// [ExhibitBookmarkHandler]. This layer parses no utterances (it consumes the
/// already-parsed `VoiceCommand`), builds no prompts, calls no AI, computes no
/// policy, and touches no storage. It never throws — every path resolves to an
/// [AudioDescriptionInteractionResult].
class AudioDescriptionInteractionController {
  AudioDescriptionInteractionController({
    required AudioDescriptionController narrationController,
    required ConversationContextManager context,
    required NarrationVoiceOutput voice,
    required NarrationDetailPreference detail,
    required NarrationFollowUpResponder followUp,
    required ExhibitBookmarkHandler onBookmark,
  })  : _narration = narrationController,
        _context = context,
        _voice = voice,
        _detail = detail,
        _followUp = followUp,
        _onBookmark = onBookmark;

  final AudioDescriptionController _narration;
  final ConversationContextManager _context;
  final NarrationVoiceOutput _voice;
  final NarrationDetailPreference _detail;
  final NarrationFollowUpResponder _followUp;
  final ExhibitBookmarkHandler _onBookmark;

  /// Map an already-parsed voice command to a storytelling interaction and
  /// handle it. Consumes `VoiceCommandParser` output — it does not re-parse.
  /// Recognized commands with no storytelling meaning resolve to
  /// [AudioDescriptionInteractionStatus.unsupported].
  Future<AudioDescriptionInteractionResult> handleCommand(
    VoiceCommand command, {
    String? question,
  }) {
    final interaction = _mapIntent(command.intent);
    if (interaction == null) {
      return Future.value(const AudioDescriptionInteractionResult(
        interaction: AudioDescriptionInteraction.repeat,
        status: AudioDescriptionInteractionStatus.unsupported,
      ));
    }
    return handle(interaction, question: question);
  }

  /// Handle a directly-chosen interaction (e.g. a UI button). Never throws.
  Future<AudioDescriptionInteractionResult> handle(
    AudioDescriptionInteraction interaction, {
    String? question,
  }) async {
    switch (interaction) {
      case AudioDescriptionInteraction.repeat:
      case AudioDescriptionInteraction.tellMeMore:
      case AudioDescriptionInteraction.increaseDetail:
      case AudioDescriptionInteraction.decreaseDetail:
        return _reNarrate(interaction);
      case AudioDescriptionInteraction.askFollowUp:
        return _askFollowUp(question);
      case AudioDescriptionInteraction.skip:
        return _skip();
      case AudioDescriptionInteraction.bookmark:
        return _bookmark();
    }
  }

  // ---------------------------------------------------------------------------
  // Re-narration: repeat / tell-me-more / increase / decrease detail.
  // ---------------------------------------------------------------------------
  Future<AudioDescriptionInteractionResult> _reNarrate(
    AudioDescriptionInteraction interaction,
  ) async {
    final exhibitId = _currentExhibit();
    if (exhibitId == null) {
      return AudioDescriptionInteractionResult(
        interaction: interaction,
        status: AudioDescriptionInteractionStatus.noActiveExhibit,
      );
    }

    // Adjust the desired length through the existing policy flow (never here).
    switch (interaction) {
      case AudioDescriptionInteraction.tellMeMore:
        _detail.maximize();
        break;
      case AudioDescriptionInteraction.increaseDetail:
        _detail.increase();
        break;
      case AudioDescriptionInteraction.decreaseDetail:
        _detail.decrease();
        break;
      case AudioDescriptionInteraction.repeat:
      case AudioDescriptionInteraction.askFollowUp:
      case AudioDescriptionInteraction.skip:
      case AudioDescriptionInteraction.bookmark:
        break; // repeat keeps the current length; the rest never reach here.
    }

    // Re-run the existing pipeline. The controller re-reads policy via its
    // injected resolver, so the length change takes effect without us touching
    // prompts or policy.
    final state = await _narration.describe(exhibitId);

    if (state.isCompleted) {
      return AudioDescriptionInteractionResult(
        interaction: interaction,
        status: AudioDescriptionInteractionStatus.narrationUpdated,
        exhibitId: exhibitId,
        state: state,
      );
    }
    return AudioDescriptionInteractionResult(
      interaction: interaction,
      status: AudioDescriptionInteractionStatus.failed,
      exhibitId: exhibitId,
      state: state,
      diagnostics:
          'Re-narration ended in ${state.status.storageKey}'
          '${state.diagnostics != null ? ': ${state.diagnostics}' : ''}',
    );
  }

  // ---------------------------------------------------------------------------
  // Ask a follow-up question through the existing AI path.
  // ---------------------------------------------------------------------------
  Future<AudioDescriptionInteractionResult> _askFollowUp(
      String? question) async {
    const interaction = AudioDescriptionInteraction.askFollowUp;
    if (!_context.current.hasExhibit) {
      return const AudioDescriptionInteractionResult(
        interaction: interaction,
        status: AudioDescriptionInteractionStatus.noActiveExhibit,
      );
    }
    final q = question?.trim() ?? '';
    if (q.isEmpty) {
      return AudioDescriptionInteractionResult(
        interaction: interaction,
        status: AudioDescriptionInteractionStatus.failed,
        exhibitId: _context.current.exhibitId,
        diagnostics: 'Empty follow-up question',
      );
    }

    // Ground the bare question in the current exhibit + prior questions, and
    // remember it — both owned by ConversationContextManager.
    final enriched = _context.enrichFollowUp(q, remember: true);

    try {
      final answer = await _followUp(enriched);
      final trimmed = answer.trim();
      if (trimmed.isEmpty) {
        return AudioDescriptionInteractionResult(
          interaction: interaction,
          status: AudioDescriptionInteractionStatus.failed,
          exhibitId: _context.current.exhibitId,
          diagnostics: 'AI path returned an empty answer',
        );
      }
      return AudioDescriptionInteractionResult(
        interaction: interaction,
        status: AudioDescriptionInteractionStatus.answered,
        exhibitId: _context.current.exhibitId,
        answer: trimmed,
      );
    } catch (e) {
      return AudioDescriptionInteractionResult(
        interaction: interaction,
        status: AudioDescriptionInteractionStatus.failed,
        exhibitId: _context.current.exhibitId,
        diagnostics: 'Follow-up AI path threw: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Skip: stop the audio and hand control back for the tour to advance.
  // ---------------------------------------------------------------------------
  Future<AudioDescriptionInteractionResult> _skip() async {
    final exhibitId = _currentExhibit();
    if (exhibitId == null) {
      return const AudioDescriptionInteractionResult(
        interaction: AudioDescriptionInteraction.skip,
        status: AudioDescriptionInteractionStatus.noActiveExhibit,
      );
    }

    // Supersede any in-flight run, then guarantee silence via the voice seam.
    _narration.cancel();
    try {
      await _voice.stopNarration();
    } catch (e) {
      return AudioDescriptionInteractionResult(
        interaction: AudioDescriptionInteraction.skip,
        status: AudioDescriptionInteractionStatus.failed,
        exhibitId: exhibitId,
        diagnostics: 'Stopping narration failed: $e',
      );
    }
    return AudioDescriptionInteractionResult(
      interaction: AudioDescriptionInteraction.skip,
      status: AudioDescriptionInteractionStatus.skipped,
      exhibitId: exhibitId,
    );
  }

  // ---------------------------------------------------------------------------
  // Bookmark: fire the injected callback only (no persistence here).
  // ---------------------------------------------------------------------------
  Future<AudioDescriptionInteractionResult> _bookmark() async {
    final ctx = _context.current;
    if (!ctx.hasExhibit || ctx.exhibitId == null) {
      return const AudioDescriptionInteractionResult(
        interaction: AudioDescriptionInteraction.bookmark,
        status: AudioDescriptionInteractionStatus.noActiveExhibit,
      );
    }
    try {
      await _onBookmark(ctx.exhibitId!, ctx.metadata);
      return AudioDescriptionInteractionResult(
        interaction: AudioDescriptionInteraction.bookmark,
        status: AudioDescriptionInteractionStatus.bookmarked,
        exhibitId: ctx.exhibitId,
      );
    } catch (e) {
      return AudioDescriptionInteractionResult(
        interaction: AudioDescriptionInteraction.bookmark,
        status: AudioDescriptionInteractionStatus.failed,
        exhibitId: ctx.exhibitId,
        diagnostics: 'Bookmark handler threw: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  /// The exhibit currently in play: the one in conversation context if a
  /// narration has landed, otherwise the one the controller is mid-run on.
  ExhibitId? _currentExhibit() =>
      _context.current.exhibitId ?? _narration.state.exhibitId;

  /// Map a parsed voice intent onto a storytelling interaction, or null when the
  /// command has no audio-description meaning. Only the intents that genuinely
  /// correspond are mapped; this does not re-implement the parser.
  AudioDescriptionInteraction? _mapIntent(VoiceCommandIntent intent) {
    switch (intent) {
      case VoiceCommandIntent.repeatExplanation:
        return AudioDescriptionInteraction.repeat;
      case VoiceCommandIntent.nextExhibit:
        return AudioDescriptionInteraction.skip;
      case VoiceCommandIntent.startTour:
      case VoiceCommandIntent.pauseTour:
      case VoiceCommandIntent.resumeTour:
      case VoiceCommandIntent.previousExhibit:
      case VoiceCommandIntent.stopSpeaking:
      case VoiceCommandIntent.callAssistance:
      case VoiceCommandIntent.increaseVolume:
      case VoiceCommandIntent.decreaseVolume:
      case VoiceCommandIntent.fasterSpeech:
      case VoiceCommandIntent.slowerSpeech:
      case VoiceCommandIntent.unknown:
        return null;
    }
  }
}
