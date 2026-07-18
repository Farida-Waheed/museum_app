import '../models/exhibit_id.dart';

/// The lifecycle of robot↔narration synchronization for one exhibit stop,
/// published by [RobotNarrationCoordinator]. A stop moves:
///
///   idle → waitingForStop → waitingForPosition → narrating → completed
///
/// and may divert to [pausedForMovement] (robot moved unexpectedly mid-
/// narration, then back to narrating), [skipped], [disconnected], or [failed].
enum RobotNarrationStatus {
  /// Nothing in progress.
  idle('idle'),

  /// An exhibit was reached; waiting for the robot to report it has stopped.
  waitingForStop('waiting_for_stop'),

  /// Robot stopped; waiting for the visitor to reach the viewing position.
  waitingForPosition('waiting_for_position'),

  /// Narration is playing (robot stopped, visitor in position).
  narrating('narrating'),

  /// Narration was paused/stopped because the robot began moving unexpectedly;
  /// it resumes when movement stops.
  pausedForMovement('paused_for_movement'),

  /// The narration for this stop finished successfully.
  completed('completed'),

  /// The visitor skipped; narration stopped and the tour may advance.
  skipped('skipped'),

  /// The robot link disconnected; narration is held until it returns.
  disconnected('disconnected'),

  /// The underlying narration pipeline failed for this stop.
  failed('failed');

  const RobotNarrationStatus(this.storageKey);

  final String storageKey;

  bool get isTerminal =>
      this == completed || this == skipped || this == failed;
}

/// An immutable snapshot of the coordinator's synchronization state for the
/// current exhibit stop, published on every transition. Pure value object — no
/// robot/voice/AI/Firebase/UI imports.
class RobotNarrationState {
  final RobotNarrationStatus status;

  /// The exhibit this stop is for (null only when [RobotNarrationStatus.idle]).
  final ExhibitId? exhibitId;

  /// Human-readable diagnostics for logging (never fabricated narration).
  final String? diagnostics;

  const RobotNarrationState({
    required this.status,
    this.exhibitId,
    this.diagnostics,
  });

  static const RobotNarrationState initial =
      RobotNarrationState(status: RobotNarrationStatus.idle);

  bool get isNarrating => status == RobotNarrationStatus.narrating;
  bool get isCompleted => status == RobotNarrationStatus.completed;
  bool get isPausedForMovement =>
      status == RobotNarrationStatus.pausedForMovement;

  RobotNarrationState copyWith({
    RobotNarrationStatus? status,
    ExhibitId? exhibitId,
    String? diagnostics,
  }) =>
      RobotNarrationState(
        status: status ?? this.status,
        exhibitId: exhibitId ?? this.exhibitId,
        diagnostics: diagnostics ?? this.diagnostics,
      );

  @override
  String toString() =>
      'RobotNarrationState(${status.storageKey}, ${exhibitId ?? 'none'}'
      '${diagnostics != null ? ', "$diagnostics"' : ''})';
}
