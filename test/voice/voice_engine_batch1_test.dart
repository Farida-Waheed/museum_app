import 'package:flutter_test/flutter_test.dart';
import 'package:museum_app/voice/voice.dart';
import 'package:museum_app/voice/integration/notification_voice_bridge.dart';
import 'package:museum_app/core/notifications/notification_models.dart';
import 'package:museum_app/core/notifications/notification_types.dart';

/// Batch 1 of the Voice Communication Engine (Phase 3) test suite.
///
/// Covers the four pure, deterministic units — no Flutter binding, no plugin,
/// no timers — mirroring the accessibility module's plain-Dart test style:
///   * [VoiceQueueManager]      — ordering / interruption / dedup / cap policy
///   * [VoiceCommandParser]     — bilingual utterance → intent grammar
///   * [RobotSpeechCoordinator] — the shared speaking-floor policy
///   * [NotificationVoiceBridge]— "only meaningful notifications" policy
void main() {
  // ---------------------------------------------------------------------------
  // VoiceQueueManager
  // ---------------------------------------------------------------------------
  group('VoiceQueueManager ordering & interruption', () {
    // Deterministic message factory: fixed nowMs + explicit dedupKey so nothing
    // collapses by accident and creation order is unambiguous.
    VoiceMessage msg(
      String text,
      VoicePriority priority, {
      int nowMs = 0,
      String? dedupKey,
    }) =>
        VoiceMessage(
          content: VoiceContent.plain(text),
          priority: priority,
          language: VoiceLanguage.english,
          nowMs: nowMs,
          dedupKey: dedupKey ?? 'k:$text',
        );

    test('higher priority is dequeued before lower priority', () {
      final q = VoiceQueueManager();
      q.enqueue(msg('content', VoicePriority.content));
      q.enqueue(msg('nav', VoicePriority.navigation));
      q.enqueue(msg('ambient', VoicePriority.ambient));

      expect(q.takeNext()!.text, 'nav');
      expect(q.takeNext()!.text, 'content');
      expect(q.takeNext()!.text, 'ambient');
      expect(q.takeNext(), isNull);
    });

    test('equal priority keeps FIFO (stable) order', () {
      final q = VoiceQueueManager();
      q.enqueue(msg('first', VoicePriority.content, nowMs: 1));
      q.enqueue(msg('second', VoicePriority.content, nowMs: 2));
      q.enqueue(msg('third', VoicePriority.content, nowMs: 3));

      expect(q.takeNext()!.text, 'first');
      expect(q.takeNext()!.text, 'second');
      expect(q.takeNext()!.text, 'third');
    });

    test('enqueue reports interrupt when it outranks the current utterance', () {
      final q = VoiceQueueManager();
      q.enqueue(msg('content', VoicePriority.content));
      q.takeNext(); // content now "speaking"

      final result = q.enqueue(msg('sos', VoicePriority.critical));
      expect(result, VoiceEnqueueResult.interrupt);
    });

    test('lower priority queues (never interrupts) behind the current one', () {
      final q = VoiceQueueManager();
      q.enqueue(msg('nav', VoicePriority.navigation));
      q.takeNext(); // navigation "speaking"

      final result = q.enqueue(msg('ambient', VoicePriority.ambient));
      expect(result, VoiceEnqueueResult.queued);
    });

    test('critical clears all lower-priority pending items', () {
      final q = VoiceQueueManager();
      q.enqueue(msg('content', VoicePriority.content));
      q.enqueue(msg('nav', VoicePriority.navigation));
      q.enqueue(msg('ambient', VoicePriority.ambient));

      q.enqueue(msg('sos', VoicePriority.critical));

      // Only the critical message survives, spoken first.
      expect(q.length, 1);
      expect(q.takeNext()!.text, 'sos');
      expect(q.isEmpty, isTrue);
    });

    test('duplicates within the window are rejected', () {
      final q = VoiceQueueManager();
      final a = q.enqueue(msg('turn left', VoicePriority.navigation,
          nowMs: 0, dedupKey: 'dup'));
      final b = q.enqueue(msg('turn left', VoicePriority.navigation,
          nowMs: 100, dedupKey: 'dup'));

      expect(a, VoiceEnqueueResult.queued);
      expect(b, VoiceEnqueueResult.duplicate);
      expect(q.length, 1);
    });

    test('identical text past the dedup window is allowed again', () {
      final q = VoiceQueueManager(duplicateWindow: const Duration(seconds: 4));
      q.enqueue(msg('turn left', VoicePriority.navigation,
          nowMs: 0, dedupKey: 'dup'));
      final later = q.enqueue(msg('turn left', VoicePriority.navigation,
          nowMs: 5000, dedupKey: 'dup'));

      expect(later, VoiceEnqueueResult.queued);
      expect(q.length, 2);
    });

    test('the queue is capped and evicts the least-urgent items', () {
      final q = VoiceQueueManager(maxLength: 3);
      // Distinct dedup keys so nothing collapses; low priority should be evicted.
      q.enqueue(msg('amb1', VoicePriority.ambient, dedupKey: 'a1'));
      q.enqueue(msg('amb2', VoicePriority.ambient, dedupKey: 'a2'));
      q.enqueue(msg('nav1', VoicePriority.navigation, dedupKey: 'n1'));
      q.enqueue(msg('nav2', VoicePriority.navigation, dedupKey: 'n2'));

      expect(q.length, 3);
      final texts = q.pending.map((m) => m.text).toList();
      // An ambient item was evicted; both navigation items are retained.
      expect(texts, contains('nav1'));
      expect(texts, contains('nav2'));
    });

    test('clear empties pending but not the current message', () {
      final q = VoiceQueueManager();
      q.enqueue(msg('a', VoicePriority.content, dedupKey: 'a'));
      q.enqueue(msg('b', VoicePriority.content, dedupKey: 'b'));
      q.takeNext(); // a is current
      q.clear();

      expect(q.isEmpty, isTrue);
      expect(q.current!.text, 'a');
    });
  });

  // ---------------------------------------------------------------------------
  // VoiceCommandParser
  // ---------------------------------------------------------------------------
  group('VoiceCommandParser bilingual grammar', () {
    const parser = VoiceCommandParser();

    test('parses core English commands', () {
      expect(parser.parse('stop').intent, VoiceCommandIntent.stopSpeaking);
      expect(parser.parse('next exhibit').intent, VoiceCommandIntent.nextExhibit);
      expect(parser.parse('go back').intent, VoiceCommandIntent.previousExhibit);
      expect(parser.parse('repeat that').intent,
          VoiceCommandIntent.repeatExplanation);
      expect(parser.parse('start the tour').intent,
          VoiceCommandIntent.startTour);
      expect(parser.parse('louder').intent, VoiceCommandIntent.increaseVolume);
      expect(parser.parse('slow down').intent, VoiceCommandIntent.slowerSpeech);
    });

    test('parses core Arabic commands', () {
      expect(parser.parse('توقف').intent, VoiceCommandIntent.stopSpeaking);
      expect(parser.parse('التالي').intent, VoiceCommandIntent.nextExhibit);
      expect(parser.parse('مساعدة').intent, VoiceCommandIntent.callAssistance);
      expect(parser.parse('كرر').intent, VoiceCommandIntent.repeatExplanation);
    });

    test('normalizes Arabic diacritics before matching', () {
      // "توقّف" (with shadda) must match the same intent as "توقف".
      expect(parser.parse('توقّف').intent, VoiceCommandIntent.stopSpeaking);
    });

    test('word-boundary aware: "restart" does not fire "start"', () {
      expect(parser.parse('restart').intent, isNot(VoiceCommandIntent.startTour));
    });

    test('unrecognized speech returns unknown and is not actionable', () {
      final cmd = parser.parse('what time does the cafe close');
      expect(cmd.intent, VoiceCommandIntent.unknown);
      expect(cmd.isActionable, isFalse);
    });

    test('empty transcript returns unknown', () {
      expect(parser.parse('   ').intent, VoiceCommandIntent.unknown);
    });

    test('carries confidence and preserves the trimmed transcript', () {
      final cmd = parser.parse('  next  ', confidence: 0.8);
      expect(cmd.intent, VoiceCommandIntent.nextExhibit);
      expect(cmd.transcript, 'next');
      expect(cmd.confidence, closeTo(0.8, 0.0001));
    });

    test('immediate safety commands are actionable at low confidence', () {
      // stop is immediate (threshold 0.3); a normal command needs >= 0.5.
      final stop = parser.parse('stop', confidence: 0.35);
      final next = parser.parse('next', confidence: 0.35);
      expect(stop.isActionable, isTrue);
      expect(next.isActionable, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // RobotSpeechCoordinator
  // ---------------------------------------------------------------------------
  group('RobotSpeechCoordinator speaking floor', () {
    test('app speaks freely when the robot is silent', () async {
      final coordinator = RobotSpeechCoordinator(link: _FakeRobotLink());
      expect(await coordinator.acquireFloor(VoicePriority.content), isTrue);
    });

    test('non-essential app speech yields while the robot is speaking', () async {
      final link = _FakeRobotLink()..speaking = true;
      final coordinator = RobotSpeechCoordinator(link: link);

      expect(await coordinator.acquireFloor(VoicePriority.content), isFalse);
      expect(link.silenceRequests, 0);
    });

    test('essential app speech silences a speaking robot, then releases it',
        () async {
      final link = _FakeRobotLink()..speaking = true;
      final coordinator = RobotSpeechCoordinator(link: link);

      expect(await coordinator.acquireFloor(VoicePriority.navigation), isTrue);
      expect(link.silenceRequests, 1);

      await coordinator.releaseFloor();
      expect(link.silenceReleases, 1);
    });

    test('releaseFloor is a no-op when we never silenced the robot', () async {
      final link = _FakeRobotLink(); // robot not speaking
      final coordinator = RobotSpeechCoordinator(link: link);

      await coordinator.acquireFloor(VoicePriority.navigation);
      await coordinator.releaseFloor();
      expect(link.silenceReleases, 0);
    });

    test('isEssential is navigation-and-above', () {
      expect(RobotSpeechCoordinator.isEssential(VoicePriority.ambient), isFalse);
      expect(RobotSpeechCoordinator.isEssential(VoicePriority.content), isFalse);
      expect(
          RobotSpeechCoordinator.isEssential(VoicePriority.navigation), isTrue);
      expect(
          RobotSpeechCoordinator.isEssential(VoicePriority.critical), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // NotificationVoiceBridge
  // ---------------------------------------------------------------------------
  group('NotificationVoiceBridge "only meaningful" policy', () {
    ImmediateNotification notif({
      required NotificationType type,
      required NotificationPriority priority,
      String title = 'Title',
      String body = 'Body',
    }) =>
        ImmediateNotification(
          id: 1,
          type: type,
          title: title,
          body: body,
          priority: priority,
          category: NotificationCategory.tourUpdates,
          payload: NotificationPayload(type: type),
        );

    test('meaningful medium/high notifications are announced', () {
      final n = notif(
        type: NotificationType.robotDisconnected,
        priority: NotificationPriority.high,
      );
      expect(NotificationVoiceBridge.shouldAnnounce(n), isTrue);
      expect(NotificationVoiceBridge.spokenText(n), 'Title. Body');
    });

    test('low-priority (passive/batched) notifications are never spoken', () {
      final n = notif(
        type: NotificationType.tourStarted,
        priority: NotificationPriority.low,
      );
      expect(NotificationVoiceBridge.shouldAnnounce(n), isFalse);
    });

    test('passive engagement types are excluded even at medium priority', () {
      for (final type in NotificationVoiceBridge.passiveTypes) {
        final n = notif(type: type, priority: NotificationPriority.medium);
        expect(NotificationVoiceBridge.shouldAnnounce(n), isFalse,
            reason: '$type should not be spoken');
      }
    });

    test('spokenText joins title and body, tolerating an empty side', () {
      final titleOnly = notif(
        type: NotificationType.tourStarted,
        priority: NotificationPriority.high,
        body: '   ',
      );
      final bodyOnly = notif(
        type: NotificationType.tourStarted,
        priority: NotificationPriority.high,
        title: '   ',
      );
      expect(NotificationVoiceBridge.spokenText(titleOnly), 'Title');
      expect(NotificationVoiceBridge.spokenText(bodyOnly), 'Body');
    });

    test('announce speaks meaningful notifications through the injected sink',
        () {
      final spoken = <String>[];
      final bridge = NotificationVoiceBridge(speak: spoken.add);

      bridge.announce(notif(
        type: NotificationType.museumClosingSoon,
        priority: NotificationPriority.high,
      ));
      expect(spoken, ['Title. Body']);
    });

    test('announce is a silent no-op for non-meaningful notifications', () {
      final spoken = <String>[];
      final bridge = NotificationVoiceBridge(speak: spoken.add);

      bridge.announce(notif(
        type: NotificationType.didYouKnow,
        priority: NotificationPriority.low,
      ));
      expect(spoken, isEmpty);
    });
  });
}

/// Minimal in-memory [RobotSpeechLink] double: a controllable speaking flag and
/// counters for silence request/release, so the floor policy is fully testable
/// with no robot dependency.
class _FakeRobotLink implements RobotSpeechLink {
  bool speaking = false;
  int silenceRequests = 0;
  int silenceReleases = 0;
  void Function(bool speaking)? _handler;

  @override
  bool get robotIsSpeaking => speaking;

  @override
  Future<void> requestRobotSilence() async => silenceRequests++;

  @override
  Future<void> releaseRobotSilence() async => silenceReleases++;

  @override
  set onRobotSpeakingChanged(void Function(bool speaking)? handler) =>
      _handler = handler;

  /// Simulate the robot reporting a speaking-state change from MQTT: flip the
  /// flag and notify the coordinator exactly as the production link would.
  void emitSpeaking(bool value) {
    speaking = value;
    _handler?.call(value);
  }
}
