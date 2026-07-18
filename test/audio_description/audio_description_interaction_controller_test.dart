import 'package:flutter_test/flutter_test.dart';
import 'package:museum_app/accessibility/accessibility.dart';
import 'package:museum_app/audio_description/ai/narration_generation_result.dart';
import 'package:museum_app/audio_description/ai/narration_generator.dart';
import 'package:museum_app/audio_description/context/conversation_context_manager.dart';
import 'package:museum_app/audio_description/controller/audio_description_controller.dart';
import 'package:museum_app/audio_description/controller/audio_description_state.dart';
import 'package:museum_app/audio_description/controller/audio_description_status.dart';
import 'package:museum_app/audio_description/interaction/audio_description_interaction.dart';
import 'package:museum_app/audio_description/interaction/audio_description_interaction_controller.dart';
import 'package:museum_app/audio_description/models/audio_description_enums.dart';
import 'package:museum_app/audio_description/models/exhibit_id.dart';
import 'package:museum_app/audio_description/models/exhibit_metadata.dart';
import 'package:museum_app/audio_description/models/narration_policy.dart';
import 'package:museum_app/audio_description/prompt/narration_prompt.dart';
import 'package:museum_app/audio_description/prompt/narration_prompt_builder.dart';
import 'package:museum_app/audio_description/repository/exhibit_lookup_result.dart';
import 'package:museum_app/voice/voice.dart';

