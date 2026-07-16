/// Foundational constants for the Accessibility & Inclusive Experience module.
///
/// Centralised so no magic numbers or storage keys leak into widgets, services,
/// or the robot/AI payloads. Changing a bound or a key here changes it
/// everywhere — a hard requirement for a maintainable commercial deployment.
library;

class AccessibilityConstants {
  const AccessibilityConstants._();

  /// Schema version persisted with every profile. Bump only on an incompatible
  /// field-shape change; [profileMigrations] then upgrades older maps.
  static const int schemaVersion = 1;

  // --- Text scaling bounds (shared by UI slider, theme adapter, clamping) ---
  static const double minTextScale = 0.8;
  static const double maxTextScale = 2.0;
  static const double defaultTextScale = 1.0;
  static const double largeTextScale = 1.3;
  static const double extraLargeTextScale = 1.6;

  // --- Touch target sizing (Material 3 baseline is 48dp) ---
  static const double baseTapTarget = 48;
  static const double comfortableTapTarget = 56;
  static const double largeTapTarget = 64;

  // --- Speech rate bounds for TTS / robot narration (0.5x .. 1.5x) ---
  static const double minSpeechRate = 0.5;
  static const double maxSpeechRate = 1.5;
  static const double defaultSpeechRate = 1.0;

  // --- Tour dwell multipliers (extend/shorten time per exhibit) ---
  static const double relaxedDwellMultiplier = 1.4;
  static const double standardDwellMultiplier = 1.0;
  static const double briskDwellMultiplier = 0.7;

  // --- Persistence keys ---
  /// SharedPreferences blob key (offline cache).
  static const String localCacheKey = 'accessibility_profile_v1';

  /// Field name inside the existing `users/{uid}` document. Already modelled by
  /// AppUser and already whitelisted in firestore.rules — reused, not invented.
  static const String firestoreField = 'accessibility_defaults';

  // --- Top-level storage map keys (kept snake_case, house convention) ---
  static const String kVersion = 'version';
  static const String kCategory = 'category'; // legacy single-select (read-only)
  static const String kCategories = 'categories'; // multi-select (Phase 2+)
  static const String kDisplay = 'display_settings';
  static const String kVoice = 'voice_settings';
  static const String kNavigation = 'navigation_settings';
  static const String kInteraction = 'interaction_settings';
  static const String kEmergency = 'emergency_settings';
  static const String kTour = 'tour_preferences';
  static const String kHasCompletedSetup = 'has_completed_setup';
  static const String kUpdatedAtMs = 'updated_at_ms';
}
