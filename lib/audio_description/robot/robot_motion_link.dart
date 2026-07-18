/// The narrow seam through which the narration synchronizer observes the
/// physical robot's *motion and viewing-position* state — the movement analogue
/// of the voice module's `RobotSpeechLink` (which only models the speaking
/// floor). It is deliberately observation-only and abstracted (DIP) so this
/// layer never imports `RobotMqttService`, implements no navigation, MQTT,
/// localization, or robot control, and stays fully testable with a fake.
///
/// The concrete motion wiring (mapping the existing robot status/event streams
/// to these signals) belongs to the robot/tour phase and drops in here, exactly
/// as `RobotMqttSpeechLink` does for the speaking floor. The default
/// [NoopRobotMotionLink] behaves as if the robot is always stopped and in
/// position, so the synchronizer runs and is testable with no robot present.
abstract class RobotMotionLink {
  /// Whether the robot is currently moving. Narration must not play while true.
  bool get isMoving;

  /// Whether the visitor has reached a comfortable viewing position at the
  /// current exhibit. Narration should begin only once this is true.
  bool get isInViewingPosition;

  /// Whether the robot link is currently connected. When false, motion/position
  /// signals are stale and the synchronizer holds narration.
  bool get isConnected;

  /// Notifies when the robot's motion state flips (started / stopped moving).
  set onMotionChanged(void Function(bool moving)? handler);

  /// Notifies when the visitor's viewing-position readiness flips.
  set onViewingPositionChanged(void Function(bool inPosition)? handler);

  /// Notifies when the robot link's connection state flips.
  set onConnectionChanged(void Function(bool connected)? handler);
}

/// No robot present: always stopped, always in position, always connected — so
/// the synchronizer narrates immediately and the whole layer is testable with no
/// robot dependency (mirrors `NoopRobotSpeechLink`).
class NoopRobotMotionLink implements RobotMotionLink {
  @override
  bool get isMoving => false;

  @override
  bool get isInViewingPosition => true;

  @override
  bool get isConnected => true;

  @override
  set onMotionChanged(void Function(bool moving)? handler) {}

  @override
  set onViewingPositionChanged(void Function(bool inPosition)? handler) {}

  @override
  set onConnectionChanged(void Function(bool connected)? handler) {}
}
