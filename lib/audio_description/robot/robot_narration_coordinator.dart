import 'dart:async';

import '../controller/audio_description_controller.dart';
import '../controller/audio_description_state.dart';
import '../controller/audio_description_status.dart';
import '../models/exhibit_id.dart';
import 'robot_motion_link.dart';
import 'robot_narration_state.dart';

/// Coordinates robot movement with exhibit narration so Horus only speaks while
/// the robot is stopped and the visitor is in a comfortable viewing position,
/// and falls silent the moment the robot moves unexpectedly (the Phase-4
/// "Synchronization with Robot" requirement).
///
/// It is ONLY an orchestrator. Every capability is delegated to an existing
/// component:
///   * motion / position / connection are OBSERVED through the injected
///     [RobotMotionLink] seam (this layer implements no navigation, MQTT,
///     localization, obstacle avoidance, or robot control),
///   * narration is produced by the injected [AudioDescriptionController]
///     (no AI, prompt, repository, or policy logic here),
///   * stopping active audio goes through the injected [NarrationVoiceOutput]
///     seam.
///
/// It never throws — every outcome is a published [RobotNarrationState].
class RobotNarrationCoordinator {
  RobotNarrationCoordinator({
    required RobotMotionLink motion,
    required AudioDescriptionController narrationController,
    required NarrationVoiceOutput voice,
  })  : _motion = motion,
        _narration = narrationController,
        _voice = voice {
    _motion.onMotionChanged = _handleMotionChanged;
    _motion.onViewingPositionChanged = _handlePositionChanged;
    _motion.onConnectionChanged = _handleConnectionChanged;
  }

  final RobotMotionLink _motion;
  final AudioDescriptionController _narration;
  final NarrationVoiceOutput _voice;

  RobotNarrationState _state = RobotNarrationState.initial;
  RobotNarrationState get state => _state;

  /// Published on every synchronization state change.
  void Function(RobotNarrationState state)? onStateChanged;

  /// Incremented per exhibit stop so a superseded stop (visitor skipped, next
  /// exhibit reached) cannot publish after a newer stop has begun.
  int _stopToken = 0;

  /// The exhibit currently being synchronized, retained so a resume-after-
  /// movement can re-run the pipeline for the right exhibit.
  ExhibitId? _currentExhibit;

  // ---------------------------------------------------------------------------
  // Public entry points
  // ---------------------------------------------------------------------------

  /// A new exhibit was reached (from the robot detection / tour layer). Begins
  /// the gated sequence: wait for stop → wait for viewing position → narrate.
  /// Never throws.
  Future<RobotNarrationState> onExhibitReached(ExhibitId exhibitId) async {
    final token = ++_stopToken;
    _currentExhibit = exhibitId;
  

    if (!_motion.isConnected) {
      return _publish(RobotNarrationState(
        status: RobotNarrationStatus.disconnected,
        exhibitId: exhibitId,
        diagnostics: 'Robot link disconnected on exhibit reached',
      ));
    }

    // 1. Wait until the robot reports it has stopped.
    if (_motion.isMoving) {
      return _publish(RobotNarrationState(
        status: RobotNarrationStatus.waitingForStop,
        exhibitId: exhibitId,
      ));
    }

    // 2. Verify the visitor is in the viewing position.
    if (!_motion.isInViewingPosition) {
      return _publish(RobotNarrationState(
        status: RobotNarrationStatus.waitingForPosition,
        exhibitId: exhibitId,
      ));
    }

    // 3. Conditions already met — narrate now.
    return _beginNarration(token, exhibitId);
  }

  /// The visitor skipped this exhibit. Supersede the stop, stop any active
  /// audio through the voice seam, and let the higher layer advance navigation.
  /// Never throws.
  Future<RobotNarrationState> skip() async {
    final exhibitId = _currentExhibit;
    if (_state.status.isTerminal ||
        _state.status == RobotNarrationStatus.idle) {
      return _state;
    }
    _stopToken++; // supersede any in-flight begin/resume
    _narration.cancel();
    await _stopVoiceQuietly();
    return _publish(RobotNarrationState(
      status: RobotNarrationStatus.skipped,
      exhibitId: exhibitId,
    ));
  }

  /// Detach from the motion link's callbacks. Safe to call more than once.
  void dispose() {
    _motion.onMotionChanged = null;
    _motion.onViewingPositionChanged = null;
    _motion.onConnectionChanged = null;
  }

  // ---------------------------------------------------------------------------
  // Robot event handlers (observation → orchestration)
  // ---------------------------------------------------------------------------

