/// The vocabulary of visitor interactions the audio-description layer supports
/// *during* a narration (Phase 4, Task 8). These are storytelling interactions,
/// distinct from the low-level speech commands parsed by `VoiceCommandParser` —
/// this layer routes an already-decided intent to the existing narration,
/// context, and voice components; it never re-parses utterances.
///
/// Pure data (a stable [storageKey] per value, forward-compatible `fromStorage`),
/// mirroring the Phase 2/3 enum conventions.
enum AudioDescriptionInteraction {
  /// Replay the most recent narration for the current exhibit.
  repeat('repeat'),

  /// Ask for the fullest telling of the current exhibit.
  tellMeMore('tell_me_more'),

  /// Ask a natural follow-up question about the current exhibit.
  askFollowUp('ask_follow_up'),

  /// Stop the current narration and move on to the next exhibit.
  skip('skip'),

  /// Save / bookmark the current exhibit (persistence handled by a higher layer).
  bookmark('bookmark'),

  /// Step the narration toward more detail.
  increaseDetail('increase_detail'),

  /// Step the narration toward less detail.
  decreaseDetail('decrease_detail');

  const AudioDescriptionInteraction(this.storageKey);

  final String storageKey;

  static AudioDescriptionInteraction? fromStorage(Object? value) {
    for (final i in AudioDescriptionInteraction.values) {
      if (i.storageKey == value?.toString()) return i;
    }
    return null;
  }

  /// Interactions that re-run the narration pipeline (and therefore produce an
  /// [AudioDescriptionState] to fold into the result).
  bool get reNarrates =>
      this == repeat ||
      this == tellMeMore ||
      this == increaseDetail ||
      this == decreaseDetail;
}

/// The outcome of handling one [AudioDescriptionInteraction]. Every interaction
/// resolves to exactly one of these; the interaction layer never throws.
enum AudioDescriptionInteractionStatus {
  /// A re-narration interaction (repeat / tell-me-more / detail change) produced
  /// a fresh, successfully spoken narration.
  narrationUpdated('narration_updated'),

  /// A follow-up question was forwarded to the AI path and an answer returned.
  answered('answered'),

  /// The bookmark handler was invoked for the current exhibit.
  bookmarked('bookmarked'),

  /// The current narration was stopped; the higher layer should advance the tour.
  skipped('skipped'),

  /// There is no exhibit in context to act on.
  noActiveExhibit('no_active_exhibit'),

  /// The requested command is not one this layer handles.
  unsupported('unsupported'),

  /// An orchestrated component failed (narration pipeline, AI path, bookmark).
  failed('failed');

  const AudioDescriptionInteractionStatus(this.storageKey);

  final String storageKey;

  /// Whether the interaction was carried out as intended.
  bool get isSuccess =>
      this == narrationUpdated ||
      this == answered ||
      this == bookmarked ||
      this == skipped;
}
