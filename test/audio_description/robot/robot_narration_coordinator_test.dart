import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:museum_app/accessibility/accessibility.dart';
import 'package:museum_app/audio_description/ai/narration_generation_result.dart';
import 'package:museum_app/audio_description/ai/narration_generator.dart';
import 'package:museum_app/audio_description/context/conversation_context_manager.dart';
import 'package:museum_app/audio_description/controller/audio_description_controller.dart';
import 'package:museum_app/audio_description/controller/audio_description_state.dart';
import 'package:museum_app/audio_description/models/audio_description_enums.dart';
import 'package:museum_app/audio_description/models/exhibit_id.dart';
import 'package:museum_app/audio_description/models/exhibit_metadata.dart';
import 'package:museum_app/audio_description/models/narration_policy.dart';
import 'package:museum_app/audio_description/prompt/narration_prompt.dart';
import 'package:museum_app/audio_description/prompt/narration_prompt_builder.dart';
import 'package:museum_app/audio_description/repository/exhibit_lookup_result.dart';
import 'package:museum_app/audio_description/robot/robot_motion_link.dart';
import 'package:museum_app/audio_description/robot/robot_narration_coordinator.dart';
import 'package:museum_app/audio_description/robot/robot_narration_state.dart';

/// Phase 4 Task 9 — RobotNarrationCoordinator synchronization tests.
///
/// The coordinator is a pure orchestrator. Every dependency here is a fake or a
/// real (pure) component: a controllable [_FakeMotionLink] drives robot
/// motion/position/connection events, and the real Task 7
/// [AudioDescriptionController] is wired to a fake repository/generator/voice.
/// No AI, network, Firebase, MQTT, or TTS plugin is touched.
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

  _Harness harness({
    bool moving = false,
    bool inPosition = true,
    bool connected = true,
    NarrationGenerationResult? generation,
    bool deferredVoice = false,
  }) {
    final motion = _FakeMotionLink(
      moving: moving,
      inPosition: inPosition,
      connected: connected,
    );
    final repo = _FakeRepository(ExhibitLookupResult.found(metadata));
    final gen = _FakeGenerator(
        generation ?? NarrationGenerationResult.success('a telling'));
    final voice = _FakeVoice(deferred: deferredVoice);
    final narration = AudioDescriptionController(
      repository: repo,
      policyResolver: () => policy,
      promptBuilder: const NarrationPromptBuilder(),
      generator: gen,
      context: ConversationContextManager(),
      voice: voice,
      profile: AccessibilityProfile.initial,
    );
    final coordinator = RobotNarrationCoordinator(
      motion: motion,
      narrationController: narration,
      voice: voice,
    );
    final transitions = <RobotNarrationStatus>[];
    coordinator.onStateChanged = (s) => transitions.add(s.status);
    return _Harness(
      coordinator: coordinator,
      motion: motion,
      gen: gen,
      voice: voice,
      transitions: transitions,
    );
  }

  group('robot reaches exhibit', () {
    test('stopped + in position → narrates and completes', () async {
      final h = harness();

      final result = await h.coordinator.onExhibitReached(exhibit);

      expect(result.status, RobotNarrationStatus.completed);
      expect(result.exhibitId, exhibit);
      expect(h.gen.calls, 1);
      expect(h.voice.spoken, ['a telling']);
    });

    test('publishes narrating before completed', () async {
      final h = harness();

      await h.coordinator.onExhibitReached(exhibit);

      expect(h.transitions,
          [RobotNarrationStatus.narrating, RobotNarrationStatus.completed]);
    });
  });

  group('robot still moving', () {
    test('holds in waitingForStop and does not narrate', () async {
      final h = harness(moving: true);

      final result = await h.coordinator.onExhibitReached(exhibit);

      expect(result.status, RobotNarrationStatus.waitingForStop);
      expect(h.gen.calls, 0);
      expect(h.voice.spoken, isEmpty);
    });

    test('stopped but not in position → waitingForPosition', () async {
      final h = harness(moving: false, inPosition: false);

      final result = await h.coordinator.onExhibitReached(exhibit);

      expect(result.status, RobotNarrationStatus.waitingForPosition);
      expect(h.gen.calls, 0);
    });
  });

  group('robot stops then narration begins', () {
    test('waitingForStop → stop event → narrates', () async {
      final h = harness(moving: true);
      await h.coordinator.onExhibitReached(exhibit);
      expect(h.coordinator.state.status, RobotNarrationStatus.waitingForStop);

      h.motion.setMoving(false);
      await _pump();

      expect(h.coordinator.state.status, RobotNarrationStatus.completed);
      expect(h.gen.calls, 1);
    });

    test('waitingForPosition → position gained → narrates', () async {
      final h = harness(moving: false, inPosition: false);
      await h.coordinator.onExhibitReached(exhibit);
      expect(
          h.coordinator.state.status, RobotNarrationStatus.waitingForPosition);

      h.motion.setInPosition(true);
      await _pump();

      expect(h.coordinator.state.status, RobotNarrationStatus.completed);
      expect(h.gen.calls, 1);
    });
  });

  group('unexpected movement during narration', () {
    test('robot moves mid-narration → pausedForMovement, voice stopped',
        () async {
      final h = harness(deferredVoice: true);
      // Start narration; it parks in the voice stage (deferred).
      final future = h.coordinator.onExhibitReached(exhibit);
      await _pump();
      expect(h.coordinator.state.status, RobotNarrationStatus.narrating);

      h.motion.setMoving(true);
      await _pump();

      expect(
          h.coordinator.state.status, RobotNarrationStatus.pausedForMovement);
      expect(h.voice.stopCalls, greaterThanOrEqualTo(1));

      // The superseded narration must not resurrect to completed.
      h.voice.complete(true);
      await future;
      expect(
          h.coordinator.state.status, RobotNarrationStatus.pausedForMovement);
    });
  });

  group('narration resume', () {
    test('pausedForMovement → movement stops → re-narrates to completed',
        () async {
      final h = harness(deferredVoice: true);
      final future = h.coordinator.onExhibitReached(exhibit);
      await _pump();
      h.motion.setMoving(true);
      await _pump();
      // Let the first (deferred) voice call resolve into the superseded void.
      h.voice.complete(true);
      await future;
      expect(
          h.coordinator.state.status, RobotNarrationStatus.pausedForMovement);

      // Now the voice accepts immediately so the resume run can complete.
      h.voice.deferred = false;
      h.motion.setMoving(false);
      await _pump();

      expect(h.coordinator.state.status, RobotNarrationStatus.completed);
      // Narrated once before the pause and once on resume.
      expect(h.gen.calls, 2);
    });
  });

  group('skip exhibit', () {
    test('skip stops audio and reports skipped', () async {
      final h = harness(deferredVoice: true);
      final future = h.coordinator.onExhibitReached(exhibit);
      await _pump();
      expect(h.coordinator.state.status, RobotNarrationStatus.narrating);

      final result = await h.coordinator.skip();

      expect(result.status, RobotNarrationStatus.skipped);
      expect(h.voice.stopCalls, greaterThanOrEqualTo(1));

      h.voice.complete(true);
      await future;
      expect(h.coordinator.state.status, RobotNarrationStatus.skipped);
    });

    test('skip when idle is a no-op', () async {
      final h = harness();

      final result = await h.coordinator.skip();

      expect(result.status, RobotNarrationStatus.idle);
    });
  });

  group('robot disconnect', () {
    test('disconnected on reach → held in disconnected, no narration',
        () async {
      final h = harness(connected: false);

      final result = await h.coordinator.onExhibitReached(exhibit);

      expect(result.status, RobotNarrationStatus.disconnected);
      expect(h.gen.calls, 0);
    });

    test('disconnect mid-narration → disconnected and audio stopped', () async {
      final h = harness(deferredVoice: true);
      final future = h.coordinator.onExhibitReached(exhibit);
      await _pump();
      expect(h.coordinator.state.status, RobotNarrationStatus.narrating);

      h.motion.setConnected(false);
      await _pump();

      expect(h.coordinator.state.status, RobotNarrationStatus.disconnected);
      expect(h.voice.stopCalls, greaterThanOrEqualTo(1));

      h.voice.complete(true);
      await future;
      expect(h.coordinator.state.status, RobotNarrationStatus.disconnected);
    });

    test('reconnect after disconnect resumes toward narration', () async {
      final h = harness(connected: false);
      await h.coordinator.onExhibitReached(exhibit);
      expect(h.coordinator.state.status, RobotNarrationStatus.disconnected);

      h.motion.setConnected(true);
      await _pump();

      expect(h.coordinator.state.status, RobotNarrationStatus.completed);
      expect(h.gen.calls, 1);
    });
  });

  group('repeated robot events', () {
    test('duplicate stop events do not double-narrate', () async {
      final h = harness();
      await h.coordinator.onExhibitReached(exhibit);
      expect(h.coordinator.state.status, RobotNarrationStatus.completed);

      // Further motion events after a terminal stop are ignored.
      h.motion.setMoving(false);
      h.motion.setMoving(false);
      await _pump();

      expect(h.gen.calls, 1);
      expect(h.coordinator.state.status, RobotNarrationStatus.completed);
    });

    test('a new exhibit reached supersedes the previous stop', () async {
      final h = harness();
      await h.coordinator.onExhibitReached(exhibit);

      final other = ExhibitId('sphinx');
      final result = await h.coordinator.onExhibitReached(other);

      expect(result.status, RobotNarrationStatus.completed);
      expect(result.exhibitId, other);
      expect(h.gen.calls, 2);
    });
  });

  group('state transitions', () {
    test('full gated sequence: moving → stop → position → narrate', () async {
      final h = harness(moving: true, inPosition: false);
      await h.coordinator.onExhibitReached(exhibit);
      expect(h.coordinator.state.status, RobotNarrationStatus.waitingForStop);

      h.motion.setMoving(false);
      await _pump();
      expect(
          h.coordinator.state.status, RobotNarrationStatus.waitingForPosition);

      h.motion.setInPosition(true);
      await _pump();
      expect(h.coordinator.state.status, RobotNarrationStatus.completed);
    });

    test('narration failure surfaces as failed', () async {
      final h = harness(
        generation: NarrationGenerationResult.failure(
          NarrationGenerationStatus.aiFailure,
          diagnostics: 'model 500',
        ),
      );

      final result = await h.coordinator.onExhibitReached(exhibit);

      expect(result.status, RobotNarrationStatus.failed);
      expect(result.diagnostics, contains('model 500'));
    });

    test('published state always equals coordinator.state', () async {
      final h = harness();
      h.coordinator.onStateChanged = (s) {
        expect(identical(h.coordinator.state, s), isTrue);
      };
      await h.coordinator.onExhibitReached(exhibit);
    });
  });
}

