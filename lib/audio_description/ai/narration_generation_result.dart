/// Where a narration's text came from. The generator itself only ever produces
/// [ai] (a real AI completion) or [none] (generation failed and produced
/// nothing); it deliberately does NOT fabricate fallback text — Task 7 owns the
/// fallback decision, so [fallback] exists only so a higher layer can label a
/// result it substituted.
enum NarrationSource {
  ai('ai'),
  fallback('fallback'),
  none('none');

  const NarrationSource(this.storageKey);

  final String storageKey;
}

/// The outcome of a narration generation attempt. Every failure mode is a
/// distinct value so Task 7 can decide how to fall back (retry, use a cached
/// description, speak a generic line) instead of guessing from an exception.
enum NarrationGenerationStatus {
  /// Usable narration text was produced.
  success('success'),

  /// The AI backend did not respond within the allotted time.
  timeout('timeout'),

  /// The AI backend errored (network / backend fault / unexpected exception).
  aiFailure('ai_failure'),

  /// The backend responded, but with empty / whitespace-only text.
  emptyResponse('empty_response'),

  /// The backend responded with text that could not be interpreted as a valid
  /// narration (signalled by the completion throwing a [FormatException]).
  malformedResponse('malformed_response'),

  /// The request was cancelled before completing (e.g. the visitor skipped on).
  cancelled('cancelled');

  const NarrationGenerationStatus(this.storageKey);

  final String storageKey;

  bool get isSuccess => this == NarrationGenerationStatus.success;
}

/// The structured result of a narration generation attempt. A generation NEVER
/// throws to the UI — success or failure, it resolves to one of these so the
/// caller (Task 7) can react deterministically.
///
/// Pure value object: no AI/network/Firebase/UI imports.
class NarrationGenerationResult {
  final NarrationGenerationStatus status;

  /// The generated narration text on [NarrationGenerationStatus.success];
  /// null otherwise.
  final String? narration;

  final NarrationSource source;

  /// Whether this narration was substituted by a fallback path (always false
  /// from the AI generator itself; a higher layer may set it when it swaps in
  /// fallback content).
  final bool fallbackUsed;

  /// How long the attempt took, when measured.
  final Duration? duration;

  /// Optional human-readable diagnostics (error type/message, timeout budget)
  /// for logging — never surfaced verbatim to visitors.
  final String? diagnostics;

  const NarrationGenerationResult({
    required this.status,
    this.narration,
    this.source = NarrationSource.none,
    this.fallbackUsed = false,
    this.duration,
    this.diagnostics,
  });

  factory NarrationGenerationResult.success(
    String narration, {
    Duration? duration,
  }) =>
      NarrationGenerationResult(
        status: NarrationGenerationStatus.success,
        narration: narration,
        source: NarrationSource.ai,
        duration: duration,
      );

  factory NarrationGenerationResult.failure(
    NarrationGenerationStatus status, {
    Duration? duration,
    String? diagnostics,
  }) =>
      NarrationGenerationResult(
        status: status,
        source: NarrationSource.none,
        duration: duration,
        diagnostics: diagnostics,
      );

  bool get isSuccess => status.isSuccess && (narration?.isNotEmpty ?? false);

  NarrationGenerationResult copyWith({
    NarrationGenerationStatus? status,
    String? narration,
    NarrationSource? source,
    bool? fallbackUsed,
    Duration? duration,
    String? diagnostics,
  }) =>
      NarrationGenerationResult(
        status: status ?? this.status,
        narration: narration ?? this.narration,
        source: source ?? this.source,
        fallbackUsed: fallbackUsed ?? this.fallbackUsed,
        duration: duration ?? this.duration,
        diagnostics: diagnostics ?? this.diagnostics,
      );

  @override
  String toString() =>
      'NarrationGenerationResult(${status.storageKey}, ${source.storageKey}'
      '${fallbackUsed ? ', fallback' : ''}'
      '${diagnostics != null ? ', "$diagnostics"' : ''})';
}
