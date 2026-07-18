import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:museum_app/accessibility/accessibility.dart';
import 'package:museum_app/audio_description/ai/narration_generation_result.dart';
import 'package:museum_app/audio_description/ai/narration_generator.dart';
import 'package:museum_app/audio_description/context/conversation_context_manager.dart';
import 'package:museum_app/audio_description/controller/audio_description_controller.dart';
import 'package:museum_app/audio_description/controller/audio_description_state.dart';
import 'package:museum_app/audio_description/controller/audio_description_status.dart';
import 'package:museum_app/audio_description/models/audio_description_enums.dart';
import 'package:museum_app/audio_description/models/exhibit_id.dart';
import 'package:museum_app/audio_description/models/exhibit_metadata.dart';
import 'package:museum_app/audio_description/models/narration_policy.dart';
import 'package:museum_app/audio_description/prompt/narration_prompt.dart';
import 'package:museum_app/audio_description/prompt/narration_prompt_builder.dart';
import 'package:museum_app/audio_description/repository/exhibit_lookup_result.dart';

/// Phase 4 Task 7 — AudioDescriptionController orchestration tests.
///
/// The controller is ONLY a coordinator: repository → policy → prompt →
/// generator → context → voice. Every collaborator is a FAKE injected here; no
/// AI, network, Firebase, or TTS plugin is ever touched. The tests assert the
/// controller sequences the pipeline correctly, publishes the right
/// [AudioDescriptionState] transitions, classifies each failure to the right
/// [AudioDescriptionFailureStage], honours cancellation/supersession, and never
/// fabricates narration or throws.
void main() {
  final exhibit = ExhibitId('rosetta-stone');
  final metadata = ExhibitMetadata(
    id: exhibit,
    title: 'Rosetta Stone',
    location: 'Hall of Writing',
    physicalDescription: 'A tall dark granodiorite slab covered in three scripts.',
    historicalContext: 'Issued in 196 BC during the reign of Ptolemy V.',
    period: 'Ptolemaic Period',
    interestingFacts: ['It unlocked the reading of hieroglyphs.'],
  );

  // A concrete, valid policy stands in for the real mapper's output — the
  // controller only passes it through to the (real) prompt builder.
  const policy = NarrationPolicy(
    length: NarrationLength.standard,
    layers: {StoryLayer.visual, StoryLayer.historical, StoryLayer.story},
    useSimpleLanguage: false,
    educationalDepth: EducationalDepth.casual,
    childMode: false,
    researchMode: false,
    emphasizePhysicalDescription: false,
    inviteFollowUp: true,
  );

  // -------------------------------------------------------------------------
  // Fakes (scripted, inert — never call real infrastructure).
  // -------------------------------------------------------------------------

  AudioDescriptionController buildController({
    required ExhibitRepository repository,
    required NarrationGenerator generator,
    required NarrationVoiceOutput voice,
    ConversationContextManager? context,
    NarrationPolicy resolvedPolicy = policy,
    String language = 'en',
  }) {
    return AudioDescriptionController(
      repository: repository,
      policyResolver: () => resolvedPolicy,
      promptBuilder: const NarrationPromptBuilder(),
      generator: generator,
      context: context ?? ConversationContextManager(),
      voice: voice,
      profile: AccessibilityProfile.initial,
      language: language,
    );
  }

  group('successful narration pipeline', () {
    test('runs loading → generating → speaking → completed and speaks narration',
        () async {
      final repo = _FakeRepository.found(metadata);
      final gen = _FakeGenerator.success('A tall inscribed slab of decrees.');
      final voice = _FakeVoice.accepting();
      final controller = buildController(
        repository: repo,
        generator: gen,
        voice: voice,
      );

      final transitions = <AudioDescriptionStatus>[];
      controller.onStateChanged = (s) => transitions.add(s.status);

      final result = await controller.describe(exhibit);

      expect(result.status, AudioDescriptionStatus.completed);
      expect(result.isCompleted, isTrue);
      expect(result.narration, 'A tall inscribed slab of decrees.');
      expect(result.exhibitId, exhibit);
      expect(
        transitions,
        [
          AudioDescriptionStatus.loading,
          AudioDescriptionStatus.generating,
          AudioDescriptionStatus.speaking,
          AudioDescriptionStatus.completed,
        ],
      );

      // Each collaborator was exercised exactly once, in order.
      expect(repo.calls, [exhibit]);
      expect(gen.calls, 1);
      expect(voice.spoken, ['A tall inscribed slab of decrees.']);
      expect(voice.languages, ['en']);
    });

    test('the prompt builder is fed the resolved metadata + policy', () async {
      final gen = _FakeGenerator.success('narration');
      final controller = buildController(
        repository: _FakeRepository.found(metadata),
        generator: gen,
        voice: _FakeVoice.accepting(),
      );

      await controller.describe(exhibit);

      // The controller builds a non-empty prompt from the real builder and hands
      // it to the generator (proving the prompt-builder stage ran).
      final prompt = gen.lastPrompt!;
      expect(prompt.userPrompt, contains('Rosetta Stone'));
      expect(prompt.length, NarrationLength.standard);
      expect(prompt.layers, isNotEmpty);
    });
  });

  group('repository stage', () {
    test('not found → failed with invalidExhibit and no generation', () async {
      final gen = _FakeGenerator.success('unused');
      final voice = _FakeVoice.accepting();
      final controller = buildController(
        repository: _FakeRepository.notFound(),
        generator: gen,
        voice: voice,
      );

      final result = await controller.describe(exhibit);

      expect(result.status, AudioDescriptionStatus.failed);
      expect(result.failureStage, AudioDescriptionFailureStage.invalidExhibit);
      expect(result.narration, isNull);
      expect(gen.calls, 0);
      expect(voice.spoken, isEmpty);
    });

    test('source unavailable → failed with repository stage', () async {
      final gen = _FakeGenerator.success('unused');
      final controller = buildController(
        repository: _FakeRepository.unavailable(),
        generator: gen,
        voice: _FakeVoice.accepting(),
      );

      final result = await controller.describe(exhibit);

      expect(result.status, AudioDescriptionStatus.failed);
      expect(result.failureStage, AudioDescriptionFailureStage.repository);
      expect(gen.calls, 0);
    });
  });

  group('generation stage', () {
    test('AI success → narration handed to voice', () async {
      final voice = _FakeVoice.accepting();
      final controller = buildController(
        repository: _FakeRepository.found(metadata),
        generator: _FakeGenerator.success('generated telling'),
        voice: voice,
      );

      final result = await controller.describe(exhibit);

      expect(result.status, AudioDescriptionStatus.completed);
      expect(voice.spoken, ['generated telling']);
    });

    test('AI failure → failed at generation stage, diagnostics propagated',
        () async {
      final voice = _FakeVoice.accepting();
      final controller = buildController(
        repository: _FakeRepository.found(metadata),
        generator: _FakeGenerator.failure(
          NarrationGenerationStatus.aiFailure,
          diagnostics: 'backend exploded: 503',
        ),
        voice: voice,
      );

      final result = await controller.describe(exhibit);

      expect(result.status, AudioDescriptionStatus.failed);
      expect(result.failureStage, AudioDescriptionFailureStage.generation);
      expect(result.diagnostics, 'backend exploded: 503');
      expect(result.narration, isNull);
      // Failing before voice means nothing is spoken.
      expect(voice.spoken, isEmpty);
    });

    test('AI failure without diagnostics falls back to the status key', () async {
      final controller = buildController(
        repository: _FakeRepository.found(metadata),
        generator: _FakeGenerator.failure(NarrationGenerationStatus.timeout),
        voice: _FakeVoice.accepting(),
      );

      final result = await controller.describe(exhibit);

      expect(result.failureStage, AudioDescriptionFailureStage.generation);
      expect(result.diagnostics, NarrationGenerationStatus.timeout.storageKey);
    });
  });

  group('voice stage', () {
    test('voice accepts → completed', () async {
      final controller = buildController(
        repository: _FakeRepository.found(metadata),
        generator: _FakeGenerator.success('spoken'),
        voice: _FakeVoice.accepting(),
      );

      final result = await controller.describe(exhibit);

      expect(result.status, AudioDescriptionStatus.completed);
    });

    test('voice rejects → failed at voice stage', () async {
      final controller = buildController(
        repository: _FakeRepository.found(metadata),
        generator: _FakeGenerator.success('spoken'),
        voice: _FakeVoice.rejecting(),
      );

      final result = await controller.describe(exhibit);

      expect(result.status, AudioDescriptionStatus.failed);
      expect(result.failureStage, AudioDescriptionFailureStage.voice);
      expect(result.diagnostics, contains('rejected'));
    });

    test('voice throwing → failed at voice stage with the error in diagnostics',
        () async {
      final controller = buildController(
        repository: _FakeRepository.found(metadata),
        generator: _FakeGenerator.success('spoken'),
        voice: _FakeVoice.throwing(StateError('tts crashed')),
      );

      final result = await controller.describe(exhibit);

      expect(result.status, AudioDescriptionStatus.failed);
      expect(result.failureStage, AudioDescriptionFailureStage.voice);
      expect(result.diagnostics, contains('tts crashed'));
    });
  });

  group('cancellation', () {
    test('cancelling while generating → cancelled, voice never speaks', () async {
      final gen = _FakeGenerator.deferred();
      final voice = _FakeVoice.accepting();
      final controller = buildController(
        repository: _FakeRepository.found(metadata),
        generator: gen,
        voice: voice,
      );

      final future = controller.describe(exhibit);
      // Let the pipeline advance to the generating stage (repo await resolves).
      await _pump();
      expect(controller.state.status, AudioDescriptionStatus.generating);

      controller.cancel();
      // Now allow the deferred generation to complete late.
      gen.complete('too late');
      final result = await future;

      // The superseded run must not publish speaking/completed.
      expect(controller.state.status, AudioDescriptionStatus.cancelled);
      expect(result.status, AudioDescriptionStatus.cancelled);
      expect(voice.spoken, isEmpty);
      // Cancelling during generation does not touch the voice engine at all.
      expect(voice.stopCalls, 0);
    });

    test('cancelling while speaking → cancelled and stopNarration() invoked',
        () async {
      final voice = _FakeVoice.deferred();
      final controller = buildController(
        repository: _FakeRepository.found(metadata),
        generator: _FakeGenerator.success('long narration'),
        voice: voice,
      );

      final future = controller.describe(exhibit);
      // Advance through repo + generation until the run is awaiting the voice.
      await _pump();
      expect(controller.state.status, AudioDescriptionStatus.speaking);

      controller.cancel();
      expect(controller.state.status, AudioDescriptionStatus.cancelled);
      // Active audio must be stopped through the seam.
      await _pump();
      expect(voice.stopCalls, 1);

      // The late voice acceptance must not resurrect the run to completed.
      voice.complete(true);
      final result = await future;
      expect(result.status, AudioDescriptionStatus.cancelled);
      expect(controller.state.status, AudioDescriptionStatus.cancelled);
    });

    test('cancel() is a no-op before any run / after terminal state', () async {
      final controller = buildController(
        repository: _FakeRepository.found(metadata),
        generator: _FakeGenerator.success('done'),
        voice: _FakeVoice.accepting(),
      );

      // No run yet (idle): cancel does nothing.
      controller.cancel();
      expect(controller.state.status, AudioDescriptionStatus.idle);

      // After a completed run, cancel does not overwrite the terminal state.
      await controller.describe(exhibit);
      expect(controller.state.status, AudioDescriptionStatus.completed);
      controller.cancel();
      expect(controller.state.status, AudioDescriptionStatus.completed);
    });
  });

  group('supersession (repeated describe calls)', () {
    test('a newer describe() run supersedes an in-flight one', () async {
      final gen = _FakeGenerator.deferred();
      final voice = _FakeVoice.accepting();
      final controller = buildController(
        repository: _FakeRepository.found(metadata),
        generator: gen,
        voice: voice,
      );

      final other = ExhibitId('sphinx');
      final first = controller.describe(exhibit);
      await _pump();
      expect(controller.state.status, AudioDescriptionStatus.generating);

      // Start a second run before the first finishes generating.
      final second = controller.describe(other);
      // Resolve the first (now-stale) generation late — it must not publish.
      gen.complete('stale narration');
      final firstResult = await first;

      // The stale run observes the token change and returns the current state
      // without ever speaking its narration.
      expect(firstResult.status, isNot(AudioDescriptionStatus.completed));
      expect(voice.spoken, isNot(contains('stale narration')));

      // Let the second run advance to its own generate-await, then finish it.
      await _pump();
      gen.complete('fresh narration');
      final secondResult = await second;
      expect(secondResult.status, AudioDescriptionStatus.completed);
      expect(secondResult.exhibitId, other);
    });
  });

  group('conversation context integration', () {
    test('context updated after a successful narration', () async {
      final context = ConversationContextManager();
      final controller = buildController(
        repository: _FakeRepository.found(metadata),
        generator: _FakeGenerator.success('a fine telling'),
        voice: _FakeVoice.accepting(),
        context: context,
      );

      await controller.describe(exhibit);

      expect(context.current.exhibitId, exhibit);
      expect(context.current.lastNarration, 'a fine telling');
      expect(context.current.metadata, metadata);
    });

    test('context NOT updated after a failed narration (generation failure)',
        () async {
      final context = ConversationContextManager();
      final controller = buildController(
        repository: _FakeRepository.found(metadata),
        generator: _FakeGenerator.failure(NarrationGenerationStatus.aiFailure),
        voice: _FakeVoice.accepting(),
        context: context,
      );

      final result = await controller.describe(exhibit);

      expect(result.status, AudioDescriptionStatus.failed);
      // A failed run must leave the conversation context untouched.
      expect(context.current.exhibitId, isNull);
      expect(context.current.lastNarration, isNull);
    });

    test('context NOT updated when the exhibit is not found', () async {
      final context = ConversationContextManager();
      final controller = buildController(
        repository: _FakeRepository.notFound(),
        generator: _FakeGenerator.success('unused'),
        voice: _FakeVoice.accepting(),
        context: context,
      );

      await controller.describe(exhibit);

      expect(context.current.exhibitId, isNull);
      expect(context.current.lastNarration, isNull);
    });
  });

  group('state details & diagnostics', () {
    test('failure state carries the exhibit id, language, stage, diagnostics',
        () async {
      final controller = buildController(
        repository: _FakeRepository.unavailable(),
        generator: _FakeGenerator.success('unused'),
        voice: _FakeVoice.accepting(),
        language: 'ar',
      );

      final result = await controller.describe(exhibit);

      expect(result.exhibitId, exhibit);
      expect(result.language, 'ar');
      expect(result.failureStage, AudioDescriptionFailureStage.repository);
      expect(result.diagnostics, isNotNull);
      expect(result.isFailed, isTrue);
    });

    test('every published state is also the controller.state at that moment',
        () async {
      final controller = buildController(
        repository: _FakeRepository.found(metadata),
        generator: _FakeGenerator.success('x'),
        voice: _FakeVoice.accepting(),
      );

      controller.onStateChanged = (s) {
        // The published snapshot and the getter must agree at all times.
        expect(identical(controller.state, s), isTrue);
      };

      await controller.describe(exhibit);
    });
  });
}

