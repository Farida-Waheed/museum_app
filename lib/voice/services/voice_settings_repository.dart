import 'package:museum_app/accessibility/accessibility.dart';

import '../constants/voice_constants.dart';
import '../enums/voice_enums.dart';
import '../models/speech_config.dart';

/// Session/runtime voice overrides the visitor sets by voice command or the
/// controls bar (louder, slower, mute, gender). These layer ON TOP of the
/// profile-derived config so accessibility settings drive the baseline and the
/// visitor can still nudge it live. Persisted separately from the profile so the
/// accessibility schema is untouched (spec continuity: "extend, never replace").
class VoicePreferences {
  final bool muted;
  final double volume;
  final double rateBias; // added to the profile rate, clamped on resolve
  final VoiceGender gender;

  /// null = follow the profile's auto-speak; true/false = explicit override.
  final bool? autoSpeakOverride;

  const VoicePreferences({
    this.muted = false,
    this.volume = VoiceConstants.defaultVolume,
    this.rateBias = 0.0,
    this.gender = VoiceGender.system,
    this.autoSpeakOverride,
  });

  static const VoicePreferences defaults = VoicePreferences();

  VoicePreferences copyWith({
    bool? muted,
    double? volume,
    double? rateBias,
    VoiceGender? gender,
    bool? autoSpeakOverride,
    bool clearAutoSpeakOverride = false,
  }) =>
      VoicePreferences(
        muted: muted ?? this.muted,
        volume: (volume ?? this.volume)
            .clamp(VoiceConstants.minVolume, VoiceConstants.maxVolume)
            .toDouble(),
        rateBias: rateBias ?? this.rateBias,
        gender: gender ?? this.gender,
        autoSpeakOverride: clearAutoSpeakOverride
            ? null
            : (autoSpeakOverride ?? this.autoSpeakOverride),
      );

  Map<String, dynamic> toMap() => {
        VoiceConstants.kMuted: muted,
        VoiceConstants.kVolume: volume,
        'rate_bias': rateBias,
        VoiceConstants.kGender: gender.storageKey,
        VoiceConstants.kAutoSpeak: autoSpeakOverride,
      };

  factory VoicePreferences.fromMap(Map<String, dynamic> map) => VoicePreferences(
        muted: map[VoiceConstants.kMuted] == true,
        volume: _asDouble(map[VoiceConstants.kVolume], VoiceConstants.defaultVolume),
        rateBias: _asDouble(map['rate_bias'], 0.0),
        gender: VoiceGender.fromStorage(map[VoiceConstants.kGender]),
        autoSpeakOverride: map[VoiceConstants.kAutoSpeak] is bool
            ? map[VoiceConstants.kAutoSpeak] as bool
            : null,
      );

  static double _asDouble(Object? v, double fallback) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? fallback;
  }

  @override
  bool operator ==(Object other) =>
      other is VoicePreferences &&
      other.muted == muted &&
      (other.volume - volume).abs() < 0.0001 &&
      (other.rateBias - rateBias).abs() < 0.0001 &&
      other.gender == gender &&
      other.autoSpeakOverride == autoSpeakOverride;

  @override
  int get hashCode =>
      Object.hash(muted, volume, rateBias, gender, autoSpeakOverride);
}

/// Durable store for [VoicePreferences]. Abstracted (DIP) so tests use an
/// in-memory store and production uses SharedPreferences — the repository never
/// imports a storage plugin directly.
abstract class VoicePreferencesStore {
  Future<Map<String, dynamic>?> load();
  Future<void> save(Map<String, dynamic> data);
}

/// Test/guest store — keeps preferences in memory only.
class InMemoryVoicePreferencesStore implements VoicePreferencesStore {
  Map<String, dynamic>? _data;

  @override
  Future<Map<String, dynamic>?> load() async => _data;

  @override
  Future<void> save(Map<String, dynamic> data) async => _data = data;
}

/// Derives the effective [SpeechConfig] by combining:
/// 1. the visitor's [AccessibilityProfile] (the accessibility baseline), and
/// 2. their live [VoicePreferences] (session nudges + persisted mute/gender).
///
/// The profile→config mapping is a pure, exhaustively-tested function; this is
/// how "accessibility preferences automatically control voice behavior" is
/// realised. Persistence is delegated to a [VoicePreferencesStore].
class VoiceSettingsRepository {
  VoiceSettingsRepository({VoicePreferencesStore? store})
      : _store = store ?? InMemoryVoicePreferencesStore();

  final VoicePreferencesStore _store;
  VoicePreferences _prefs = VoicePreferences.defaults;

  VoicePreferences get preferences => _prefs;

  Future<VoicePreferences> load() async {
    try {
      final data = await _store.load();
      if (data != null) _prefs = VoicePreferences.fromMap(data);
    } catch (_) {
      _prefs = VoicePreferences.defaults; // corrupt cache → safe defaults
    }
    return _prefs;
  }

  Future<void> update(VoicePreferences prefs) async {
    _prefs = prefs;
    try {
      await _store.save(prefs.toMap());
    } catch (_) {
      // Best-effort; an offline/failed write keeps the in-memory value.
    }
  }

  /// Pure mapping from an accessibility profile to the baseline speech config
  /// (before session overrides). Static so it can be unit-tested in isolation.
  static SpeechConfig deriveFromProfile(
    AccessibilityProfile profile, {
    required VoiceLanguage language,
  }) {
    final voice = profile.voice;
    final tour = profile.tour;

    final enabled = voice.voiceGuidanceEnabled ||
        voice.screenReaderFirst ||
        voice.audioDescriptionEnabled;

    // Screen-reader-first visitors expect everything spoken automatically.
    final autoSpeak = voice.screenReaderFirst || voice.voiceGuidanceEnabled;

    // Cognitive assistance (simple language) always wins → concise; otherwise a
    // screen-reader-first / audio-description visitor wants richer speech.
    final simple = tour.explanationLevel.prefersSimpleLanguage;
    final richPreferred = voice.screenReaderFirst ||
        voice.audioDescriptionEnabled ||
        tour.explanationLevel == ExplanationLevel.detailed;

    final navVerbosity = simple
        ? VoiceVerbosity.concise
        : (voice.screenReaderFirst
            ? VoiceVerbosity.detailed
            : VoiceVerbosity.standard);

    final explanationVerbosity = simple
        ? VoiceVerbosity.concise
        : (richPreferred ? VoiceVerbosity.detailed : VoiceVerbosity.standard);

    return SpeechConfig(
      enabled: enabled,
      autoSpeak: autoSpeak,
      rate: voice.speechRate.multiplier,
      pitch: VoiceConstants.defaultPitch,
      volume: VoiceConstants.defaultVolume,
      gender: VoiceGender.system,
      language: language,
      navigationVerbosity: navVerbosity,
      explanationVerbosity: explanationVerbosity,
    );
  }

  /// The final config the engine uses: profile baseline + session overrides.
  static SpeechConfig resolve(
    AccessibilityProfile profile,
    VoicePreferences prefs, {
    required VoiceLanguage language,
  }) {
    final base = deriveFromProfile(profile, language: language);
    return base.copyWith(
      autoSpeak: prefs.autoSpeakOverride ?? base.autoSpeak,
      rate: base.rate + prefs.rateBias,
      volume: prefs.volume,
      gender: prefs.gender == VoiceGender.system ? base.gender : prefs.gender,
    );
  }
}
