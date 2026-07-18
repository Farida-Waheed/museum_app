import 'package:flutter_test/flutter_test.dart';
import 'package:museum_app/accessibility/accessibility.dart';
import 'package:museum_app/audio_description/context/conversation_context_manager.dart';
import 'package:museum_app/audio_description/models/exhibit_id.dart';
import 'package:museum_app/audio_description/models/exhibit_metadata.dart';
import 'package:museum_app/audio_description/models/narration_preferences.dart';
import 'package:museum_app/audio_description/services/narration_profile_mapper.dart';

/// Phase 4 Task 6 — conversational context carry-over tests.
///
/// Pure, deterministic: a fixed clock makes timestamps assertable and no AI /
/// network is touched. Policies come from the real Task 2 mapper.
void main() {
  final policy = NarrationProfileMapper.resolve(
    AccessibilityProfile(),
    preferences: const NarrationPreferences(),
  );

  ExhibitMetadata meta(String id, String title) =>
      ExhibitMetadata(id: ExhibitId(id), title: title);

  final rosetta = meta('rosetta', 'Rosetta Stone');
  final mask = meta('mask', 'Mask of Tutankhamun');

  final fixedTime = DateTime(2024, 1, 1, 10, 30);
  ConversationContextManager manager({String language = 'en'}) =>
      ConversationContextManager(
        clock: () => fixedTime,
        initialLanguage: language,
      );

  group('initial empty context', () {
    test('starts with no exhibit, no narration, default language', () {
      final m = manager();
      expect(m.current.hasExhibit, isFalse);
      expect(m.current.hasNarration, isFalse);
      expect(m.current.exhibitId, isNull);
      expect(m.current.recentFollowUps, isEmpty);
      expect(m.current.language, 'en');
    });

    test('honours a seeded initial language', () {
      expect(manager(language: 'ar').current.language, 'ar');
    });
  });

  group('context update', () {
    test('onNarrationComplete populates the current exhibit context', () {
      final m = manager();
      m.onNarrationComplete(
        metadata: rosetta,
        narration: 'A slab of decrees in three scripts.',
        policy: policy,
      );

      final c = m.current;
      expect(c.exhibitId, rosetta.id);
      expect(c.metadata, rosetta);
      expect(c.lastNarration, 'A slab of decrees in three scripts.');
      expect(c.narrationAt, fixedTime);
      expect(c.policy, policy);
      expect(c.hasNarration, isTrue);
    });
  });

  group('context replacement', () {
    test('moving to a new exhibit replaces context and resets follow-ups', () {
      final m = manager();
      m.onNarrationComplete(
          metadata: rosetta, narration: 'first', policy: policy);
      m.recordFollowUp('why three scripts?');
      expect(m.current.recentFollowUps, isNotEmpty);

      m.onNarrationComplete(metadata: mask, narration: 'second', policy: policy);

      expect(m.current.exhibitId, mask.id);
      expect(m.current.lastNarration, 'second');
      expect(m.current.recentFollowUps, isEmpty,
          reason: 'a new exhibit starts a fresh conversation');
    });

    test('re-narrating the SAME exhibit keeps its follow-up history', () {
      final m = manager();
      m.onNarrationComplete(
          metadata: rosetta, narration: 'first', policy: policy);
      m.recordFollowUp('who found it?');

      m.onNarrationComplete(
          metadata: rosetta, narration: 'expanded', policy: policy);

      expect(m.current.lastNarration, 'expanded');
      expect(m.current.recentFollowUps, ['who found it?']);
    });
  });

  group('follow-up question enrichment', () {
    test('enriches a bare question with the current exhibit + prior questions',
        () {
      final m = manager();
      m.onNarrationComplete(
          metadata: rosetta, narration: 'n', policy: policy);
      m.recordFollowUp('who found it?');

      final enriched = m.enrichFollowUp('why is it broken?');

      expect(enriched, contains('Rosetta Stone'));
      expect(enriched, contains('why is it broken?'));
      expect(enriched, contains('who found it?')); // earlier question included
      expect(enriched, contains('this specific exhibit'));
    });

    test('with no exhibit in context, returns the question unchanged (trimmed)',
        () {
      final m = manager();
      expect(m.enrichFollowUp('  hello?  '), 'hello?');
    });

    test('remember:true also records the question into history', () {
      final m = manager();
      m.onNarrationComplete(metadata: rosetta, narration: 'n', policy: policy);
      m.enrichFollowUp('how old is it?', remember: true);
      expect(m.current.recentFollowUps, contains('how old is it?'));
    });

    test('Arabic context enriches in Arabic', () {
      final m = manager(language: 'ar');
      m.onNarrationComplete(metadata: rosetta, narration: 'n', policy: policy);
      final enriched = m.enrichFollowUp('كم عمره؟');
      expect(enriched, contains('سؤال المتابعة'));
      expect(enriched, contains('Rosetta Stone'));
    });
  });

  group('context clearing', () {
    test('clear resets the exhibit but preserves language', () {
      final m = manager(language: 'ar');
      m.onNarrationComplete(metadata: rosetta, narration: 'n', policy: policy);
      m.recordFollowUp('q');

      m.clear();

      expect(m.current.hasExhibit, isFalse);
      expect(m.current.lastNarration, isNull);
      expect(m.current.recentFollowUps, isEmpty);
      expect(m.current.language, 'ar', reason: 'language survives a clear');
    });
  });

  group('language preservation', () {
    test('narration without an explicit language keeps the active language', () {
      final m = manager(language: 'ar');
      m.onNarrationComplete(metadata: rosetta, narration: 'n', policy: policy);
      expect(m.current.language, 'ar');
    });

    test('an explicit narration language overrides, then persists', () {
      final m = manager(language: 'en');
      m.onNarrationComplete(
          metadata: rosetta, narration: 'n', policy: policy, language: 'ar');
      expect(m.current.language, 'ar');
      m.clear();
      expect(m.current.language, 'ar');
    });

    test('setLanguage updates language without disturbing the exhibit', () {
      final m = manager();
      m.onNarrationComplete(metadata: rosetta, narration: 'n', policy: policy);
      m.setLanguage('ar');
      expect(m.current.language, 'ar');
      expect(m.current.exhibitId, rosetta.id);
    });
  });

  group('repeated updates', () {
    test('follow-up history is capped, dropping the oldest first', () {
      final m = ConversationContextManager(
        clock: () => fixedTime,
        maxFollowUps: 3,
      );
      m.onNarrationComplete(metadata: rosetta, narration: 'n', policy: policy);
      for (final q in ['q1', 'q2', 'q3', 'q4', 'q5']) {
        m.recordFollowUp(q);
      }
      expect(m.current.recentFollowUps, ['q3', 'q4', 'q5']);
    });

    test('blank follow-ups are ignored', () {
      final m = manager();
      m.onNarrationComplete(metadata: rosetta, narration: 'n', policy: policy);
      m.recordFollowUp('   ');
      expect(m.current.recentFollowUps, isEmpty);
    });

    test('repeated narrations of different exhibits always track the latest', () {
      final m = manager();
      for (var i = 0; i < 4; i++) {
        final e = i.isEven ? rosetta : mask;
        m.onNarrationComplete(metadata: e, narration: 'n$i', policy: policy);
        expect(m.current.exhibitId, e.id);
        expect(m.current.lastNarration, 'n$i');
      }
    });
  });
}
