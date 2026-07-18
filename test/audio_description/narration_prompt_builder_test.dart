import 'package:flutter_test/flutter_test.dart';
import 'package:museum_app/accessibility/accessibility.dart';
import 'package:museum_app/audio_description/models/audio_description_enums.dart';
import 'package:museum_app/audio_description/models/exhibit_description.dart';
import 'package:museum_app/audio_description/models/exhibit_id.dart';
import 'package:museum_app/audio_description/models/exhibit_metadata.dart';
import 'package:museum_app/audio_description/models/narration_preferences.dart';
import 'package:museum_app/audio_description/prompt/narration_prompt.dart';
import 'package:museum_app/audio_description/prompt/narration_prompt_builder.dart';
import 'package:museum_app/audio_description/services/narration_profile_mapper.dart';

/// Phase 4 Task 4 — AI prompt builder tests.
///
/// The builder is a pure text transformation (no AI/network), so every test is
/// deterministic: build a prompt and assert on its structure/content. Policies
/// come from the real Task 2 mapper so the prompt reflects genuine adaptations.
void main() {
  const builder = NarrationPromptBuilder();

  final fullMetadata = ExhibitMetadata(
    id: ExhibitId('statue-ramesses'),
    title: 'Statue of Ramesses II',
    location: 'Great Hall',
    period: 'New Kingdom, Dynasty 19',
    physicalDescription: 'A colossal black granite figure with crossed arms.',
    historicalContext: 'Commissioned to project royal power.',
    interestingFacts: const ['Carved from a single block', 'Over 3,000 years old'],
  );

  AccessibilityProfile profile({
    Set<AccessibilityCategory> categories = const {},
    VoiceSettings voice = VoiceSettings.standard,
    AccessibilityTourPreferences tour = AccessibilityTourPreferences.standard,
  }) =>
      AccessibilityProfile(categories: categories, voice: voice, tour: tour);

  NarrationPrompt buildFor(
    AccessibilityProfile p, {
    NarrationPreferences prefs = NarrationPreferences.defaults,
    ExhibitMetadata? metadata,
    ExhibitDescription? description,
    String language = 'en',
  }) {
    final policy = NarrationProfileMapper.resolve(p, preferences: prefs);
    return builder.build(
      metadata: metadata ?? fullMetadata,
      policy: policy,
      profile: p,
      preferences: prefs,
      description: description,
      language: language,
    );
  }

  group('always-present structure & output constraints', () {
    test('includes exhibit facts and the core constraints (English)', () {
      final prompt = buildFor(profile());
      final text = prompt.combined;

      // Exhibit facts.
      expect(text, contains('Statue of Ramesses II'));
      expect(text, contains('New Kingdom, Dynasty 19'));
      expect(text, contains('colossal black granite'));
      expect(text, contains('project royal power'));
      expect(text, contains('Carved from a single block'));

      // Required output constraints.
      expect(text, contains('factual'));
      expect(text.toLowerCase(), contains('hallucinat'));
      expect(text, contains('Do not repeat'));
      expect(text, contains('natural spoken language'));
      expect(text, contains('narration length'));
      expect(text, contains('English'));
    });

    test('identifies Horus as the guide', () {
      expect(buildFor(profile()).systemPrompt, contains('Horus'));
    });
  });

  group('narration length', () {
    test('short narration (cognitive) states the 30–45s target', () {
      final prompt = buildFor(
        profile(categories: {AccessibilityCategory.cognitiveAssistance}),
      );
      expect(prompt.length, NarrationLength.short);
      expect(prompt.combined, contains('30–45 seconds'));
    });

    test('standard narration states the 1–2 minute target', () {
      final prompt = buildFor(profile());
      expect(prompt.length, NarrationLength.standard);
      expect(prompt.combined, contains('1–2 minutes'));
    });

    test('detailed narration (researcher) states the 3–5 minute target', () {
      final prompt = buildFor(
        profile(),
        prefs: const NarrationPreferences(audience: VisitorAudience.researcher),
      );
      expect(prompt.length, NarrationLength.detailed);
      expect(prompt.combined, contains('3–5 minutes'));
    });
  });

  group('language', () {
    test('English prompt is tagged and instructs English output', () {
      final prompt = buildFor(profile(), language: 'en');
      expect(prompt.isArabic, isFalse);
      expect(prompt.combined, contains('Write the entire narration in English.'));
    });

    test('Arabic prompt is tagged and instructs Arabic output', () {
      final prompt = buildFor(profile(), language: 'ar');
      expect(prompt.isArabic, isTrue);
      expect(prompt.language, 'ar');
      expect(prompt.combined, contains('اكتب السرد بالكامل باللغة العربية.'));
      // Arabic facts labels present.
      expect(prompt.combined, contains('معلومات القطعة الأثرية:'));
    });
  });

  group('accessibility adaptations', () {
    test('visual-impairment policy asks for rich physical description + a11y layer',
        () {
      final prompt = buildFor(
        profile(voice: const VoiceSettings(screenReaderFirst: true)),
      );
      expect(prompt.layers, contains(StoryLayer.accessibility));
      expect(prompt.combined,
          contains('especially rich physical description'));
      // Accessibility enhancement layer instruction is present.
      expect(prompt.combined.toLowerCase(), contains('facial expressions'));
    });

    test("reuses the profile's own accessibility directives", () {
      final p = profile(voice: const VoiceSettings(screenReaderFirst: true));
      final prompt = buildFor(p);
      // The exact directive text comes from AccessibilityProfile.toAiDirectives.
      expect(prompt.combined, contains('not relying on the screen'));
    });

    test('cognitive policy adds a simple-language constraint + short layer set', () {
      final prompt = buildFor(
        profile(categories: {AccessibilityCategory.cognitiveAssistance}),
      );
      expect(prompt.combined, contains('short sentences and simple vocabulary'));
      expect(prompt.layers, [StoryLayer.visual, StoryLayer.historical]);
    });
  });

  group('audience modes', () {
    test('child mode sets a storytelling tone with interactive questions', () {
      final prompt = buildFor(
        profile(),
        prefs: const NarrationPreferences(audience: VisitorAudience.child),
      );
      expect(prompt.combined, contains('Target audience: a child'));
      expect(prompt.combined.toLowerCase(), contains('interactive question'));
    });

    test('research mode sets an academic/archaeological tone', () {
      final prompt = buildFor(
        profile(),
        prefs: const NarrationPreferences(audience: VisitorAudience.researcher),
      );
      expect(prompt.combined, contains('researcher'));
      expect(prompt.combined.toLowerCase(), contains('archaeological'));
    });

    test('student mode adds educational detail to the tone', () {
      final prompt = buildFor(
        profile(),
        prefs: const NarrationPreferences(audience: VisitorAudience.student),
      );
      expect(prompt.combined, contains('student'));
      expect(prompt.combined.toLowerCase(), contains('educational'));
    });
  });

  group('optional fields & prior material', () {
    test('missing optional metadata fields are simply omitted (no blank labels)',
        () {
      final sparse = ExhibitMetadata(
        id: ExhibitId('mystery'),
        title: 'Unlabeled Fragment',
      );
      final prompt = buildFor(profile(), metadata: sparse);
      final text = prompt.combined;

      expect(text, contains('Unlabeled Fragment'));
      // No empty "Location:" / "Historical period:" lines.
      expect(text, isNot(contains('Location:')));
      expect(text, isNot(contains('Historical period:')));
      expect(text, isNot(contains('Interesting facts:')));
    });

    test('a prior description is offered as anti-repetition material', () {
      final prior = ExhibitDescription(
        exhibitId: ExhibitId('statue-ramesses'),
        layers: const {
          StoryLayer.visual: 'A previously generated visual description.',
        },
      );
      final prompt = buildFor(profile(), description: prior);
      expect(prompt.combined, contains('do not repeat verbatim'));
      expect(prompt.combined, contains('A previously generated visual description.'));
    });

    test('no prior description → no anti-repetition block', () {
      final prompt = buildFor(profile());
      expect(prompt.combined, isNot(contains('do not repeat verbatim')));
    });
  });

  group('prompt layers metadata', () {
    test('layers list mirrors the policy ordered layers', () {
      final p = profile(voice: const VoiceSettings(screenReaderFirst: true));
      final policy = NarrationProfileMapper.resolve(p);
      final prompt = buildFor(p);
      expect(prompt.layers, policy.orderedLayers);
    });
  });
}
