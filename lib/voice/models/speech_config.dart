import '../constants/voice_constants.dart';
import '../enums/voice_enums.dart';

/// The fully-resolved set of parameters the TTS backend needs to speak, derived
/// once from the [AccessibilityProfile] by `VoiceSettingsRepository` and carried
/// on every [VoiceMessage].
///
/// It is a pure, immutable value object (no Flutter/plugin imports) so the
/// mapping from profile → speech parameters can be unit-tested in isolation and
/// reused by a future cloud-TTS or robot-TTS engine unchanged.
class SpeechConfig {
  /// Master switch. When false the coordinator suppresses non-critical speech
  /// entirely (visitor prefers a silent/manual experience). Critical safety
  /// messages may still be spoken.
  final bool enabled;

  /// Speak new content automatically vs. only on an explicit tap/replay.
  final bool autoSpeak;

  /// Speech rate multiplier (see [VoiceConstants.min/maxSpeechRate]).
  final double rate;

  final double pitch;
  final double volume;
  final VoiceGender gender;
  final VoiceLanguage language;

  /// How verbose navigation guidance is.
  final VoiceVerbosity navigationVerbosity;

  /// How verbose exhibit / AI explanations are.
  final VoiceVerbosity explanationVerbosity;

  const SpeechConfig({
    this.enabled = false,
    this.autoSpeak = true,
    this.rate = VoiceConstants.defaultSpeechRate,
    this.pitch = VoiceConstants.defaultPitch,
    this.volume = VoiceConstants.defaultVolume,
    this.gender = VoiceGender.system,
    this.language = VoiceLanguage.english,
    this.navigationVerbosity = VoiceVerbosity.standard,
    this.explanationVerbosity = VoiceVerbosity.standard,
  });

  static const SpeechConfig disabled = SpeechConfig();

  SpeechConfig copyWith({
    bool? enabled,
    bool? autoSpeak,
    double? rate,
    double? pitch,
    double? volume,
    VoiceGender? gender,
    VoiceLanguage? language,
    VoiceVerbosity? navigationVerbosity,
    VoiceVerbosity? explanationVerbosity,
  }) {
    return SpeechConfig(
      enabled: enabled ?? this.enabled,
      autoSpeak: autoSpeak ?? this.autoSpeak,
      rate: _clampRate(rate ?? this.rate),
      pitch: _clampPitch(pitch ?? this.pitch),
      volume: _clampVolume(volume ?? this.volume),
      gender: gender ?? this.gender,
      language: language ?? this.language,
      navigationVerbosity: navigationVerbosity ?? this.navigationVerbosity,
      explanationVerbosity: explanationVerbosity ?? this.explanationVerbosity,
    );
  }

  /// The verbosity that applies to a given priority stream.
  VoiceVerbosity verbosityFor(VoicePriority priority) {
    switch (priority) {
      case VoicePriority.navigation:
        return navigationVerbosity;
      case VoicePriority.content:
      case VoicePriority.ambient:
        return explanationVerbosity;
      case VoicePriority.interactive:
      case VoicePriority.critical:
        return VoiceVerbosity.standard;
    }
  }

  static double _clampRate(double v) =>
      v.clamp(VoiceConstants.minSpeechRate, VoiceConstants.maxSpeechRate)
          .toDouble();
  static double _clampPitch(double v) =>
      v.clamp(VoiceConstants.minPitch, VoiceConstants.maxPitch).toDouble();
  static double _clampVolume(double v) =>
      v.clamp(VoiceConstants.minVolume, VoiceConstants.maxVolume).toDouble();

  Map<String, dynamic> toMap() => {
        VoiceConstants.kEnabled: enabled,
        VoiceConstants.kAutoSpeak: autoSpeak,
        VoiceConstants.kRate: rate,
        VoiceConstants.kPitch: pitch,
        VoiceConstants.kVolume: volume,
        VoiceConstants.kGender: gender.storageKey,
        VoiceConstants.kLanguage: language.code,
        VoiceConstants.kNavVerbosity: navigationVerbosity.storageKey,
        VoiceConstants.kExplanationVerbosity: explanationVerbosity.storageKey,
      };

  factory SpeechConfig.fromMap(Map<String, dynamic> map) => SpeechConfig(
        enabled: map[VoiceConstants.kEnabled] == true,
        autoSpeak: map[VoiceConstants.kAutoSpeak] != false,
        rate: _asDouble(map[VoiceConstants.kRate], VoiceConstants.defaultSpeechRate),
        pitch: _asDouble(map[VoiceConstants.kPitch], VoiceConstants.defaultPitch),
        volume: _asDouble(map[VoiceConstants.kVolume], VoiceConstants.defaultVolume),
        gender: VoiceGender.fromStorage(map[VoiceConstants.kGender]),
        language: VoiceLanguage.fromCode(map[VoiceConstants.kLanguage]),
        navigationVerbosity:
            VoiceVerbosity.fromStorage(map[VoiceConstants.kNavVerbosity]),
        explanationVerbosity:
            VoiceVerbosity.fromStorage(map[VoiceConstants.kExplanationVerbosity]),
      );

  static double _asDouble(Object? value, double fallback) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  @override
  bool operator ==(Object other) =>
      other is SpeechConfig &&
      other.enabled == enabled &&
      other.autoSpeak == autoSpeak &&
      (other.rate - rate).abs() < 0.0001 &&
      (other.pitch - pitch).abs() < 0.0001 &&
      (other.volume - volume).abs() < 0.0001 &&
      other.gender == gender &&
      other.language == language &&
      other.navigationVerbosity == navigationVerbosity &&
      other.explanationVerbosity == explanationVerbosity;

  @override
  int get hashCode => Object.hash(enabled, autoSpeak, rate, pitch, volume,
      gender, language, navigationVerbosity, explanationVerbosity);

  @override
  String toString() =>
      'SpeechConfig(enabled: $enabled, rate: $rate, lang: ${language.code}, '
      'nav: ${navigationVerbosity.storageKey}, exp: ${explanationVerbosity.storageKey})';
}