/// Yield to the microtask/event queue so scheduled awaits advance.
Future<void> _pump() => Future<void>.delayed(Duration.zero);

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeRepository implements ExhibitRepository {
  _FakeRepository(this._result);

  factory _FakeRepository.found(ExhibitMetadata metadata) =>
      _FakeRepository(ExhibitLookupResult.found(metadata));
  factory _FakeRepository.notFound() =>
      _FakeRepository(ExhibitLookupResult.notFound);
  factory _FakeRepository.unavailable() =>
      _FakeRepository(ExhibitLookupResult.sourceUnavailable);

  final ExhibitLookupResult _result;
  final List<ExhibitId> calls = [];

  @override
  Future<ExhibitLookupResult> getExhibit(ExhibitId id) async {
    calls.add(id);
    return _result;
  }
}

class _FakeGenerator implements NarrationGenerator {
  _FakeGenerator._({NarrationGenerationResult? immediate})
      : _immediate = immediate;

  factory _FakeGenerator.success(String narration) => _FakeGenerator._(
        immediate: NarrationGenerationResult.success(narration),
      );

  factory _FakeGenerator.failure(
    NarrationGenerationStatus status, {
    String? diagnostics,
  }) =>
      _FakeGenerator._(
        immediate: NarrationGenerationResult.failure(
          status,
          diagnostics: diagnostics,
        ),
      );