/// Yield so scheduled awaits (describe/voice) advance.
Future<void> _pump() => Future<void>.delayed(Duration.zero);

// ---------------------------------------------------------------------------
// Harness + fakes
// ---------------------------------------------------------------------------

class _Harness {
  _Harness({
    required this.coordinator,
    required this.motion,
    required this.gen,
    required this.voice,
    required this.transitions,
  });

  final RobotNarrationCoordinator coordinator;
  final _FakeMotionLink motion;
  final _FakeGenerator gen;
  final _FakeVoice voice;
  final List<RobotNarrationStatus> transitions;
}

/// A controllable robot motion seam: tests flip motion/position/connection and
/// the coordinator's registered callbacks fire, exactly as a real link would.
class _FakeMotionLink implements RobotMotionLink {
  _FakeMotionLink({
    required bool moving,
    required bool inPosition,
    required bool connected,
  })  : _moving = moving,
        _inPosition = inPosition,
        _connected = connected;

  bool _moving;
  bool _inPosition;
  bool _connected;

  void Function(bool moving)? _onMotion;
  void Function(bool inPosition)? _onPosition;
  void Function(bool connected)? _onConnection;

  @override
  bool get isMoving => _moving;

  @override
  bool get isInViewingPosition => _inPosition;

  @override
  bool get isConnected => _connected;

  @override
  set onMotionChanged(void Function(bool moving)? handler) => _onMotion = handler;

  @override
  set onViewingPositionChanged(void Function(bool inPosition)? handler) =>
      _onPosition = handler;

  @override
  set onConnectionChanged(void Function(bool connected)? handler) =>
      _onConnection = handler;

  void setMoving(bool value) {
    _moving = value;
    _onMotion?.call(value);
  }

  void setInPosition(bool value) {
    _inPosition = value;
    _onPosition?.call(value);
  }

  void setConnected(bool value) {
    _connected = value;
    _onConnection?.call(value);
  }
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
  _FakeVoice({bool deferred = false}) : deferred = deferred;

  bool deferred;
  final List<String> spoken = [];
  int stopCalls = 0;
  Completer<bool>? _pending;

  void complete(bool accepted) {
    _pending?.complete(accepted);
    _pending = null;
  }

  @override
  Future<bool> speakNarration(String narration, {required String language}) {
    spoken.add(narration);
    if (deferred) return (_pending = Completer<bool>()).future;
    return Future.value(true);
  }

  @override
  Future<void> stopNarration() async {
    stopCalls++;
  }
}