/// Phase 4 Task 8 — AudioDescriptionInteractionController orchestration tests.
///
/// The interaction layer is a pure router over EXISTING components. Every
/// collaborator here is a fake or the real (pure) component; no AI, network,
/// Firebase, or TTS plugin is touched. The tests assert each interaction is
/// delegated to the right component and folded into the right
/// [AudioDescriptionInteractionResult] / status, and that failures propagate
/// without throwing.
void main() {
  final exhibit = ExhibitId('rosetta-stone');
  final metadata = ExhibitMetadata(
    id: exhibit,
    title: 'Rosetta Stone',
    physicalDescription: 'A tall dark granodiorite slab.',
    historicalContext: 'Issued in 196 BC.',
  );

  const policy = NarrationPolicy(
    length: NarrationLength.standard,
    layers: {StoryLayer.visual, StoryLayer.historical},
    useSimpleLanguage: false,
    educationalDepth: EducationalDepth.casual,
    childMode: false,
    researchMode: false,
    emphasizePhysicalDescription: false,
    inviteFollowUp: true,
  );

  // A test harness that wires the real Task 7 controller + real context manager
  // to fakes, exactly as production would wire real components.
  _Harness harness({
    ExhibitLookupResult? lookup,
    NarrationGenerationResult? generation,
    bool voiceAccepts = true,
    bool seedContext = true,
  }) {
    final repo = _FakeRepository(lookup ?? ExhibitLookupResult.found(metadata));
    final gen = _FakeGenerator(
        generation ?? NarrationGenerationResult.success('a telling'));
    final voice = _FakeVoice(accept: voiceAccepts);
    final context = ConversationContextManager();
    final narration = AudioDescriptionController(
      repository: repo,
      policyResolver: () => policy,
      promptBuilder: const NarrationPromptBuilder(),
      generator: gen,
      context: context,
      voice: voice,
      profile: AccessibilityProfile.initial,
    );

    // Seed an active exhibit into context the way a completed narration would.
    if (seedContext) {
      context.onNarrationComplete(
        metadata: metadata,
        narration: 'the original telling',
        policy: policy,
      );
    }

    final detail = _FakeDetail();
    final followUp = _FakeFollowUp();
    final bookmark = _FakeBookmark();

    final controller = AudioDescriptionInteractionController(
      narrationController: narration,
      context: context,
      voice: voice,
      detail: detail,
      followUp: followUp.respond,
      onBookmark: bookmark.save,
    );

    return _Harness(
      controller: controller,
      repo: repo,
      gen: gen,
      voice: voice,
      context: context,
      detail: detail,
      followUp: followUp,
      bookmark: bookmark,
    );
  }

  group('repeat', () {
    test('re-runs the narration pipeline and reports narrationUpdated',
        () async {
      final h = harness();

      final result =
          await h.controller.handle(AudioDescriptionInteraction.repeat);

      expect(result.status,
          AudioDescriptionInteractionStatus.narrationUpdated);
      expect(result.exhibitId, exhibit);
      expect(result.state?.status, AudioDescriptionStatus.completed);
      expect(h.gen.calls, 1);
      expect(h.voice.spoken, ['a telling']);
      // Repeat must not change the requested length.
      expect(h.detail.log, isEmpty);
    });
  });

  group('tell me more', () {
    test('maximizes detail then re-narrates', () async {
      final h = harness();

      final result =
          await h.controller.handle(AudioDescriptionInteraction.tellMeMore);

      expect(result.status,
          AudioDescriptionInteractionStatus.narrationUpdated);
      expect(h.detail.log, ['maximize']);
      expect(h.gen.calls, 1);
    });
  });

  group('increase / decrease detail', () {
    test('increase steps detail up through the policy flow, then re-narrates',
        () async {
      final h = harness();

      final result = await h.controller
          .handle(AudioDescriptionInteraction.increaseDetail);

      expect(result.status,
          AudioDescriptionInteractionStatus.narrationUpdated);
      expect(h.detail.log, ['increase']);
      expect(h.gen.calls, 1);
    });

    test('decrease steps detail down through the policy flow, then re-narrates',
        () async {
      final h = harness();

      final result = await h.controller
          .handle(AudioDescriptionInteraction.decreaseDetail);

      expect(result.status,
          AudioDescriptionInteractionStatus.narrationUpdated);
      expect(h.detail.log, ['decrease']);
      expect(h.gen.calls, 1);
    });
  });

  group('follow-up question', () {
    test('enriches via context, forwards to the AI path, returns the answer',
        () async {
      final h = harness();
      h.followUp.answer = 'Because it unlocked hieroglyphs.';

      final result = await h.controller.handle(
        AudioDescriptionInteraction.askFollowUp,
        question: 'Why is it important?',
      );

      expect(result.status, AudioDescriptionInteractionStatus.answered);
      expect(result.answer, 'Because it unlocked hieroglyphs.');
      // The prompt forwarded to the AI path was exhibit-grounded (enriched),
      // proving ConversationContextManager did the grounding, not this layer.
      expect(h.followUp.lastPrompt, contains('Rosetta Stone'));
      expect(h.followUp.lastPrompt, contains('Why is it important?'));
      // The question was remembered in context.
      expect(h.context.current.recentFollowUps, contains('Why is it important?'));
      // No narration pipeline run for a follow-up.
      expect(h.gen.calls, 0);
    });

    test('empty question → failed without calling the AI path', () async {
      final h = harness();

      final result = await h.controller.handle(
        AudioDescriptionInteraction.askFollowUp,
        question: '   ',
      );

      expect(result.status, AudioDescriptionInteractionStatus.failed);
      expect(h.followUp.calls, 0);
    });

    test('AI path throwing → failed with diagnostics, never rethrows', () async {
      final h = harness();
      h.followUp.error = StateError('chat backend down');

      final result = await h.controller.handle(
        AudioDescriptionInteraction.askFollowUp,
        question: 'Tell me about it',
      );

      expect(result.status, AudioDescriptionInteractionStatus.failed);
      expect(result.diagnostics, contains('chat backend down'));
    });
  });

  group('skip exhibit', () {
    test('cancels the run, stops the voice, returns skipped', () async {
      final h = harness();

      final result =
          await h.controller.handle(AudioDescriptionInteraction.skip);

      expect(result.status, AudioDescriptionInteractionStatus.skipped);
      expect(result.exhibitId, exhibit);
      expect(h.voice.stopCalls, 1);
    });

    test('stop failure propagates as failed', () async {
      final h = harness();
      h.voice.throwOnStop = StateError('tts stuck');

      final result =
          await h.controller.handle(AudioDescriptionInteraction.skip);

      expect(result.status, AudioDescriptionInteractionStatus.failed);
      expect(result.diagnostics, contains('tts stuck'));
    });
  });

  group('bookmark', () {
    test('invokes the injected callback only (no persistence here)', () async {
      final h = harness();

      final result =
          await h.controller.handle(AudioDescriptionInteraction.bookmark);

      expect(result.status, AudioDescriptionInteractionStatus.bookmarked);
      expect(result.exhibitId, exhibit);
      expect(h.bookmark.saved, [exhibit]);
      expect(h.bookmark.savedMetadata.single?.title, 'Rosetta Stone');
    });

    test('bookmark handler throwing → failed with diagnostics', () async {
      final h = harness();
      h.bookmark.error = StateError('disk full');

      final result =
          await h.controller.handle(AudioDescriptionInteraction.bookmark);

      expect(result.status, AudioDescriptionInteractionStatus.failed);
      expect(result.diagnostics, contains('disk full'));
    });
  });

  group('no active exhibit', () {
    test('interactions with no exhibit in context report noActiveExhibit',
        () async {
      final h = harness(seedContext: false);

      for (final interaction in [
        AudioDescriptionInteraction.repeat,
        AudioDescriptionInteraction.tellMeMore,
        AudioDescriptionInteraction.bookmark,
        AudioDescriptionInteraction.skip,
      ]) {
        final result = await h.controller.handle(interaction);
        expect(result.status, AudioDescriptionInteractionStatus.noActiveExhibit,
            reason: 'for $interaction');
      }

      final followUp = await h.controller.handle(
        AudioDescriptionInteraction.askFollowUp,
        question: 'anything?',
      );
      expect(followUp.status,
          AudioDescriptionInteractionStatus.noActiveExhibit);
    });
  });

  group('controller failure propagation', () {
    test('a re-narration whose pipeline fails resolves to failed with state',
        () async {
      final h = harness(
        generation: NarrationGenerationResult.failure(
          NarrationGenerationStatus.aiFailure,
          diagnostics: 'model 500',
        ),
      );

      final result =
          await h.controller.handle(AudioDescriptionInteraction.repeat);

      expect(result.status, AudioDescriptionInteractionStatus.failed);
      expect(result.state?.status, AudioDescriptionStatus.failed);
      expect(result.state?.failureStage,
          AudioDescriptionFailureStage.generation);
      expect(result.diagnostics, contains('model 500'));
    });
  });

  group('command mapping (consumes parser output, does not re-parse)', () {
    test('repeat_explanation intent maps to repeat', () async {
      final h = harness();

      final result = await h.controller.handleCommand(const VoiceCommand(
        intent: VoiceCommandIntent.repeatExplanation,
      ));

      expect(result.interaction, AudioDescriptionInteraction.repeat);
      expect(result.status,
          AudioDescriptionInteractionStatus.narrationUpdated);
    });

    test('next_exhibit intent maps to skip', () async {
      final h = harness();

      final result = await h.controller.handleCommand(const VoiceCommand(
        intent: VoiceCommandIntent.nextExhibit,
      ));

      expect(result.interaction, AudioDescriptionInteraction.skip);
      expect(result.status, AudioDescriptionInteractionStatus.skipped);
    });

    test('an unrelated voice intent is unsupported', () async {
      final h = harness();

      final result = await h.controller.handleCommand(const VoiceCommand(
        intent: VoiceCommandIntent.increaseVolume,
      ));

      expect(result.status, AudioDescriptionInteractionStatus.unsupported);
      // Nothing was orchestrated.
      expect(h.gen.calls, 0);
      expect(h.voice.stopCalls, 0);
      expect(h.followUp.calls, 0);
    });
  });

  group('interaction result status', () {
    test('isSuccess covers the four successful outcomes only', () {
      expect(AudioDescriptionInteractionStatus.narrationUpdated.isSuccess,
          isTrue);
      expect(AudioDescriptionInteractionStatus.answered.isSuccess, isTrue);
      expect(AudioDescriptionInteractionStatus.bookmarked.isSuccess, isTrue);
      expect(AudioDescriptionInteractionStatus.skipped.isSuccess, isTrue);
      expect(AudioDescriptionInteractionStatus.failed.isSuccess, isFalse);
      expect(AudioDescriptionInteractionStatus.unsupported.isSuccess, isFalse);
      expect(AudioDescriptionInteractionStatus.noActiveExhibit.isSuccess,
          isFalse);
    });

    test('result exposes isSuccess / isFailure consistently', () async {
      final h = harness();
      final ok =
          await h.controller.handle(AudioDescriptionInteraction.bookmark);
      expect(ok.isSuccess, isTrue);
      expect(ok.isFailure, isFalse);

      h.bookmark.error = StateError('x');
      final bad =
          await h.controller.handle(AudioDescriptionInteraction.bookmark);
      expect(bad.isSuccess, isFalse);
      expect(bad.isFailure, isTrue);
    });
  });
}

