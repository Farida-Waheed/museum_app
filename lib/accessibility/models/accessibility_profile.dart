import '../constants/accessibility_constants.dart';
import '../enums/accessibility_enums.dart';
import '../utils/accessibility_parse.dart';
import 'accessibility_tour_preferences.dart';
import 'display_settings.dart';
import 'emergency_settings.dart';
import 'interaction_settings.dart';
import 'navigation_settings.dart';
import 'voice_settings.dart';

/// The single, authoritative description of a visitor's accessibility needs —
/// the app-wide source of truth. Composed of six cohesive settings groups so
/// the schema is nested and scalable (spec #3) rather than a flat bag of flags.
///
/// It is a pure, immutable value object (no Flutter/Firebase/MQTT imports) so it
/// can be unit-tested in isolation and reused by the future website dashboard.
/// Every subsystem reads it:
/// * Mobile UI  → [display] drives text scale / contrast / motion / targets.
/// * AI         → [toAiDirectives] adapts tone, length, modality.
/// * Robot      → [toRobotPayload] adapts speed, narration, routing.
/// * Tour       → [tour] drives pace and explanation depth.
/// * Firestore  → [toStorageMap] persists inside users/{uid}.accessibility_defaults.
class AccessibilityProfile {
  final int version;

  /// The set of accessibility categories the visitor identifies with. A visitor
  /// may combine needs (e.g. Visual + Wheelchair), so this is a SET, not a
  /// single value (Phase 2 requirement). An empty set means Standard.
  ///
  /// The concrete effect of the categories lives entirely in the six settings
  /// groups below, composed by [AccessibilityProfile.forCategories]; the set is
  /// retained so the setup wizard and profile page can show what was chosen and
  /// let the visitor edit the selection.
  final Set<AccessibilityCategory> categories;

  final DisplaySettings display;
  final VoiceSettings voice;
  final NavigationSettings navigation;
  final InteractionSettings interaction;
  final EmergencySettings emergency;
  final AccessibilityTourPreferences tour;

  /// Whether the visitor has completed the one-time setup (drives the Phase 2
  /// prompt without nagging).
  final bool hasCompletedSetup;

  /// Last local modification time (ms since epoch). Used for last-writer
  /// reconciliation between the offline cache and the cloud copy.
  final int updatedAtMs;

  AccessibilityProfile({
    this.version = AccessibilityConstants.schemaVersion,
    Set<AccessibilityCategory>? categories,
    this.display = DisplaySettings.standard,
    this.voice = VoiceSettings.standard,
    this.navigation = NavigationSettings.standard,
    this.interaction = InteractionSettings.standard,
    this.emergency = EmergencySettings.standard,
    this.tour = AccessibilityTourPreferences.standard,
    this.hasCompletedSetup = false,
    this.updatedAtMs = 0,
  }) : categories = _normalizeCategories(categories);

  /// A neutral profile — the default for a brand-new / guest visitor.
  /// (Non-const because [categories] is a runtime-normalized set.)
  static final AccessibilityProfile initial = AccessibilityProfile();

  /// Drops [AccessibilityCategory.standard] whenever any real need is present,
  /// so "Standard" is never stored alongside another category. An empty result
  /// canonically means the standard experience.
  static Set<AccessibilityCategory> _normalizeCategories(
    Set<AccessibilityCategory>? input,
  ) {
    if (input == null || input.isEmpty) return const {};
    final real =
        input.where((c) => c != AccessibilityCategory.standard).toSet();
    return real; // empty ⇒ standard
  }

  /// The single category most useful for compact UI (badges, greetings). Falls
  /// back to [AccessibilityCategory.standard] when the visitor combined none.
  AccessibilityCategory get primaryCategory =>
      categories.isEmpty ? AccessibilityCategory.standard : categories.first;

  bool hasCategory(AccessibilityCategory c) =>
      c == AccessibilityCategory.standard ? categories.isEmpty
          : categories.contains(c);

  bool get isStandard => categories.isEmpty;

