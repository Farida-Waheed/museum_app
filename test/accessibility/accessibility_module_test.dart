import 'package:flutter_test/flutter_test.dart';
import 'package:museum_app/accessibility/accessibility.dart';

void main() {
  group('AccessibilityProfile serialization (nested schema)', () {
    test('round-trips a fully-populated profile without loss', () {
      final original = AccessibilityProfile(
        categories: const {
          AccessibilityCategory.wheelchairUser,
          AccessibilityCategory.visualImpairment,
        },
        display: const DisplaySettings(
          textScale: 1.3,
          highContrast: true,
          boldText: true,
          reduceMotion: true,
          largeTapTargets: true,
          colorVision: ColorVisionMode.deuteranopia,
        ),
        voice: const VoiceSettings(
          voiceGuidanceEnabled: true,
          audioDescriptionEnabled: true,
          screenReaderFirst: true,
          speechRate: SpeechRate.slow,
        ),
        navigation: const NavigationSettings(
          routePreference: RoutePreference.stepFree,
          moreRestPoints: true,
          announceDirections: true,
          avoidCrowds: true,
        ),
        interaction: const InteractionSettings(
          mode: InteractionMode.largeControls,
          captionsEnabled: true,
          hapticFeedback: true,
          extendedTimeouts: true,
          confirmActions: true,
        ),
        emergency: const EmergencySettings(
          sosEnabled: true,
          trigger: SosTrigger.shakeDevice,
          contactName: 'Nour',
          contactPhone: '+20100',
          shareLocation: true,
          medicalNote: 'none',
        ),
        tour: const AccessibilityTourPreferences(
          pace: TourPace.relaxed,
          explanationLevel: ExplanationLevel.detailed,
          autoPauseBetweenStops: true,
          highlightsOnly: true,
        ),
        hasCompletedSetup: true,
      );

      final restored =
          AccessibilityProfile.fromStorageMap(original.toStorageMap());
      expect(restored, equals(original));
    });

    test('null / empty map degrades to the neutral initial profile', () {
      expect(AccessibilityProfile.fromStorageMap(null),
          equals(AccessibilityProfile.initial));
      expect(AccessibilityProfile.fromStorageMap(const {}),
          equals(AccessibilityProfile.initial));
    });

    test('unknown enum values and bad numbers fall back safely', () {
      final p = AccessibilityProfile.fromStorageMap({
        'category': 'from_the_future',
        'display_settings': {'text_scale': 'NaN', 'color_vision': 'xyz'},
        'tour_preferences': {'pace': 'lightspeed'},
      });
      expect(p.primaryCategory, AccessibilityCategory.standard);
      expect(p.isStandard, isTrue);
      expect(p.display.textScale, AccessibilityConstants.defaultTextScale);
      expect(p.display.colorVision, ColorVisionMode.none);
      expect(p.tour.pace, TourPace.standard);
    });

    test('text scale is clamped into the supported range', () {
      expect(const DisplaySettings(textScale: 9).textScale,
          AccessibilityConstants.maxTextScale);
      expect(const DisplaySettings(textScale: 0.1).textScale,
          AccessibilityConstants.minTextScale);
    });
  });

  group('Category presets ("one profile, configure everything")', () {
    test('visualImpairment bundles a coherent cross-group set', () {
      final p =
          AccessibilityProfile.forCategory(AccessibilityCategory.visualImpairment);
      expect(p.display.highContrast, isTrue);
      expect(p.display.largeTapTargets, isTrue);
      expect(p.display.textScale, greaterThan(1.0));
      expect(p.voice.screenReaderFirst, isTrue);
      expect(p.voice.audioDescriptionEnabled, isTrue);
      expect(p.hasCompletedSetup, isTrue);
    });

    test('wheelchairUser forces step-free routing and relaxed pace', () {
      final p =
          AccessibilityProfile.forCategory(AccessibilityCategory.wheelchairUser);
      expect(p.navigation.routePreference, RoutePreference.stepFree);
      expect(p.navigation.routePreference.requiresStepFree, isTrue);
      expect(p.tour.pace, TourPace.relaxed);
    });

    test('cognitiveAssistance simplifies language and slows the tour', () {
      final p = AccessibilityProfile.forCategory(
          AccessibilityCategory.cognitiveAssistance);
      expect(p.tour.explanationLevel, ExplanationLevel.simple);
      expect(p.tour.explanationLevel.prefersSimpleLanguage, isTrue);
      expect(p.display.reduceMotion, isTrue);
    });

    test('standard category is neutral', () {
      expect(
        AccessibilityProfile.forCategory(AccessibilityCategory.standard)
            .copyWith(hasCompletedSetup: false)
            .isNeutral,
        isTrue,
      );
    });
  });

  group('Subsystem contracts', () {
    test('robot payload reflects mobility, hearing and pace', () {
      final p =
          AccessibilityProfile.forCategory(AccessibilityCategory.wheelchairUser);
      final payload = p.toRobotPayload();
      expect(payload['step_free'], isTrue);
      expect(payload['more_rest_points'], isTrue);
      expect(payload['dwell_multiplier'], TourPace.relaxed.dwellMultiplier);
    });

    test('hearing profile requires captions in the robot payload', () {
      final p = AccessibilityProfile.forCategory(
          AccessibilityCategory.hearingImpairment);
      expect(p.toRobotPayload()['captions_required'], isTrue);
    });

    test('neutral profile yields no AI directives', () {
      expect(AccessibilityProfile.initial.toAiDirectives(), isEmpty);
    });

    test('AI directives adapt (en + ar) to visual + cognitive needs', () {
      final vis =
          AccessibilityProfile.forCategory(AccessibilityCategory.visualImpairment);
      expect(vis.toAiDirectives(), contains('Describe visual elements'));

      final cog = AccessibilityProfile.forCategory(
          AccessibilityCategory.cognitiveAssistance);
      expect(cog.toAiDirectives(), contains('simple language'));
      expect(cog.toAiDirectives(language: 'ar'), contains('بسيطة'));
    });

    test('notification style is derived from the profile', () {
      final vis =
          AccessibilityProfile.forCategory(AccessibilityCategory.visualImpairment);
      final style = AccessibilityNotificationStyle.fromProfile(vis);
      expect(style.announceAloud, isTrue);
      expect(style.largeText, isTrue);
      expect(style.highContrast, isTrue);
    });
  });

  group('Feature registry (future integration points, spec #18)', () {
    test('registers and discovers features relevant to a profile', () {
      final registry = AccessibilityFeatureRegistry.instance;
      registry.register(AccessibilityFeature(
        id: AccessibilityFeatureRegistry.wheelchairNavigation,
        appliesTo: (p) => p.navigation.routePreference.requiresStepFree,
      ));
      final wheelchair =
          AccessibilityProfile.forCategory(AccessibilityCategory.wheelchairUser);
      final available = registry.availableFor(wheelchair).map((f) => f.id);
      expect(available,
          contains(AccessibilityFeatureRegistry.wheelchairNavigation));
      expect(
        registry.availableFor(AccessibilityProfile.initial),
        isEmpty,
      );
    });
  });

  group('Multi-select combinations (Phase 2)', () {
    test('Visual + Wheelchair unions both needs', () {
      final p = AccessibilityProfile.forCategories({
        AccessibilityCategory.visualImpairment,
        AccessibilityCategory.wheelchairUser,
      });
      // Visual needs
      expect(p.display.highContrast, isTrue);
      expect(p.voice.screenReaderFirst, isTrue);
      // Wheelchair needs
      expect(p.navigation.routePreference, RoutePreference.stepFree);
      expect(p.tour.pace, TourPace.relaxed);
      // Both categories retained
      expect(p.categories, hasLength(2));
      expect(p.hasCategory(AccessibilityCategory.visualImpairment), isTrue);
      expect(p.hasCategory(AccessibilityCategory.wheelchairUser), isTrue);
    });

    test('Visual + Cognitive: comprehension wins (simple over detailed)', () {
      final p = AccessibilityProfile.forCategories({
        AccessibilityCategory.visualImpairment,
        AccessibilityCategory.cognitiveAssistance,
      });
      // Cognitive is layered last, so simple language wins the conflict.
      expect(p.tour.explanationLevel, ExplanationLevel.simple);
      // Visual accommodations still present.
      expect(p.display.highContrast, isTrue);
      expect(p.display.textScale, greaterThan(1.0));
      // Cognitive accommodations still present.
      expect(p.display.reduceMotion, isTrue);
      expect(p.tour.autoPauseBetweenStops, isTrue);
    });

    test('adding Standard alongside a real need is normalized away', () {
      final p = AccessibilityProfile.forCategories({
        AccessibilityCategory.standard,
        AccessibilityCategory.hearingImpairment,
      });
      expect(p.categories, {AccessibilityCategory.hearingImpairment});
      expect(p.isStandard, isFalse);
    });

    test('empty selection is the standard experience', () {
      final p = AccessibilityProfile.forCategories(const {});
      expect(p.isStandard, isTrue);
      expect(p.categories, isEmpty);
    });

    test('multi-select round-trips through storage (categories list)', () {
      final p = AccessibilityProfile.forCategories({
        AccessibilityCategory.hearingImpairment,
        AccessibilityCategory.cognitiveAssistance,
      });
      final restored =
          AccessibilityProfile.fromStorageMap(p.toStorageMap());
      expect(restored.categories, equals(p.categories));
      expect(restored, equals(p));
    });

    test('legacy Phase-1 single-category document still parses', () {
      // A document written by Phase 1 had only the scalar `category` field.
      final legacy = AccessibilityProfile.fromStorageMap({
        'category': 'wheelchair_user',
        'navigation_settings': {'route_preference': 'step_free'},
      });
      expect(legacy.hasCategory(AccessibilityCategory.wheelchairUser), isTrue);
      expect(legacy.navigation.routePreference, RoutePreference.stepFree);
    });

    test('category set equality is order-independent', () {
      final a = AccessibilityProfile.forCategories({
        AccessibilityCategory.visualImpairment,
        AccessibilityCategory.hearingImpairment,
      });
      final b = AccessibilityProfile.forCategories({
        AccessibilityCategory.hearingImpairment,
        AccessibilityCategory.visualImpairment,
      });
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
