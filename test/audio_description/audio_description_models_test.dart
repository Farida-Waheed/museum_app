import 'package:flutter_test/flutter_test.dart';
import 'package:museum_app/audio_description/models/audio_description_enums.dart';
import 'package:museum_app/audio_description/models/exhibit_description.dart';
import 'package:museum_app/audio_description/models/exhibit_id.dart';
import 'package:museum_app/audio_description/models/exhibit_metadata.dart';

/// Phase 4 Task 1 — foundational Audio Description domain models.
///
/// Pure-Dart value-object tests in the same style as the accessibility and voice
/// module suites: no Flutter binding, no plugins, fully deterministic.
void main() {
  // ---------------------------------------------------------------------------
  // Enums — storage keys + null-safe, forward-compatible fromStorage
  // ---------------------------------------------------------------------------
  group('NarrationLength', () {
    test('round-trips every value through its storage key', () {
      for (final l in NarrationLength.values) {
        expect(NarrationLength.fromStorage(l.storageKey), l);
      }
    });

    test('unknown / null storage values degrade to standard', () {
      expect(NarrationLength.fromStorage('nonsense'), NarrationLength.standard);
      expect(NarrationLength.fromStorage(null), NarrationLength.standard);
    });

    test('convenience predicates', () {
      expect(NarrationLength.short.isShort, isTrue);
      expect(NarrationLength.detailed.isDetailed, isTrue);
      expect(NarrationLength.standard.isShort, isFalse);
    });
  });

  group('StoryLayer', () {
    test('round-trips every value through its storage key', () {
      for (final l in StoryLayer.values) {
        expect(StoryLayer.fromStorage(l.storageKey), l);
      }
    });

    test('unknown / null storage values degrade to visual', () {
      expect(StoryLayer.fromStorage('???'), StoryLayer.visual);
      expect(StoryLayer.fromStorage(null), StoryLayer.visual);
    });

    test('declared in natural telling order', () {
      expect(StoryLayer.values, [
        StoryLayer.visual,
        StoryLayer.historical,
        StoryLayer.story,
        StoryLayer.accessibility,
      ]);
    });
  });

  // ---------------------------------------------------------------------------
  // ExhibitId
  // ---------------------------------------------------------------------------
  group('ExhibitId', () {
    test('trims surrounding whitespace', () {
      expect(ExhibitId('  rosetta-stone  ').value, 'rosetta-stone');
    });

    test('value equality (usable as a map/set key)', () {
      expect(ExhibitId('a'), ExhibitId('a'));
      expect(ExhibitId('a').hashCode, ExhibitId('a').hashCode);
      expect(ExhibitId('a'), isNot(ExhibitId('b')));

      final set = {ExhibitId('a'), ExhibitId('a'), ExhibitId('b')};
      expect(set.length, 2);
    });

    test('tryParse returns null for blank / null input, an id otherwise', () {
      expect(ExhibitId.tryParse(null), isNull);
      expect(ExhibitId.tryParse('   '), isNull);
      expect(ExhibitId.tryParse('  x '), ExhibitId('x'));
    });

    test('toString is the raw value', () {
      expect(ExhibitId('exhibit-42').toString(), 'exhibit-42');
    });
  });

  // ---------------------------------------------------------------------------
  // ExhibitMetadata
  // ---------------------------------------------------------------------------
  group('ExhibitMetadata', () {
    final base = ExhibitMetadata(
      id: ExhibitId('statue-ramesses'),
      title: 'Statue of Ramesses II',
      location: 'Great Hall',
      period: 'New Kingdom',
      interestingFacts: const ['Over 3,000 years old'],
      tags: const ['statue', 'granite'],
    );

    test('value equality over all fields incl. lists', () {
      final same = ExhibitMetadata(
        id: ExhibitId('statue-ramesses'),
        title: 'Statue of Ramesses II',
        location: 'Great Hall',
        period: 'New Kingdom',
        interestingFacts: const ['Over 3,000 years old'],
        tags: const ['statue', 'granite'],
      );
      expect(base, same);
      expect(base.hashCode, same.hashCode);
    });

    test('differs when a list element differs', () {
      final other = base.copyWith(tags: const ['statue', 'basalt']);
      expect(base, isNot(other));
    });

    test('list order is significant', () {
      final reordered = base.copyWith(tags: const ['granite', 'statue']);
      expect(base, isNot(reordered));
    });

    test('copyWith overrides only the named field', () {
      final renamed = base.copyWith(title: 'Colossus of Ramesses');
      expect(renamed.title, 'Colossus of Ramesses');
      expect(renamed.id, base.id);
      expect(renamed.period, base.period);
    });
  });

  // ---------------------------------------------------------------------------
  // ExhibitDescription
  // ---------------------------------------------------------------------------
  group('ExhibitDescription', () {
    final desc = ExhibitDescription(
      exhibitId: ExhibitId('statue-ramesses'),
      layers: const {
        StoryLayer.visual: 'A life-sized black granite statue.',
        StoryLayer.historical: 'Carved during the New Kingdom.',
        StoryLayer.accessibility: 'The figure stands with arms crossed.',
      },
    );

    test('present layers are reported in telling order, skipping empties', () {
      expect(desc.presentLayers, [
        StoryLayer.visual,
        StoryLayer.historical,
        StoryLayer.accessibility,
      ]);
      expect(desc.hasLayer(StoryLayer.story), isFalse);
    });

    test('a whitespace-only layer counts as absent', () {
      final d = ExhibitDescription(
        exhibitId: ExhibitId('x'),
        layers: const {
          StoryLayer.visual: 'Shown.',
          StoryLayer.story: '   ',
        },
      );
      expect(d.hasLayer(StoryLayer.story), isFalse);
      expect(d.presentLayers, [StoryLayer.visual]);
    });

    test('compose flattens only the selected present layers in telling order',
        () {
      final text = desc.compose([StoryLayer.accessibility, StoryLayer.visual]);
      // Selection order does NOT matter — output follows telling order.
      expect(text,
          'A life-sized black granite statue. The figure stands with arms crossed.');
    });

    test('compose ignores requested-but-absent layers', () {
      final text = desc.compose([StoryLayer.visual, StoryLayer.story]);
      expect(text, 'A life-sized black granite statue.');
    });

    test('fullText joins every present layer in order', () {
      expect(
        desc.fullText,
        'A life-sized black granite statue. Carved during the New Kingdom. '
        'The figure stands with arms crossed.',
      );
    });

    test('empty description reports isEmpty', () {
      final empty = ExhibitDescription(
        exhibitId: ExhibitId('x'),
        layers: const {StoryLayer.visual: ''},
      );
      expect(empty.isEmpty, isTrue);
      expect(empty.fullText, '');
    });

    test('value equality is order-independent over the layer map', () {
      final reordered = ExhibitDescription(
        exhibitId: ExhibitId('statue-ramesses'),
        layers: const {
          StoryLayer.accessibility: 'The figure stands with arms crossed.',
          StoryLayer.visual: 'A life-sized black granite statue.',
          StoryLayer.historical: 'Carved during the New Kingdom.',
        },
      );
      expect(desc, reordered);
      expect(desc.hashCode, reordered.hashCode);
    });

    test('differs by length or language even with identical layers', () {
      expect(desc, isNot(desc.copyWith(length: NarrationLength.detailed)));
      expect(desc, isNot(desc.copyWith(languageCode: 'ar')));
    });
  });
}
