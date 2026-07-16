import 'dart:async';

import '../../services/robot_mqtt_service.dart';
import '../services/robot_speech_coordinator.dart';

/// Production [RobotSpeechLink] that observes the physical robot's speaking
/// state from the existing [RobotMqttService] so the mobile app and the robot
/// never speak simultaneously.
///
/// This is exactly the concrete wiring the [RobotSpeechCoordinator] was designed
/// to receive (Phase 1/2 left robot integration as a "seam ready" drop-in): the
/// coordinator owns the *policy* — essential app speech silences the robot,
/// non-essential app speech waits for it — while this link owns the
/// *observation*, mapping the robot's existing status/event broadcast streams to
/// a single `robotIsSpeaking` signal and notifying on every transition.
///
/// It is deliberately **observation-only**: it subscribes to broadcast streams
/// that already exist and never publishes anything, so no MQTT command traffic,
/// robot navigation logic, or connection behavior changes. If the robot never
/// reports a speaking state, the link simply stays quiet and the engine behaves
/// exactly as it did with the no-op link — a safe, zero-regression bridge.
class RobotMqttSpeechLink implements RobotSpeechLink {
  RobotMqttSpeechLink(this._robot) {
    // Broadcast streams: adding a listener is pure observation and never
    // triggers a connect or publish, so existing robot behavior is preserved.
    _statusSub = _robot.statusUpdates.listen(_onStatus);
    _eventSub = _robot.events.listen((event) => _onEventType(event.type));
  }

  final RobotMqttService _robot;

  StreamSubscription<Map<String, dynamic>>? _statusSub;
  StreamSubscription<Object?>? _eventSub;

  bool _speaking = false;
  void Function(bool speaking)? _onSpeakingChanged;

  @override
  bool get robotIsSpeaking => _speaking;

  @override
  set onRobotSpeakingChanged(void Function(bool speaking)? handler) =>
      _onSpeakingChanged = handler;

  // Observation-only: we never ask the robot to fall silent over MQTT, as that
  // would be new outbound command traffic (out of scope, and would change MQTT
  // behavior). Non-essential app speech still yields to the robot through the
  // coordinator; these are intentional, documented no-ops.
  @override
  Future<void> requestRobotSilence() async {}

  @override
  Future<void> releaseRobotSilence() async {}

  /// Derive the speaking flag from a robot status snapshot. Tolerant parse: the
  /// state may arrive under any of a few conventional keys, and anything we do
  /// not recognize leaves the current state untouched (safe degradation, the
  /// same ethos as the rest of the module's `fromStorage` parsing).
  void _onStatus(Map<String, dynamic> status) {
    final raw = (status['robotState'] ??
            status['robot_state'] ??
            status['state'] ??
            status['activity'])
        ?.toString()
        .toLowerCase();
    if (raw == null) return;
    if (raw == 'speaking' || raw == 'explaining' || raw == 'narrating') {
      _set(true);
    } else if (raw == 'idle' ||
        raw == 'waiting' ||
        raw == 'ready' ||
        raw == 'moving' ||
        raw == 'done' ||
        raw == 'paused') {
      _set(false);
    }
  }

  /// Derive the speaking flag from a discrete robot event type.
  void _onEventType(String type) {
    final t = type.toLowerCase();
    if (t.isEmpty) return;
    if (t.contains('speech_start') ||
        t.contains('speaking_start') ||
        t.contains('narration_start') ||
        t == 'speaking') {
      _set(true);
    } else if (t.contains('speech_end') ||
        t.contains('speaking_end') ||
        t.contains('narration_end') ||
        t == 'idle') {
      _set(false);
    }
  }

  void _set(bool speaking) {
    if (_speaking == speaking) return;
    _speaking = speaking;
    _onSpeakingChanged?.call(speaking);
  }

  /// Cancel the observation subscriptions. Safe to call more than once.
  Future<void> dispose() async {
    await _statusSub?.cancel();
    await _eventSub?.cancel();
    _statusSub = null;
    _eventSub = null;
  }
}
