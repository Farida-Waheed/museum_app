import 'narration_transcript.dart';
import 'transcript_segment.dart';
import 'transcript_status.dart';

/// An immutable snapshot of live transcript progress, published by
/// `TranscriptController` on every change. It pairs the (immutable) transcript
/// with a status and the cursor into its segments. Pure value object — no
/// Flutter / AI / Firebase imports.
class TranscriptState {
  final TranscriptStatus status;

  /// The transcript being tracked, or null when [TranscriptStatus.idle].
  final NarrationTranscript? transcript;

  /// Index of the currently active (spoken) segment, or -1 when none is active
  /// (idle, empty narration, or before the first segment starts).
  final int activeIndex;

  const TranscriptState({
    required this.status,
    this.transcript,
    this.activeIndex = -1,
  });

  static const TranscriptState initial =
      TranscriptState(status: TranscriptStatus.idle);

  /// The currently active segment, or null when none is active / out of range.
  TranscriptSegment? get activeSegment => transcript?.segmentAt(activeIndex);

  /// How many segments have been fully spoken (all before [activeIndex] when
  /// active; all of them once completed).
  int get spokenCount {
    if (transcript == null) return 0;
    if (status == TranscriptStatus.completed) return transcript!.segmentCount;
    return activeIndex < 0 ? 0 : activeIndex;
  }

  /// Total speakable segments in the tracked transcript.
  int get totalCount => transcript?.segmentCount ?? 0;

  /// Fractional progress 0..1 (0 when there is nothing to speak).
  double get progress {
    final total = totalCount;
    if (total == 0) return status == TranscriptStatus.completed ? 1.0 : 0.0;
    if (status == TranscriptStatus.completed) return 1.0;
    final done = activeIndex < 0 ? 0 : activeIndex;
    return done / total;
  }

  bool get isActive => status == TranscriptStatus.active;
  bool get isPaused => status == TranscriptStatus.paused;
  bool get isCompleted => status == TranscriptStatus.completed;
  bool get isCancelled => status == TranscriptStatus.cancelled;

  TranscriptState copyWith({
    TranscriptStatus? status,
    NarrationTranscript? transcript,
    int? activeIndex,
  }) =>
      TranscriptState(
        status: status ?? this.status,
        transcript: transcript ?? this.transcript,
        activeIndex: activeIndex ?? this.activeIndex,
      );

  @override
  String toString() =>
      'TranscriptState(${status.storageKey}, active: $activeIndex/'
      '$totalCount)';
}
