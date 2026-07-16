/// Foundational constants for the Voice Communication Engine (Phase 3).
///
/// Centralised so no magic numbers, storage keys, or cache ids leak into the
/// services, coordinator, or UI — mirroring `AccessibilityConstants`. Changing a
/// bound here changes it everywhere.
library;

class VoiceConstants {
  const VoiceConstants._();

  /// Schema version for any persisted voice data (settings snapshot, cache
  /// manifest). Bump only on an incompatible field-shape change.
  static const int schemaVersion = 1;

  // --- Speech rate bounds (aligned with AccessibilityConstants.min/maxSpeechRate
  //     so the two subsystems never disagree on limits) ---
  static const double minSpeechRate = 0.5;
  static const double maxSpeechRate = 1.5;
  static const double defaultSpeechRate = 1.0;
  static const double speechRateStep = 0.1;

  // --- Pitch bounds (flutter_tts accepts ~0.5 .. 2.0) ---
  static const double minPitch = 0.5;
  static const double maxPitch = 2.0;
  static const double defaultPitch = 1.0;

  // --- Volume bounds (0.0 .. 1.0) ---
  static const double minVolume = 0.0;
  static const double maxVolume = 1.0;
  static const double defaultVolume = 1.0;
  static const double volumeStep = 0.1;

  /// Hard cap on queued messages. Beyond this, the lowest-priority pending items
  /// are dropped so a runaway producer can never exhaust memory (performance +
  /// "avoid overwhelming the visitor").
  static const int maxQueueLength = 32;

  /// Window in which an identical message is treated as a duplicate and skipped
  /// (prevents the same "turn left" firing twice from two producers).
  static const Duration duplicateWindow = Duration(seconds: 4);

  /// How long the recognizer listens for a single command before timing out and
  /// returning control to touch.
  static const Duration listenTimeout = Duration(seconds: 8);

  /// Silence after speech begins before the recognizer auto-stops.
  static const Duration listenPauseTimeout = Duration(seconds: 3);

  /// SharedPreferences key for the durable voice-preferences snapshot.
  static const String localSettingsKey = 'voice_settings_v1';

  /// SharedPreferences key prefix for cached synthesized-phrase metadata.
  static const String cacheManifestKey = 'voice_cache_manifest_v1';

  // --- Storage map keys (snake_case, house convention) ---
  static const String kVersion = 'version';
  static const String kEnabled = 'enabled';
  static const String kAutoSpeak = 'auto_speak';
  static const String kMuted = 'muted';
  static const String kRate = 'rate';
  static const String kPitch = 'pitch';
  static const String kVolume = 'volume';
  static const String kGender = 'gender';
  static const String kLanguage = 'language';
  static const String kNavVerbosity = 'nav_verbosity';
  static const String kExplanationVerbosity = 'explanation_verbosity';
}