  /// A generator whose result is supplied later via [complete], so a test can
  /// interleave cancellation/supersession before it resolves.
  factory _FakeGenerator.deferred() => _FakeGenerator._();

  final NarrationGenerationResult? _immediate;
  Completer<NarrationGenerationResult>? _pending;

  int calls = 0;
  NarrationPrompt? lastPrompt;

  void complete(String narration) {
    _pending?.complete(NarrationGenerationResult.success(narration));
    _pending = null;
  }

  @override
  Future<NarrationGenerationResult> generate(NarrationPrompt prompt) {
    calls++;
    lastPrompt = prompt;
    final immediate = _immediate;
    if (immediate != null) return Future.value(immediate);
    return (_pending = Completer<NarrationGenerationResult>()).future;
  }
}

class _FakeVoice implements NarrationVoiceOutput {
  _FakeVoice._({
    bool accept = true,
    Object? throwsError,
    bool deferred = false,
  })  : _accept = accept,
        _throwsError = throwsError,
        _deferred = deferred;

  factory _FakeVoice.accepting() => _FakeVoice._(accept: true);
  factory _FakeVoice.rejecting() => _FakeVoice._(accept: false);
  factory _FakeVoice.throwing(Object error) =>
      _FakeVoice._(throwsError: error);

  /// A voice whose speak result is supplied later via [complete], so a test can
  /// cancel while the controller is parked in the speaking stage.
  factory _FakeVoice.deferred() => _FakeVoice._(deferred: true);

  final bool _accept;
  final Object? _throwsError;
  final bool _deferred;

  final List<String> spoken = [];
  final List<String> languages = [];
  int stopCalls = 0;
  Completer<bool>? _pending;

  void complete(bool accepted) {
    _pending?.complete(accepted);
    _pending = null;
  }

  @override
  Future<bool> speakNarration(String narration, {required String language}) {
    spoken.add(narration);
    languages.add(language);
    final error = _throwsError;
    if (error != null) return Future.error(error);
    if (_deferred) return (_pending = Completer<bool>()).future;
    return Future.value(_accept);
  }

  @override
  Future<void> stopNarration() async {
    stopCalls++;
  }
}
