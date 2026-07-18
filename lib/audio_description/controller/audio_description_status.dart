/// The lifecycle of a single narration run, published by
/// [AudioDescriptionController]. A run moves idle → loading → generating →
/// speaking → completed, or lands on failed / cancelled at any stage.
enum AudioDescriptionStatus {
  /// Nothing in progress (initial state).
  idle('idle'),

  /// Fetching exhibit metadata from the repository.
  loading('loading'),

  /// Building the prompt and generating narration through the AI.
  generating('generating'),

  /// Handing the narration to the voice engine.
  speaking('speaking'),

  /// Narration was generated and dispatched to voice successfully.
  completed('completed'),

  /// A stage failed; see [AudioDescriptionFailureStage] + diagnostics.
  failed('failed'),

  /// The run was cancelled before completing.
  cancelled('cancelled');

  const AudioDescriptionStatus(this.storageKey);

  final String storageKey;

  bool get isTerminal =>
      this == completed || this == failed || this == cancelled;
}

/// Which pipeline stage produced a failure, so a caller (Task 13 fallback, UI)
/// can react specifically without parsing diagnostics text.
enum AudioDescriptionFailureStage {
  /// The data source was unreachable (repository / source unavailable).
  repository('repository'),

  /// The exhibit genuinely does not exist.
  invalidExhibit('invalid_exhibit'),

  /// Narration generation failed (timeout, AI error, malformed/empty).
  generation('generation'),

  /// The voice engine rejected / failed to accept the narration.
  voice('voice');

  const AudioDescriptionFailureStage(this.storageKey);

  final String storageKey;
}