// ---------------------------------------------------------------------------
// Harness + fakes
// ---------------------------------------------------------------------------

class _Harness {
  _Harness({
    required this.controller,
    required this.repo,
    required this.gen,
    required this.voice,
    required this.context,
    required this.detail,
    required this.followUp,
    required this.bookmark,
  });

  final AudioDescriptionInteractionController controller;
  final _FakeRepository repo;
  final _FakeGenerator gen;
  final _FakeVoice voice;
  final ConversationContextManager context;
  final _FakeDetail detail;
  final _FakeFollowUp followUp;
  final _FakeBookmark bookmark;
}

class _FakeRepository implements ExhibitRepository {
  _FakeRepository(this._result);
  final ExhibitLookupResult _result;

  @override
  Future<ExhibitLookupResult> getExhibit(ExhibitId id) async => _result;
}

class _FakeGenerator implements NarrationGenerator {
  _FakeGenerator(this._result);
  final NarrationGenerationResult _result;
  int calls = 0;

  @override
  Future<NarrationGenerationResult> generate(NarrationPrompt prompt) async {
    calls++;
    return _result;
  }
}

class _FakeVoice implements NarrationVoiceOutput {
  _FakeVoice({bool accept = true}) : _accept = accept;
  final bool _accept;

  final List<String> spoken = [];
  int stopCalls = 0;
  Object? throwOnStop;

