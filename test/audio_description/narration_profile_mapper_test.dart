import 'package:flutter_test/flutter_test.dart';
import 'package:museum_app/accessibility/accessibility.dart';
import 'package:museum_app/audio_description/models/audio_description_enums.dart';
import 'package:museum_app/audio_description/models/narration_policy.dart';
import 'package:museum_app/audio_description/models/narration_preferences.dart';
import 'package:museum_app/audio_description/services/narration_profile_mapper.dart';

/// Phase 4 Task 2 — Narration Policy layer.
///
/// Pure-Dart, deterministic mapping tests in the style of the Phase 3
/// `VoiceSettingsRepository` suite. Profiles are built explicitly (not via the
/// Phase 2 category bundles) so the policy is verified in isolation from the
/// accessibility module's own mapping logic.
void main() {
  // Explicit profile builders — independent of forCategory() bundles.
  AccessibilityProfile profile({
    Set<AccessibilityCategory> categories = const {},
    VoiceSettings voice = VoiceSettings.standard,
    AccessibilityTourPreferences tour = AccessibilityTourPreferences.standard,
  }) =>
      AccessibilityProfile(
        categories: categories,
        voice: voice,
        tour: tour,
      );

  NarrationPolicy resolve(
    AccessibilityProfile p, {
    NarrationPreferences prefs = NarrationPreferences.defaults,
  }) =>
      NarrationProfileMapper.resolve(p, preferences: prefs);

  group('supporting enums', () {
    test('VisitorAudience round-trips and degrades to general', () {
      for (final a in VisitorAudience.values) {
        expect(VisitorAudience.fromStorage(a.storageKey), a);
      }
      expect(VisitorAudience.fromStorage('???'), VisitorAudience.general);
      expect(VisitorAudience.fromStorage(null), VisitorAudience.general);
    });

    test('EducationalDepth round-trips and degrades to casual', () {
      for (final d in EducationalDepth.values) {
        expect(EducationalDepth.fromStorage(d.storageKey), d);
      }
      expect(EducationalDepth.fromStorage('x'), EducationalDepth.casual);
    });
  });

  group('NarrationPreferences', () {
    test('copyWith can set and explicitly clear the length override', () {
      const p = NarrationPreferences(
        audience: VisitorAudience.child,
        lengthOverride: NarrationLength.detailed,
      );
      expect(p.copyWith(clearLengthOverride: true).lengthOverride, isNull);
      expect(p.copyWith(clearLengthOverride: true).audience,
          VisitorAudience.child);
      expect(p.copyWith(lengthOverride: NarrationLength.short).lengthOverride,
          NarrationLength.short);
    });

    test('value equality', () {
      expect(const NarrationPreferences(audience: VisitorAudience.student),
          const NarrationPreferences(audience: VisitorAudience.student));
    });
  });

  group('default / standard visitor', () {
    test('neutral profile yields a balanced standard telling', () {
      final policy = resolve(profile());
      expect(policy.length, NarrationLength.standard);
      expect(policy.useSimpleLanguage, isFalse);
      expect(policy.childMode, isFalse);
      expect(policy.researchMode, isFalse);
      expect(policy.emphasizePhysicalDescription, isFalse);
      expect(policy.educationalDepth, EducationalDepth.casual);
      // Standard visitor: no dedicated accessibility layer.
      expect(policy.includesLayer(StoryLayer.accessibility), isFalse);
      expect(policy.includesLayer(StoryLayer.story), isTrue);
      expect(policy.inviteFollowUp, isTrue);
    });

    test('orderedLayers are always in natural telling order', () {
      final policy = resolve(profile());
      final ordered = policy.orderedLayers;
      final indices = ordered.map((l) => l.index).toList();
      final sorted = [...indices]..sort();
      expect(indices, sorted);
    });
  });

  group('visual impairment adaptation', () {
    test('category triggers detailed length + physical emphasis + a11y layer',
        () {
      final policy = resolve(profile(
        categories: {AccessibilityCategory.visualImpairment},
      ));
      expect(policy.length, NarrationLength.detailed);
      expect(policy.emphasizePhysicalDescription, isTrue);
      expect(policy.includesLayer(StoryLayer.accessibility), isTrue);
      expect(policy.includesLayer(StoryLayer.visual), isTrue);
    });

    test('audioDescriptionEnabled alone triggers the same adaptation', () {
      final policy = resolve(profile(
        voice: const VoiceSettings(audioDescriptionEnabled: true),
      ));
      expect(policy.emphasizePhysicalDescription, isTrue);
      expect(policy.includesLayer(StoryLayer.accessibility), isTrue);
      expect(policy.length, NarrationLength.detailed);
    });

    test('screenReaderFirst alone triggers the same adaptation', () {
      final policy = resolve(profile(
        voice: const VoiceSettings(screenReaderFirst: true),
      ));
      expect(policy.emphasizePhysicalDescription, isTrue);
      expect(policy.includesLayer(StoryLayer.accessibility), isTrue);
    });
  });

  group('cognitive assistance adaptation', () {
    test('forces short length, simple language, and a minimal layer set', () {
      final policy = resolve(profile(
        categories: {AccessibilityCategory.cognitiveAssistance},
      ));
      expect(policy.useSimpleLanguage, isTrue);
      expect(policy.length, NarrationLength.short);
      expect(policy.layers, {StoryLayer.visual, StoryLayer.historical});
      expect(policy.includesLayer(StoryLayer.story), isFalse);
      // The extra follow-up question is suppressed to reduce load.
      expect(policy.inviteFollowUp, isFalse);
    });

    test('simple explanation level also counts as cognitive need', () {
      final policy = resolve(profile(
        tour: const AccessibilityTourPreferences(
          explanationLevel: ExplanationLevel.simple,
        ),
      ));
      expect(policy.useSimpleLanguage, isTrue);
      expect(policy.length, NarrationLength.short);
    });

    test('cognitive need wins over a visual need for length (not overwhelmed)',
        () {
      final policy = resolve(profile(
        categories: {
          AccessibilityCategory.cognitiveAssistance,
          AccessibilityCategory.visualImpairment,
        },
      ));
      // Short despite visual impairment, but physical emphasis still on.
      expect(policy.length, NarrationLength.short);
      expect(policy.useSimpleLanguage, isTrue);
      expect(policy.emphasizePhysicalDescription, isTrue);
    });
  });

  group('audience modes', () {
    test('child mode: simple language, standard length, story + follow-up', () {
      final policy = resolve(
        profile(),
        prefs: const NarrationPreferences(audience: VisitorAudience.child),
      );
      expect(policy.childMode, isTrue);
      expect(policy.useSimpleLanguage, isTrue);
      expect(policy.length, NarrationLength.standard);
      expect(policy.educationalDepth, EducationalDepth.casual);
      expect(policy.includesLayer(StoryLayer.story), isTrue);
      expect(policy.inviteFollowUp, isTrue);
    });

    test('student mode: educational depth, standard telling', () {
      final policy = resolve(
        profile(),
        prefs: const NarrationPreferences(audience: VisitorAudience.student),
      );
      expect(policy.educationalDepth, EducationalDepth.educational);
      expect(policy.researchMode, isFalse);
      expect(policy.length, NarrationLength.standard);
    });

    test('researcher mode: academic depth + detailed + full layer set', () {
      final policy = resolve(
        profile(),
        prefs: const NarrationPreferences(audience: VisitorAudience.researcher),
      );
      expect(policy.researchMode, isTrue);
      expect(policy.educationalDepth, EducationalDepth.academic);
      expect(policy.length, NarrationLength.detailed);
      expect(policy.includesLayer(StoryLayer.accessibility), isTrue);
      expect(policy.includesLayer(StoryLayer.story), isTrue);
    });
  });

  group('length override + tour preferences', () {
    test('explicit length override always wins over derived length', () {
      final policy = resolve(
        profile(categories: {AccessibilityCategory.cognitiveAssistance}),
        prefs: const NarrationPreferences(
          lengthOverride: NarrationLength.detailed,
        ),
      );
      // Cognitive would derive short, but the visitor asked for detailed.
      expect(policy.length, NarrationLength.detailed);
      // Other cognitive adaptations remain intact.
      expect(policy.useSimpleLanguage, isTrue);
    });

    test('highlightsOnly implies a short telling', () {
      final policy = resolve(profile(
        tour: const AccessibilityTourPreferences(highlightsOnly: true),
      ));
      expect(policy.length, NarrationLength.short);
    });

    test('detailed explanation level lengthens a standard visitor', () {
      final policy = resolve(profile(
        tour: const AccessibilityTourPreferences(
          explanationLevel: ExplanationLevel.detailed,
        ),
      ));
      expect(policy.length, NarrationLength.detailed);
    });
  });

  group('determinism & value semantics', () {
    test('resolve is a pure function — identical inputs, equal outputs', () {
      final p = profile(
        categories: {AccessibilityCategory.visualImpairment},
        voice: const VoiceSettings(audioDescriptionEnabled: true),
      );
      const prefs = NarrationPreferences(audience: VisitorAudience.researcher);
      final a = resolve(p, prefs: prefs);
      final b = resolve(p, prefs: prefs);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('layer set equality is order-independent', () {
      final a = resolve(profile());
      final b = resolve(profile());
      expect(a.layers, b.layers);
      expect(a, b);
    });
  });
}
