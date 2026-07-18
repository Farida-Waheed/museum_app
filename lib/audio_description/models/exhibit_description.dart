import 'audio_description_enums.dart';
import 'exhibit_id.dart';

/// A generated (or cached fallback) narration for one exhibit, held as its four
/// [StoryLayer]s of text rather than a single blob. Storing the layers
/// separately is the whole point: the description engine composes only the
/// layers a given visitor's profile calls for (e.g. a visually-impaired visitor
/// always gets the [StoryLayer.accessibility] layer; a child gets the
/// [StoryLayer.story] layer emphasised), so one description serves every profile
/// without regenerating it.
///
/// Pure, immutable value object — no AI, networking, Firebase, or UI imports.
/// This is the *shape* of a description; producing one (from AI or a cached
/// fallback) belongs to later tasks.
class ExhibitDescription {
  final ExhibitId exhibitId;

  /// The text for each story layer. A layer may be absent (e.g. no interesting
  /// story was generated); consumers compose whatever layers are present.
  final Map<StoryLayer, String> layers;

  /// The length this description was produced for, so the cache and engine know
  /// whether a longer/shorter variant must be (re)generated on request.
  final NarrationLength length;

  /// BCP-47-ish language code the text is written in ('en' / 'ar'), so a cached
  /// description is never spoken in the wrong language.
  final String languageCode;

  const ExhibitDescription({
    required this.exhibitId,
    required this.layers,
    this.length = NarrationLength.standard,
    this.languageCode = 'en',
  });

  /// The text for a single layer, or null when that layer was not produced.
  String? layer(StoryLayer layer) => layers[layer];

  bool hasLayer(StoryLayer layer) {
    final text = layers[layer];
    return text != null && text.trim().isNotEmpty;
  }

  /// The layers that actually carry text, in natural telling order ([StoryLayer]
  /// index order). Empty layers are skipped.
  List<StoryLayer> get presentLayers =>
      StoryLayer.values.where(hasLayer).toList();

  bool get isEmpty => presentLayers.isEmpty;

  /// The layers a profile calls for, flattened into one spoken string in natural
  /// telling order ([StoryLayer] index order), regardless of the order they are
  /// requested in. Pure text assembly only — no personalisation logic lives
  /// here; a caller (a later task) decides WHICH layers to pass in.
  String compose(Iterable<StoryLayer> selected) {
    final wanted = selected.toSet();
    return StoryLayer.values
        .where(wanted.contains)
        .where(hasLayer)
        .map((l) => layers[l]!.trim())
        .where((t) => t.isNotEmpty)
        .join(' ');
  }

  /// Convenience: every present layer, in order — the fullest telling.
  String get fullText => compose(StoryLayer.values);

  ExhibitDescription copyWith({
    ExhibitId? exhibitId,
    Map<StoryLayer, String>? layers,
    NarrationLength? length,
    String? languageCode,
  }) =>
      ExhibitDescription(
        exhibitId: exhibitId ?? this.exhibitId,
        layers: layers ?? this.layers,
        length: length ?? this.length,
        languageCode: languageCode ?? this.languageCode,
      );

  @override
  bool operator ==(Object other) =>
      other is ExhibitDescription &&
      other.exhibitId == exhibitId &&
      other.length == length &&
      other.languageCode == languageCode &&
      _mapEquals(other.layers, layers);

  @override
  int get hashCode => Object.hash(
        exhibitId,
        length,
        languageCode,
        // Order-independent hash of the layer map.
        Object.hashAllUnordered(
          layers.entries.map((e) => Object.hash(e.key, e.value)),
        ),
      );

  @override
  String toString() =>
      'ExhibitDescription($exhibitId, ${length.storageKey}, $languageCode, '
      'layers: ${presentLayers.map((l) => l.storageKey).join('+')})';
}

/// Order-independent map equality over the layer texts, used by `==` so two
/// descriptions with the same layers compare equal regardless of insertion
/// order (needed for caching and tests).
bool _mapEquals(Map<StoryLayer, String> a, Map<StoryLayer, String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (b[entry.key] != entry.value) return false;
  }
  return true;
}