  @override
  Future<bool> speakNarration(String narration, {required String language}) async {
    spoken.add(narration);
    return _accept;
  }

  @override
  Future<void> stopNarration() async {
    stopCalls++;
    final err = throwOnStop;
    if (err != null) throw err;
  }
}

/// Fake length preference: records which step was requested and moves a cursor
/// over [NarrationLength], standing in for the real NarrationPreferences flow.
class _FakeDetail implements NarrationDetailPreference {
  NarrationLength _current = NarrationLength.standard;
  final List<String> log = [];

  @override
  NarrationLength get current => _current;

  @override
  NarrationLength increase() {
    log.add('increase');
    if (_current == NarrationLength.short) {
      _current = NarrationLength.standard;
    } else {
      _current = NarrationLength.detailed;
    }
    return _current;
  }

  @override
  NarrationLength decrease() {
    log.add('decrease');
    if (_current == NarrationLength.detailed) {
      _current = NarrationLength.standard;
    } else {
      _current = NarrationLength.short;
    }
    return _current;
  }

  @override
  NarrationLength maximize() {
    log.add('maximize');
    _current = NarrationLength.detailed;
    return _current;
  }
}

class _FakeFollowUp {
  String answer = 'a fine answer';
  Object? error;
  int calls = 0;
  String? lastPrompt;

  Future<String> respond(String enrichedPrompt) async {
    calls++;
    lastPrompt = enrichedPrompt;
    final err = error;
    if (err != null) throw err;
    return answer;
  }
}

class _FakeBookmark {
  Object? error;
  final List<ExhibitId> saved = [];
  final List<ExhibitMetadata?> savedMetadata = [];

  Future<void> save(ExhibitId id, ExhibitMetadata? metadata) async {
    final err = error;
    if (err != null) throw err;
    saved.add(id);
    savedMetadata.add(metadata);
  }
}
