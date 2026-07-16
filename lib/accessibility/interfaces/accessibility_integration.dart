import '../models/accessibility_profile.dart';

/// Stable integration seams for subsystems that must respect accessibility
/// (spec #10 AI, #11 Robot, #12 Notifications, #18 future features).
///
/// Phase 1 ships these interfaces AND working default implementations wired to
/// the profile's contracts, so later phases plug in by *replacing or extending*
/// a default — never by refactoring the core. Nothing here executes side effects
/// in Phase 1; it only shapes and exposes data.
/// Builds the metadata attached to robot (MQTT) commands so movement, narration,
/// and routing adapt to the visitor. Phase 6/10 consume this when publishing.
abstract class AccessibilityRobotAdapter {
  Map<String, dynamic> buildCommandMetadata(AccessibilityProfile profile);
}

/// Default robot adapter: delegates to the profile's compact robot payload.
class DefaultAccessibilityRobotAdapter implements AccessibilityRobotAdapter {
  const DefaultAccessibilityRobotAdapter();

  @override
  Map<String, dynamic> buildCommandMetadata(AccessibilityProfile profile) =>
      profile.toRobotPayload();
}

/// Builds AI system-prompt directives so Horus adapts tone/length/modality.
/// Phase 7/12 append the result to the assistant's prompt.
abstract class AccessibilityAiAdapter {
  String buildDirectives(AccessibilityProfile profile, {String language});
}

/// Default AI adapter: delegates to the profile's localized directive builder.
class DefaultAccessibilityAiAdapter implements AccessibilityAiAdapter {
  const DefaultAccessibilityAiAdapter();

  @override
  String buildDirectives(AccessibilityProfile profile, {String language = 'en'}) =>
      profile.toAiDirectives(language: language);
}

/// Presentation flags a notification should honour (spec #12). A value object so
/// the existing notification pipeline can read it without depending on the whole
/// profile. Phase 1 prepares it; the notification service consumes it later.
class AccessibilityNotificationStyle {
  final bool announceAloud; // speak via TTS when voice guidance is on
  final bool largeText;
  final bool highContrast;
  final bool reduceMotion;
  final bool useHaptics;

  const AccessibilityNotificationStyle({
    this.announceAloud = false,
    this.largeText = false,
    this.highContrast = false,
    this.reduceMotion = false,
    this.useHaptics = false,
  });

  factory AccessibilityNotificationStyle.fromProfile(
    AccessibilityProfile profile,
  ) {
    return AccessibilityNotificationStyle(
      announceAloud: profile.voice.voiceGuidanceEnabled,
      largeText: profile.display.textScale > 1.0 || profile.display.boldText,
      highContrast: profile.display.highContrast,
      reduceMotion: profile.display.reduceMotion,
      useHaptics: profile.interaction.hapticFeedback,
    );
  }
}

/// Registry of future accessibility features (Voice Navigation, Live Captions,
/// Audio Description, Wheelchair Navigation, Emergency Assistance, Accessible
/// Map, Smart Pace, Gesture Controls, Analytics, AI Assistant) — spec #18.
///
/// Each phase registers its feature with a predicate saying whether it applies
/// to a given profile. This lets navigation, a home "accessibility hub", and
/// analytics discover available features generically, so new phases plug in
/// without editing shared code.
class AccessibilityFeature {
  final String id;
  final bool Function(AccessibilityProfile profile) appliesTo;

  const AccessibilityFeature({required this.id, required this.appliesTo});
}

class AccessibilityFeatureRegistry {
  AccessibilityFeatureRegistry._();
  static final AccessibilityFeatureRegistry instance =
      AccessibilityFeatureRegistry._();

  final Map<String, AccessibilityFeature> _features = {};

  void register(AccessibilityFeature feature) {
    _features[feature.id] = feature;
  }

  bool isRegistered(String id) => _features.containsKey(id);

  /// Features relevant to the given profile — the basis for a dynamic
  /// "accessibility hub" and for analytics on feature exposure.
  List<AccessibilityFeature> availableFor(AccessibilityProfile profile) =>
      _features.values.where((f) => f.appliesTo(profile)).toList();

  /// Canonical feature ids reserved by the roadmap, so phases share one
  /// vocabulary instead of inventing strings.
  static const String voiceNavigation = 'voice_navigation';
  static const String liveCaptions = 'live_captions';
  static const String audioDescription = 'audio_description';
  static const String wheelchairNavigation = 'wheelchair_navigation';
  static const String emergencyAssistance = 'emergency_assistance';
  static const String accessibleMap = 'accessible_map';
  static const String smartPace = 'smart_pace';
  static const String gestureControls = 'gesture_controls';
  static const String accessibilityAnalytics = 'accessibility_analytics';
  static const String aiAssistant = 'ai_accessibility_assistant';
}