  void _handleMotionChanged(bool moving) {
    if (_shouldIgnore()) return;

    if (moving) {
      // Robot started moving unexpectedly. If narration is active, stop it and
      // park in pausedForMovement so it can resume when movement stops.
      if (_state.status == RobotNarrationStatus.narrating) {
        _stopToken++; // supersede the in-flight narration run
        _narration.cancel();
        unawaited(_stopVoiceQuietly());
        _publish(_state.copyWith(status: RobotNarrationStatus.pausedForMovement));
      }
      return;
    }

    // Movement stopped. Resume/begin narration if the stop is still gated on it.
    _tryProceedAfterMotionSettled();
  }

  void _handlePositionChanged(bool inPosition) {
    if (_shouldIgnore()) return;
    if (!inPosition) return; // losing position while waiting: keep waiting
    _tryProceedAfterMotionSettled();
  }

  void _handleConnectionChanged(bool connected) {
    if (_state.status.isTerminal ||
        _state.status == RobotNarrationStatus.idle) {
      return;
    }
    if (!connected) {
      // Link dropped: stop any active audio and hold in disconnected.
      _stopToken++;
      if (_state.status == RobotNarrationStatus.narrating) {
        _narration.cancel();
        unawaited(_stopVoiceQuietly());
      }
      _publish(_state.copyWith(status: RobotNarrationStatus.disconnected));
      return;
    }
    // Reconnected: if we have an exhibit to narrate, re-evaluate the gates.
    _tryProceedAfterMotionSettled();
  }

  // ---------------------------------------------------------------------------
  // Internal orchestration
  // ---------------------------------------------------------------------------

  /// Whether robot events should be ignored (no live stop, or already finished).
  bool _shouldIgnore() =>
      _currentExhibit == null ||
      _state.status.isTerminal ||
      _state.status == RobotNarrationStatus.idle;

  /// After motion settles / position is gained / link returns, advance the stop
  /// if it is currently gated (waitingForStop, waitingForPosition,
  /// pausedForMovement, or disconnected).
  void _tryProceedAfterMotionSettled() {
    final exhibitId = _currentExhibit;
    if (exhibitId == null) return;

    final gated = _state.status == RobotNarrationStatus.waitingForStop ||
        _state.status == RobotNarrationStatus.waitingForPosition ||
        _state.status == RobotNarrationStatus.pausedForMovement ||
        _state.status == RobotNarrationStatus.disconnected;
    if (!gated) return;

    if (!_motion.isConnected) {
      _publish(_state.copyWith(status: RobotNarrationStatus.disconnected));
      return;
    }
    if (_motion.isMoving) {
      _publish(_state.copyWith(status: RobotNarrationStatus.waitingForStop));
      return;
    }
    if (!_motion.isInViewingPosition) {
      _publish(_state.copyWith(status: RobotNarrationStatus.waitingForPosition));
      return;
    }

    // All gates clear — begin (or resume) narration for this stop.
    final token = ++_stopToken;
    unawaited(_beginNarration(token, exhibitId));
  }

  /// Run the narration pipeline for [exhibitId] under [token], mapping its
  /// terminal state onto a [RobotNarrationState]. A run superseded before it
  /// finishes (newer stop / skip / movement / disconnect) does not publish.
  Future<RobotNarrationState> _beginNarration(
    int token,
    ExhibitId exhibitId,
  ) async {
    _publish(RobotNarrationState(
      status: RobotNarrationStatus.narrating,
      exhibitId: exhibitId,
    ));

    final AudioDescriptionState result = await _narration.describe(exhibitId);
    if (token != _stopToken) return _state; // superseded — do not publish

    switch (result.status) {
      case AudioDescriptionStatus.completed:
        return _publish(RobotNarrationState(
          status: RobotNarrationStatus.completed,
          exhibitId: exhibitId,
        ));
      case AudioDescriptionStatus.cancelled:
        // Cancelled by our own supersession path; the superseding branch owns
        // the published state, so leave it.
        return _state;
      case AudioDescriptionStatus.failed:
        return _publish(RobotNarrationState(
          status: RobotNarrationStatus.failed,
          exhibitId: exhibitId,
          diagnostics: 'Narration ${result.status.storageKey}'
              '${result.diagnostics != null ? ': ${result.diagnostics}' : ''}',
        ));
      case AudioDescriptionStatus.idle:
      case AudioDescriptionStatus.loading:
      case AudioDescriptionStatus.generating:
      case AudioDescriptionStatus.speaking:
        // Non-terminal controller state should not occur after an awaited
        // describe(); treat defensively as a failure rather than fake success.
        return _publish(RobotNarrationState(
          status: RobotNarrationStatus.failed,
          exhibitId: exhibitId,
          diagnostics:
              'Narration ended non-terminal: ${result.status.storageKey}',
        ));
    }
  }

  Future<void> _stopVoiceQuietly() async {
    try {
      await _voice.stopNarration();
    } catch (_) {
      // A stop failure has no recovery here — the stop is already superseded.
    }
  }

  RobotNarrationState _publish(RobotNarrationState next) {
    _state = next;
    onStateChanged?.call(next);
    return next;
  }
}
