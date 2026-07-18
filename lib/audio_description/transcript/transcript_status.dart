/// The lifecycle of the live narration transcript, published by
/// `TranscriptController`. A transcript moves:
///
///   idle → active → completed
///
/// and may divert to [paused] (and back to [active]) or to [cancelled]. Starting
/// a new exhibit resets to a fresh transcript.
///
/// Pure data (a stable [storageKey] per value, forward-compatible `fromStorage`),
/// mirroring the Phase 2/3/4 enum conventions.
enum TranscriptStatus {
  /// No transcript is being tracked (initial, empty narration, or after reset).
  idle('idle'),

  /// A segment is currently being spoken; progress advances through the segments.
  active('active'),

  /// Narration is paused; the active segment is held until resumed.
  paused('paused'),

  /// Every segment has been spoken.
  completed('completed'),

  /// The transcript was abandoned (visitor skipped / moved on).
  cancelled('cancelled');

  const TranscriptStatus(this.storageKey);

  final String storageKey;

  static TranscriptStatus fromStorage(Object? value) {
    for (final s in TranscriptStatus.values) {
      if (s.storageKey == value?.toString()) return s;
    }
    return TranscriptStatus.idle;
  }

  /// Terminal states never transition again without a fresh [begin]/reset.
  bool get isTerminal =>
      this == TranscriptStatus.completed || this == TranscriptStatus.cancelled;

  /// Whether progress may advance in this state.
  bool get isProgressing => this == TranscriptStatus.active;
}
