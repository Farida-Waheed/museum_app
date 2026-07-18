/// Semantic vocabulary for the Audio Description & Adaptive Storytelling system
/// (Phase 4).
///
/// Like the accessibility and voice enums, these describe *storytelling intent*
/// — never widgets, plugins, or AI backends — so a narration concept is defined
/// once and understood everywhere (the description engine, the AI prompt builder,
/// the transcript view, and the future website dashboard).
///
/// Rules (identical to the Phase 2/3 modules, for spec continuity):
/// * A stable [storageKey] string is what gets persisted / sent on the wire
///   (never the Dart index), so reordering can never corrupt a cache entry.
/// * A null-safe, forward-compatible `fromStorage` degrades unknown values to
///   the safest default instead of throwing.
/// * Zero Flutter / plugin / AI imports — pure data, unit-testable.
library;

/// How long a narration should run. The engine and AI prompt builder use this to
/// bound generation; the visitor's profile and preferences pick a default, and a
/// live "tell me more" / "keep it short" request can nudge it — the visitor never
/// edits a raw duration.
enum NarrationLength {
  /// A brief overview — roughly 30–45 seconds spoken.
  short('short'),

  /// The default guided experience — roughly 1–2 minutes spoken.
  standard('standard'),

  /// A rich, in-depth telling — roughly 3–5 minutes spoken.
  detailed('detailed');

  const NarrationLength(this.storageKey);

  final String storageKey;

  static NarrationLength fromStorage(Object? value) {
    for (final l in NarrationLength.values) {
      if (l.storageKey == value?.toString()) return l;
    }
    return NarrationLength.standard;
  }

  bool get isShort => this == NarrationLength.short;
  bool get isDetailed => this == NarrationLength.detailed;
}

/// The four layers every exhibit narration is built from (per the Phase 4 spec).
/// Each exhibit description carries text for these layers; the engine composes
/// the ones a given visitor's profile calls for, in this order, into a single
/// spoken piece. Ordering (by index) is meaningful — it is the natural telling
/// order, so keep [visual] first and [accessibility] last.
enum StoryLayer {
  /// Layer 1 — physical appearance: shape, size, colours, materials, texture,
  /// position, decorative detail.
  visual('visual'),

  /// Layer 2 — historical context: who created it, when, why, its significance
  /// and cultural importance.
  historical('historical'),

  /// Layer 3 — an engaging story or interesting fact that brings the artifact
  /// to life, rather than a dry catalogue entry.
  story('story'),

  /// Layer 4 — accessibility enhancement: information normally obtained visually
  /// (facial expressions, clothing, symbols, carvings, relative size,
  /// orientation), spoken so a visitor who cannot see it misses nothing.
  accessibility('accessibility');

  const StoryLayer(this.storageKey);

  final String storageKey;

  static StoryLayer fromStorage(Object? value) {
    for (final l in StoryLayer.values) {
      if (l.storageKey == value?.toString()) return l;
    }
    return StoryLayer.visual;
  }
}

/// Who Horus is telling the story to. This is the one storytelling input that
/// the [AccessibilityProfile] does NOT already capture (it models needs, not age
/// or scholarly intent), so it lives in the visitor's narration preferences and
/// is layered on top of the profile — never duplicating an accessibility flag.
/// The visitor never switches this mid-tour manually; a setup choice or a future
/// engagement signal sets it, and the narration policy adapts automatically.
enum VisitorAudience {
  /// A general adult visitor — the default, balanced telling.
  general('general'),

  /// A child — engaging stories, comparisons, and interactive questions.
  child('child'),

  /// A student — the standard telling plus educational detail.
  student('student'),

  /// A researcher — maximum historical depth and archaeological detail.
  researcher('researcher');

  const VisitorAudience(this.storageKey);

  final String storageKey;

  static VisitorAudience fromStorage(Object? value) {
    for (final a in VisitorAudience.values) {
      if (a.storageKey == value?.toString()) return a;
    }
    return VisitorAudience.general;
  }

  bool get isChild => this == VisitorAudience.child;
  bool get isResearcher => this == VisitorAudience.researcher;
}

/// How much educational / scholarly depth a narration should carry. Distinct
/// from [NarrationLength] (how long) and from detail level (how simple the
/// language is): this is about how academic the *content* leans, derived from
/// the visitor audience. Ordering (by index) increases with depth.
enum EducationalDepth {
  /// Casual, accessible framing — general visitors and children.
  casual('casual'),

  /// Adds learning-oriented detail — students.
  educational('educational'),

  /// Full scholarly / archaeological depth — researchers.
  academic('academic');

  const EducationalDepth(this.storageKey);

  final String storageKey;

  static EducationalDepth fromStorage(Object? value) {
    for (final d in EducationalDepth.values) {
      if (d.storageKey == value?.toString()) return d;
    }
    return EducationalDepth.casual;
  }
}