  /// True when the visitor has declared no needs anywhere. Subsystems use this
  /// to skip adaptation payloads entirely for the common case.
  bool get isNeutral =>
      categories.isEmpty &&
      display.isNeutral &&
      voice.isNeutral &&
      navigation.isNeutral &&
      interaction.isNeutral &&
      emergency.isNeutral &&
      tour.isNeutral;

  AccessibilityProfile copyWith({
    Set<AccessibilityCategory>? categories,
    DisplaySettings? display,
    VoiceSettings? voice,
    NavigationSettings? navigation,
    InteractionSettings? interaction,
    EmergencySettings? emergency,
    AccessibilityTourPreferences? tour,
    bool? hasCompletedSetup,
    int? updatedAtMs,
  }) {
    return AccessibilityProfile(
      version: AccessibilityConstants.schemaVersion,
      categories: categories ?? this.categories,
      display: display ?? this.display,
      voice: voice ?? this.voice,
      navigation: navigation ?? this.navigation,
      interaction: interaction ?? this.interaction,
      emergency: emergency ?? this.emergency,
      tour: tour ?? this.tour,
      hasCompletedSetup: hasCompletedSetup ?? this.hasCompletedSetup,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  // ---------------------------------------------------------------------------
  // Category presets: "detect once, configure everything".
  // Selecting categories sets a coherent bundle across all groups in one action
  // so the visitor never tunes many switches individually (UX requirement).
  // Granular settings can still be overridden afterwards.
  // ---------------------------------------------------------------------------

  /// Build a profile for a SINGLE category (kept for convenience / tests).
  factory AccessibilityProfile.forCategory(
    AccessibilityCategory category, {
    bool hasCompletedSetup = true,
  }) =>
      AccessibilityProfile.forCategories({category},
          hasCompletedSetup: hasCompletedSetup);

  /// Build a profile for ANY combination of categories by layering each
  /// category's bundle. Merge order is deterministic and chosen so the SAFEST
  /// accommodation always wins on conflict:
  ///
  /// * booleans OR together (a need enabled by any category stays enabled),
  /// * text scale / tap targets take the LARGER value,
  /// * speech rate takes the SLOWER value,
  /// * pace takes the more RELAXED value (larger dwell multiplier),
  /// * explanation level: cognitive assistance is applied LAST so "simple"
  ///   overrides "detailed" when both Visual and Cognitive are selected —
  ///   comprehension support beats richness.
  factory AccessibilityProfile.forCategories(
    Set<AccessibilityCategory> categories, {
    bool hasCompletedSetup = true,
  }) {
    final normalized = _normalizeCategories(categories);
    if (normalized.isEmpty) {
      return AccessibilityProfile(hasCompletedSetup: hasCompletedSetup);
    }

    // Deterministic layer order; cognitive last so its explanation level wins.
    const order = [
      AccessibilityCategory.wheelchairUser,
      AccessibilityCategory.hearingImpairment,
      AccessibilityCategory.visualImpairment,
      AccessibilityCategory.cognitiveAssistance,
    ];

    var acc = AccessibilityProfile(
      categories: normalized,
      hasCompletedSetup: hasCompletedSetup,
    );
    for (final c in order) {
      if (!normalized.contains(c)) continue;
      acc = acc._mergeBundle(_bundleFor(c));
    }
    return acc;
  }

  /// The raw settings bundle for one category (no category set, no merge).
  static AccessibilityProfile _bundleFor(AccessibilityCategory category) {
    switch (category) {
      case AccessibilityCategory.standard:
        return AccessibilityProfile();

      case AccessibilityCategory.visualImpairment:
        return AccessibilityProfile(
          display: const DisplaySettings(
            textScale: AccessibilityConstants.largeTextScale,
            highContrast: true,
            boldText: true,
            largeTapTargets: true,
          ),
          voice: const VoiceSettings(
            voiceGuidanceEnabled: true,
            audioDescriptionEnabled: true,
            screenReaderFirst: true,
          ),
          navigation: const NavigationSettings(announceDirections: true),
          interaction: const InteractionSettings(
            mode: InteractionMode.largeControls,
            hapticFeedback: true,
          ),
          tour: const AccessibilityTourPreferences(
            explanationLevel: ExplanationLevel.detailed,
          ),
        );

      case AccessibilityCategory.hearingImpairment:
        return AccessibilityProfile(
          interaction: const InteractionSettings(captionsEnabled: true),
        );

      case AccessibilityCategory.wheelchairUser:
        return AccessibilityProfile(
          display: const DisplaySettings(largeTapTargets: true),
          navigation: const NavigationSettings(
            routePreference: RoutePreference.stepFree,
            moreRestPoints: true,
          ),
          tour: const AccessibilityTourPreferences(pace: TourPace.relaxed),
          interaction: const InteractionSettings(extendedTimeouts: true),
        );

      case AccessibilityCategory.cognitiveAssistance:
        return AccessibilityProfile(
          display: const DisplaySettings(reduceMotion: true),
          interaction: const InteractionSettings(
            extendedTimeouts: true,
            confirmActions: true,
          ),
          tour: const AccessibilityTourPreferences(
            pace: TourPace.relaxed,
            explanationLevel: ExplanationLevel.simple,
            autoPauseBetweenStops: true,
            highlightsOnly: true,
          ),
        );
    }
  }

  /// Fold another profile's settings into this one using the safest-wins rules.
  /// Public via [combineWith] for later phases that merge a session override.
  AccessibilityProfile _mergeBundle(AccessibilityProfile other) {
    return copyWith(
      display: DisplaySettings(
        textScale: display.textScale >= other.display.textScale
            ? display.textScale
            : other.display.textScale,
        highContrast: display.highContrast || other.display.highContrast,
        boldText: display.boldText || other.display.boldText,
        reduceMotion: display.reduceMotion || other.display.reduceMotion,
        largeTapTargets:
            display.largeTapTargets || other.display.largeTapTargets,
        colorVision: other.display.colorVision.isActive
            ? other.display.colorVision
            : display.colorVision,
      ),
      voice: VoiceSettings(
        voiceGuidanceEnabled:
            voice.voiceGuidanceEnabled || other.voice.voiceGuidanceEnabled,
        audioDescriptionEnabled: voice.audioDescriptionEnabled ||
            other.voice.audioDescriptionEnabled,
        screenReaderFirst:
            voice.screenReaderFirst || other.voice.screenReaderFirst,
        // Slower speech is the safer accommodation.
        speechRate: voice.speechRate.multiplier <= other.voice.speechRate.multiplier
            ? voice.speechRate
            : other.voice.speechRate,
      ),
      navigation: NavigationSettings(
        routePreference: navigation.routePreference.requiresStepFree ||
                other.navigation.routePreference.requiresStepFree
            ? RoutePreference.stepFree
            : (other.navigation.routePreference != RoutePreference.standard
                ? other.navigation.routePreference
                : navigation.routePreference),
        moreRestPoints:
            navigation.moreRestPoints || other.navigation.moreRestPoints,
        announceDirections: navigation.announceDirections ||
            other.navigation.announceDirections,
        avoidCrowds: navigation.avoidCrowds || other.navigation.avoidCrowds,
      ),
      interaction: InteractionSettings(
        mode: other.interaction.mode != InteractionMode.standardTouch
            ? other.interaction.mode
            : interaction.mode,
        captionsEnabled:
            interaction.captionsEnabled || other.interaction.captionsEnabled,
        hapticFeedback:
            interaction.hapticFeedback || other.interaction.hapticFeedback,
        extendedTimeouts:
            interaction.extendedTimeouts || other.interaction.extendedTimeouts,
        confirmActions:
            interaction.confirmActions || other.interaction.confirmActions,
      ),
      emergency: other.emergency.isNeutral ? emergency : other.emergency,
      tour: AccessibilityTourPreferences(
        // More relaxed pace = larger dwell multiplier wins.
        pace: tour.pace.dwellMultiplier >= other.tour.pace.dwellMultiplier
            ? tour.pace
            : other.tour.pace,
        // Later layer (cognitive) wins explanation level by merge order.
        explanationLevel:
            other.tour.explanationLevel != ExplanationLevel.standard
                ? other.tour.explanationLevel
                : tour.explanationLevel,
        autoPauseBetweenStops: tour.autoPauseBetweenStops ||
            other.tour.autoPauseBetweenStops,
        highlightsOnly: tour.highlightsOnly || other.tour.highlightsOnly,
      ),
    );
  }

  /// Combine this profile with a session/override profile (later phases use this
  /// to layer a temporary tour override on top of the saved profile).
  AccessibilityProfile combineWith(AccessibilityProfile other) => _mergeBundle(
        other,
      ).copyWith(categories: {...categories, ...other.categories});

  // ---------------------------------------------------------------------------
  // Serialization — one nested map shape used for BOTH the SharedPreferences
  // cache (guests + offline) and Firestore (logged-in). One code path, one shape.
  // Writes `categories` (list) AND legacy `category` (primary) so external
  // readers built against Phase 1 keep working.
  // ---------------------------------------------------------------------------
  Map<String, dynamic> toStorageMap() => {
        AccessibilityConstants.kVersion: version,
        AccessibilityConstants.kCategories:
            categories.map((c) => c.storageKey).toList(),
        AccessibilityConstants.kCategory: primaryCategory.storageKey,
        AccessibilityConstants.kDisplay: display.toMap(),
        AccessibilityConstants.kVoice: voice.toMap(),
        AccessibilityConstants.kNavigation: navigation.toMap(),
        AccessibilityConstants.kInteraction: interaction.toMap(),
        AccessibilityConstants.kEmergency: emergency.toMap(),
        AccessibilityConstants.kTour: tour.toMap(),
        AccessibilityConstants.kHasCompletedSetup: hasCompletedSetup,
        AccessibilityConstants.kUpdatedAtMs: updatedAtMs,
      };

  /// Tolerant, forward-compatible parse. Never throws on malformed data; missing
  /// groups fall back to their standard defaults, unknown enums degrade safely.
  /// Reads the multi-select `categories` list when present, else falls back to
  /// the legacy single `category` field (Phase 1 documents).
  factory AccessibilityProfile.fromStorageMap(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) return AccessibilityProfile.initial;
    final map = _migrate(AccessibilityParse.asMap(raw));

    Set<AccessibilityCategory> parsedCategories;
    final rawList = map[AccessibilityConstants.kCategories];
    if (rawList is List) {
      parsedCategories = rawList
          .map((e) => AccessibilityCategory.fromStorage(e))
          .where((c) => c != AccessibilityCategory.standard)
          .toSet();
    } else {
      // Legacy Phase 1 document: single category field.
      final legacy =
          AccessibilityCategory.fromStorage(map[AccessibilityConstants.kCategory]);
      parsedCategories =
          legacy == AccessibilityCategory.standard ? <AccessibilityCategory>{}
              : {legacy};
    }

    return AccessibilityProfile(
      version: AccessibilityConstants.schemaVersion,
      categories: parsedCategories,
      display: DisplaySettings.fromMap(
          AccessibilityParse.asMap(map[AccessibilityConstants.kDisplay])),
      voice: VoiceSettings.fromMap(
          AccessibilityParse.asMap(map[AccessibilityConstants.kVoice])),
      navigation: NavigationSettings.fromMap(
          AccessibilityParse.asMap(map[AccessibilityConstants.kNavigation])),
      interaction: InteractionSettings.fromMap(
          AccessibilityParse.asMap(map[AccessibilityConstants.kInteraction])),
      emergency: EmergencySettings.fromMap(
          AccessibilityParse.asMap(map[AccessibilityConstants.kEmergency])),
      tour: AccessibilityTourPreferences.fromMap(
          AccessibilityParse.asMap(map[AccessibilityConstants.kTour])),
      hasCompletedSetup: AccessibilityParse.asBool(
          map[AccessibilityConstants.kHasCompletedSetup]),
      updatedAtMs:
          AccessibilityParse.asInt(map[AccessibilityConstants.kUpdatedAtMs]),
    );
  }

  /// Schema migration hook. Currently a pass-through (v1 is the first schema);
  /// future incompatible changes add cases keyed on the stored `version`.
  static Map<String, dynamic> _migrate(Map<String, dynamic> map) {
    return map;
  }

  // ---------------------------------------------------------------------------
  // Robot contract (Phase 1 defines it; later phases publish over MQTT).
  // Compact, unambiguous payload for the ROS side.
  // ---------------------------------------------------------------------------
  Map<String, dynamic> toRobotPayload() => {
        'v': version,
        'categories': categories.map((c) => c.storageKey).toList(),
        'category': primaryCategory.storageKey,
        'step_free': navigation.routePreference.requiresStepFree,
        'more_rest_points': navigation.moreRestPoints,
        'announce_directions': navigation.announceDirections,
        'speech_required':
            !interaction.captionsEnabled || voice.voiceGuidanceEnabled,
        'captions_required': interaction.captionsEnabled,
        'narrate_visuals':
            voice.screenReaderFirst || voice.audioDescriptionEnabled,
        'simple_language': tour.explanationLevel.prefersSimpleLanguage,
        'explanation_level': tour.explanationLevel.storageKey,
        'reduce_motion': display.reduceMotion,
        'speech_rate': voice.speechRate.multiplier,
        'dwell_multiplier': tour.pace.dwellMultiplier,
        'interaction_mode': interaction.mode.storageKey,
      };

  // ---------------------------------------------------------------------------
  // AI contract (Phase 1 defines it; Phase 7/12 inject into the system prompt).
  // Localized human-readable directives appended to Horus's system prompt.
  // ---------------------------------------------------------------------------
  String toAiDirectives({String language = 'en'}) {
    final ar = language == 'ar';
    final directives = <String>[];

    if (tour.explanationLevel == ExplanationLevel.simple) {
      directives.add(ar
          ? 'استخدم لغة بسيطة وجملاً قصيرة وواضحة.'
          : 'Use simple language and short, clear sentences.');
    } else if (tour.explanationLevel == ExplanationLevel.detailed) {
      directives.add(ar
          ? 'قدّم شرحاً غنياً ومفصلاً مع سياق تاريخي.'
          : 'Give rich, detailed explanations with historical context.');
    }
    if (voice.screenReaderFirst) {
      directives.add(ar
          ? 'صف العناصر البصرية بالكلمات لأن الزائر لا يعتمد على الشاشة.'
          : 'Describe visual elements in words; the visitor is not relying on the screen.');
    }
    if (interaction.captionsEnabled) {
      directives.add(ar
          ? 'قدّم كل المعلومات كنص واضح؛ لا تعتمد على الصوت وحده.'
          : 'Provide all information as clear text; do not rely on audio alone.');
    }
    if (tour.pace == TourPace.relaxed) {
      directives.add(ar
          ? 'حافظ على وتيرة هادئة وغير مستعجلة.'
          : 'Keep a calm, unhurried pace.');
    }

    if (directives.isEmpty) return '';
    final header = ar
        ? 'إرشادات الوصول للزائر الحالي:'
        : 'Accessibility guidance for the current visitor:';
    return '$header\n- ${directives.join('\n- ')}';
  }

  @override
  bool operator ==(Object other) =>
      other is AccessibilityProfile &&
      other.version == version &&
      _sameCategories(other.categories, categories) &&
      other.display == display &&
      other.voice == voice &&
      other.navigation == navigation &&
      other.interaction == interaction &&
      other.emergency == emergency &&
      other.tour == tour &&
      other.hasCompletedSetup == hasCompletedSetup;

  static bool _sameCategories(
    Set<AccessibilityCategory> a,
    Set<AccessibilityCategory> b,
  ) =>
      a.length == b.length && a.containsAll(b);

  @override
  int get hashCode => Object.hash(
        version,
        // Order-independent category hash.
        Object.hashAllUnordered(categories),
        display,
        voice,
        navigation,
        interaction,
        emergency,
        tour,
        hasCompletedSetup,
      );

  @override
  String toString() =>
      'AccessibilityProfile(categories: $categories, display: $display, '
      'voice: $voice, navigation: $navigation, interaction: $interaction, '
      'tour: $tour)';
}
