import 'audio_description_enums.dart';

/// Session/visitor narration overrides that layer ON TOP of the derived
/// [AccessibilityProfile] baseline — exactly the pattern Phase 3's
/// `VoicePreferences` uses over the profile. The profile drives the accessible
/// baseline (verbosity, auto-speak, detail); these preferences capture the two
/// things the profile does not model — who the story is for ([audience]) and an
/// explicit length choice — plus live "tell me more / keep it short" nudges.
///
/// Persisted separately from the accessibility profile so that schema is
/// untouched ("extend, never replace"). Pure, immutable value object.
class NarrationPreferences {
  /// Who Horus is narrating to. Drives child / student / researcher behaviour.
  final VisitorAudience audience;

  /// An explicit length choice. When null the policy derives length from the
  /// profile; when set (the visitor picked short/standard/detailed, or asked for
  /// "more"), it overrides the derived length.
  final NarrationLength? lengthOverride;

  const NarrationPreferences({
    this.audience = VisitorAudience.general,
    this.lengthOverride,
  });

  static const NarrationPreferences defaults = NarrationPreferences();

  NarrationPreferences copyWith({
    VisitorAudience? audience,
    NarrationLength? lengthOverride,
    bool clearLengthOverride = false,
  }) =>
      NarrationPreferences(
        audience: audience ?? this.audience,
        lengthOverride: clearLengthOverride
            ? null
            : (lengthOverride ?? this.lengthOverride),
      );

  @override
  bool operator ==(Object other) =>
      other is NarrationPreferences &&
      other.audience == audience &&
      other.lengthOverride == lengthOverride;

  @override
  int get hashCode => Object.hash(audience, lengthOverride);

  @override
  String toString() =>
      'NarrationPreferences(${audience.storageKey}, '
      'length: ${lengthOverride?.storageKey ?? 'auto'})';
}
