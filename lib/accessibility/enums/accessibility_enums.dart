/// Semantic vocabulary for the Accessibility & Inclusive Experience module.
///
/// Enums describe *needs and preferences*, never widgets. Every subsystem —
/// mobile UI, robot (MQTT), AI assistant, tour engine, notifications, analytics
/// — reads these so the visitor is described once and understood everywhere.
///
/// Rules for every enum here:
/// * A stable [storageKey] string is what gets persisted (never the Dart index),
///   so reordering can never corrupt a saved profile or a robot payload.
/// * A null-safe, forward-compatible `fromStorage` degrades unknown values
///   (written by a newer app version) to the safest default instead of throwing.
/// * Zero Flutter/Firebase/MQTT imports — pure data, unit-testable, and shareable
///   with the future website dashboard.
library;

/// The single headline accessibility category the visitor identifies with.
/// This is the "ONE profile" selector; applying it sets a coherent bundle of
/// settings (see AccessibilityProfile.forCategory). Granular settings can still
/// be fine-tuned afterwards without changing the category.
enum AccessibilityCategory {
  standard('standard'),
  visualImpairment('visual_impairment'),
  hearingImpairment('hearing_impairment'),
  wheelchairUser('wheelchair_user'),
  cognitiveAssistance('cognitive_assistance');

  const AccessibilityCategory(this.storageKey);
  final String storageKey;

  static AccessibilityCategory fromStorage(Object? value) {
    for (final c in AccessibilityCategory.values) {
      if (c.storageKey == value?.toString()) return c;
    }
    return AccessibilityCategory.standard;
  }

  bool get isStandard => this == AccessibilityCategory.standard;
}

/// Narration / speech-synthesis speed for TTS and robot voice.
enum SpeechRate {
  slow('slow', 0.75),
  normal('normal', 1.0),
  fast('fast', 1.25);

  const SpeechRate(this.storageKey, this.multiplier);
  final String storageKey;
  final double multiplier;

  static SpeechRate fromStorage(Object? value) {
    for (final r in SpeechRate.values) {
      if (r.storageKey == value?.toString()) return r;
    }
    return SpeechRate.normal;
  }
}

/// Primary way the visitor prefers to operate the app and robot. Consumed by the
/// Alternative Interaction System (Phase 11); declared here so the foundation is
/// complete.
enum InteractionMode {
  standardTouch('standard_touch'),
  largeControls('large_controls'),
  voice('voice'),
  gesture('gesture'),
  switchControl('switch_control');

  const InteractionMode(this.storageKey);
  final String storageKey;

  static InteractionMode fromStorage(Object? value) {
    for (final m in InteractionMode.values) {
      if (m.storageKey == value?.toString()) return m;
    }
    return InteractionMode.standardTouch;
  }
}

/// How much detail the AI / robot should give per exhibit. Drives adaptive
/// explanation levels (Phase 7).
enum ExplanationLevel {
  simple('simple'),
  standard('standard'),
  detailed('detailed');

  const ExplanationLevel(this.storageKey);
  final String storageKey;

  static ExplanationLevel fromStorage(Object? value) {
    for (final e in ExplanationLevel.values) {
      if (e.storageKey == value?.toString()) return e;
    }
    return ExplanationLevel.standard;
  }

  bool get prefersSimpleLanguage => this == ExplanationLevel.simple;
}

/// Desired tour/interaction pace. Consumed by the Smart Pace Controller
/// (Phase 10) and the robot's dwell time per exhibit.
enum TourPace {
  relaxed('relaxed', 1.4),
  standard('standard', 1.0),
  brisk('brisk', 0.7);

  const TourPace(this.storageKey, this.dwellMultiplier);
  final String storageKey;
  final double dwellMultiplier;

  static TourPace fromStorage(Object? value) {
    for (final p in TourPace.values) {
      if (p.storageKey == value?.toString()) return p;
    }
    return TourPace.standard;
  }
}

/// Preferred route constraint for accessible navigation (Phase 6/9).
enum RoutePreference {
  standard('standard'),
  stepFree('step_free'),
  shortest('shortest');

  const RoutePreference(this.storageKey);
  final String storageKey;

  static RoutePreference fromStorage(Object? value) {
    for (final r in RoutePreference.values) {
      if (r.storageKey == value?.toString()) return r;
    }
    return RoutePreference.standard;
  }

  bool get requiresStepFree => this == RoutePreference.stepFree;
}

/// Color-vision adaptation. Prepared for future color-blind themes (spec #8);
/// no filter is applied in Phase 1 — the value is carried so the theme adapter
/// can enable it later without a schema change.
enum ColorVisionMode {
  none('none'),
  protanopia('protanopia'),
  deuteranopia('deuteranopia'),
  tritanopia('tritanopia'),
  monochrome('monochrome');

  const ColorVisionMode(this.storageKey);
  final String storageKey;

  static ColorVisionMode fromStorage(Object? value) {
    for (final m in ColorVisionMode.values) {
      if (m.storageKey == value?.toString()) return m;
    }
    return ColorVisionMode.none;
  }

  bool get isActive => this != ColorVisionMode.none;
}

/// How the visitor triggers emergency assistance (Phase 8).
enum SosTrigger {
  tapButton('tap_button'),
  voiceCommand('voice_command'),
  shakeDevice('shake_device');

  const SosTrigger(this.storageKey);
  final String storageKey;

  static SosTrigger fromStorage(Object? value) {
    for (final t in SosTrigger.values) {
      if (t.storageKey == value?.toString()) return t;
    }
    return SosTrigger.tapButton;
  }
}
