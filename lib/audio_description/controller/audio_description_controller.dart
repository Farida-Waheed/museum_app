import 'dart:async';

import 'package:museum_app/accessibility/accessibility.dart';

import '../ai/narration_generator.dart';
import '../context/conversation_context_manager.dart';
import '../models/exhibit_id.dart';
import '../models/narration_policy.dart';
import '../prompt/narration_prompt_builder.dart';
import '../repository/exhibit_lookup_result.dart';
import 'audio_description_state.dart';
import 'audio_description_status.dart';

/// Resolves the active [NarrationPolicy] for a run. Injected (not built here) so
/// the controller never inspects the AccessibilityProfile or re-derives policy
/// logic — that lives in Task 2's mapper, which a caller wires into this.
typedef NarrationPolicyResolver = NarrationPolicy Function();

/// Orchestrates the end-to-end narration pipeline for one exhibit:
///
///   ExhibitId → ExhibitRepository → NarrationPolicy → NarrationPromptBuilder
///            → AiNarrationGenerator → ConversationContext → Voice
///
/// It is ONLY a coordinator: it holds no repository/cache logic, builds no
/// prompts, makes no AI calls, and derives no policy itself — every collaborator
/// is injected and does its own job. The controller's sole responsibilities are
/// sequencing those calls, publishing [AudioDescriptionState] transitions, and
/// classifying failures into a structured [AudioDescriptionStatus.failed] (it
/// never fabricates fallback narration — that is Task 13).
class AudioDescriptionController {
  AudioDescriptionController({
    required ExhibitRepository repository,
    required NarrationPolicyResolver policyResolver,
    required NarrationPromptBuilder promptBuilder,
    required NarrationGenerator generator,
    required ConversationContextManager context,
    required NarrationVoiceOutput voice,
    required AccessibilityProfile profile,
    String language = 'en',
  })  : _repository = repository,
        _policyResolver = policyResolver,
        _promptBuilder = promptBuilder,
        _generator = generator,
        _context = context,
        _voice = voice,
        _profile = profile,
        _language = language;

  final ExhibitRepository _repository;
  final NarrationPolicyResolver _policyResolver;
  final NarrationPromptBuilder _promptBuilder;
  final NarrationGenerator _generator;
  final ConversationContextManager _context;
  final NarrationVoiceOutput _voice;

  /// The AccessibilityProfile is passed straight THROUGH to the prompt builder
  /// (which owns how it is rendered). The controller never reads a field on it —
  /// carrying a dependency is not the same as inspecting it.
  final AccessibilityProfile _profile;

  String _language;

  AudioDescriptionState _state = AudioDescriptionState.initial;
  AudioDescriptionState get state => _state;

  /// Incremented per run so a superseded/cancelled run cannot publish state
  /// after a newer run has started.
  int _runToken = 0;

  /// Published on every state change.
  void Function(AudioDescriptionState state)? onStateChanged;

  void setLanguage(String language) {
    _language = language;
    _context.setLanguage(language);
  }

  /// Cancel the in-flight run (visitor skipped / moved on). The current run
  /// observes the token change at its next checkpoint and stops publishing.
  ///
  /// If narration is actively playing, the active audio is stopped through the
  /// voice seam so Horus falls silent immediately rather than talking over the
  /// cancelled state. The stop is dispatched without blocking the state flip;
  /// [NarrationVoiceOutput.stopNarration] is contractually a no-op when nothing
  /// is speaking, so calling it is always safe.
  void cancel() {
    if (_state.status.isTerminal || _state.status == AudioDescriptionStatus.idle) {
      return;
    }
    final wasSpeaking = _state.status == AudioDescriptionStatus.speaking;
    _runToken++;
    _publish(_state.copyWith(status: AudioDescriptionStatus.cancelled));
    if (wasSpeaking) {
      // Fire-and-forget: the cancelled state has already been published; failure
      // to stop must not throw out of a synchronous cancel().
      unawaited(_stopVoiceQuietly());
    }
  }

  Future<void> _stopVoiceQuietly() async {
    try {
      await _voice.stopNarration();
    } catch (_) {
      // A stop failure has no recovery here — the run is already cancelled.
    }
  }

  /// Run the full pipeline for [exhibitId]. Never throws — every outcome is a
  /// published [AudioDescriptionState].
  Future<AudioDescriptionState> describe(ExhibitId exhibitId) async {
    final token = ++_runToken;

    // 1. Retrieve metadata (repository owns cache/source logic).
    _publish(AudioDescriptionState(
      status: AudioDescriptionStatus.loading,
      exhibitId: exhibitId,
      language: _language,
    ));

    final lookup = await _repository.getExhibit(exhibitId);
    if (_superseded(token)) return _state;

    if (!lookup.isFound) {
      final stage = lookup.status == ExhibitLookupStatus.notFound
          ? AudioDescriptionFailureStage.invalidExhibit
          : AudioDescriptionFailureStage.repository;
      return _fail(exhibitId, stage,
          'Exhibit lookup: ${lookup.status.storageKey}');
    }
    final metadata = lookup.metadata!;

    // 2 + 3. Resolve policy (injected) and build the prompt (builder owns it).
    final policy = _policyResolver();
    final prompt = _promptBuilder.build(
      metadata: metadata,
      policy: policy,
      profile: _profile,
      language: _language,
    );

    // 4. Generate narration through the AI generator (never throws).
    _publish(_state.copyWith(status: AudioDescriptionStatus.generating));
    final generation = await _generator.generate(prompt);
    if (_superseded(token)) return _state;

    if (!generation.isSuccess) {
      return _fail(exhibitId, AudioDescriptionFailureStage.generation,
          generation.diagnostics ?? generation.status.storageKey);
    }
    final narration = generation.narration!;

    // 5. Update conversational context with the completed narration.
    _context.onNarrationComplete(
      metadata: metadata,
      narration: narration,
      policy: policy,
      language: _language,
    );

    // 6. Hand off to the voice engine.
    _publish(_state.copyWith(
      status: AudioDescriptionStatus.speaking,
      narration: narration,
    ));

    bool accepted;
    try {
      accepted = await _voice.speakNarration(narration, language: _language);
    } catch (e) {
      if (_superseded(token)) return _state;
      return _fail(exhibitId, AudioDescriptionFailureStage.voice,
          'Voice output threw: $e');
    }
    if (_superseded(token)) return _state;

    if (!accepted) {
      return _fail(exhibitId, AudioDescriptionFailureStage.voice,
          'Voice engine rejected the narration');
    }

    // 7. Done.
    _publish(_state.copyWith(status: AudioDescriptionStatus.completed));
    return _state;
  }

  // ---------------------------------------------------------------------------
  bool _superseded(int token) => token != _runToken;

  AudioDescriptionState _fail(
    ExhibitId exhibitId,
    AudioDescriptionFailureStage stage,
    String diagnostics,
  ) {
    final failed = AudioDescriptionState(
      status: AudioDescriptionStatus.failed,
      exhibitId: exhibitId,
      language: _language,
      failureStage: stage,
      diagnostics: diagnostics,
    );
    _publish(failed);
    return failed;
  }

  void _publish(AudioDescriptionState next) {
    _state = next;
    onStateChanged?.call(next);
  }
}
