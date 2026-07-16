import '../enums/voice_enums.dart';

/// The channel through which the app coordinates speech with the physical robot.
/// Abstracted (DIP) so the engine never imports `RobotMqttService` directly —
/// the concrete MQTT wiring is owned by the robot/tour phase and dropped in here,
/// exactly as Phase 1/2 left robot publishing as a "seam ready" integration.
///
/// The default [NoopRobotSpeechLink] behaves as if no robot is present (the
/// robot never speaks), so the whole voice engine runs and is fully testable
/// with no robot dependency.
abstract class RobotSpeechLink {
  /// Whether the robot is speaking right now (fed from robot status/events).
  bool get robotIsSpeaking;

  /// Ask the robot to pause its non-essential narration so the app can speak an
  /// essential message (e.g. navigation) without overlapping.
  Future<void> requestRobotSilence();

  /// Allow the robot to resume once the app has finished its essential message.
  Future<void> releaseRobotSilence();

  /// Notifies when the robot's speaking state flips, so the coordinator can
  /// resume draining the app queue the moment the robot goes quiet.
  set onRobotSpeakingChanged(void Function(bool speaking)? handler);
}

/// No robot present: nothing ever blocks the app, nothing needs silencing.
class NoopRobotSpeechLink implements RobotSpeechLink {
  @override
  bool get robotIsSpeaking => false;

  @override
  Future<void> requestRobotSilence() async {}

  @override
  Future<void> releaseRobotSilence() async {}

  @override
  set onRobotSpeakingChanged(void Function(bool speaking)? handler) {}
}

/// Mediates the shared "speaking floor" between the mobile app and the robot so
/// the two never talk over each other (the Robot Speech Synchronization
/// requirement). The rules:
///
/// * If the robot is speaking and the app's message is **essential**
///   (navigation / interactive / critical), ask the robot to fall silent and
///   let the app speak.
/// * If the robot is speaking and the app's message is **non-essential**
///   (ambient / content), the app waits for the robot to finish.
/// * If the robot is silent, the app speaks freely.
///
/// Only *policy* lives here; playback timing lives in the [VoiceCoordinator].
/// That split keeps the mediation logic pure and unit-testable with a fake link.
class RobotSpeechCoordinator {
  RobotSpeechCoordinator({RobotSpeechLink? link})
      : _link = link ?? NoopRobotSpeechLink();

  final RobotSpeechLink _link;
  bool _weSilencedRobot = false;

  /// Wire a callback invoked when the robot stops speaking (so the coordinator
  /// can resume its queue). Pass-through to the link.
  set onRobotFreed(void Function()? handler) {
    _link.onRobotSpeakingChanged =
        handler == null ? null : (speaking) => speaking ? null : handler();
  }

  bool get robotIsSpeaking => _link.robotIsSpeaking;

  /// A message is essential if it is navigation-priority or above — guidance and
  /// safety must be heard promptly; exhibit chatter can wait for the robot.
  static bool isEssential(VoicePriority priority) =>
      priority.index >= VoicePriority.navigation.index;

  /// Try to take the floor for a message of [priority]. Returns true if the app
  /// may speak now, false if it must wait for the robot to finish.
  Future<bool> acquireFloor(VoicePriority priority) async {
    if (!_link.robotIsSpeaking) return true;
    if (isEssential(priority)) {
      await _link.requestRobotSilence();
      _weSilencedRobot = true;
      return true;
    }
    return false; // non-essential yields to the robot
  }

  /// Release the floor after the app's essential message finishes, letting the
  /// robot resume if we were the ones who silenced it.
  Future<void> releaseFloor() async {
    if (_weSilencedRobot) {
      _weSilencedRobot = false;
      await _link.releaseRobotSilence();
    }
  }
}
