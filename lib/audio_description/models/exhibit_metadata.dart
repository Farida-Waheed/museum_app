import 'exhibit_id.dart';

/// The raw, factual record of an exhibit — the source material the AI turns into
/// adaptive narration. It is intentionally *descriptive data only*: the same
/// metadata feeds every visitor, and the personalisation (which layers, how
/// long, how simple) happens later from the accessibility profile. Keeping the
/// facts here separate from the generated telling is what lets one exhibit be
/// narrated many different ways without duplicating its data.
///
/// Pure, immutable value object — no AI, networking, Firebase, or UI imports.
class ExhibitMetadata {
  final ExhibitId id;

  /// Display name of the artifact (e.g. "Statue of Ramesses II").
  final String title;

  /// The gallery / hall / section it lives in, for spatial context.
  final String location;

  /// Physical facts a describer would mention: materials, colours, dimensions,
  /// texture, decorative detail. Free-form so the AI can weave them naturally.
  final String physicalDescription;

  /// Who / when / why — the historical and cultural background.
  final String historicalContext;

  /// The period or dynasty this piece belongs to (e.g. "New Kingdom, Dynasty 18").
  final String period;

  /// Short, memorable facts the storytelling layer can lean on.
  final List<String> interestingFacts;

  /// Free-form tags for grouping / retrieval (themes, categories, keywords).
  final List<String> tags;

  const ExhibitMetadata({
    required this.id,
    required this.title,
    this.location = '',
    this.physicalDescription = '',
    this.historicalContext = '',
    this.period = '',
    this.interestingFacts = const [],
    this.tags = const [],
  });

  ExhibitMetadata copyWith({
    ExhibitId? id,
    String? title,
    String? location,
    String? physicalDescription,
    String? historicalContext,
    String? period,
    List<String>? interestingFacts,
    List<String>? tags,
  }) =>
      ExhibitMetadata(
        id: id ?? this.id,
        title: title ?? this.title,
        location: location ?? this.location,
        physicalDescription: physicalDescription ?? this.physicalDescription,
        historicalContext: historicalContext ?? this.historicalContext,
        period: period ?? this.period,
        interestingFacts: interestingFacts ?? this.interestingFacts,
        tags: tags ?? this.tags,
      );

  @override
  bool operator ==(Object other) =>
      other is ExhibitMetadata &&
      other.id == id &&
      other.title == title &&
      other.location == location &&
      other.physicalDescription == physicalDescription &&
      other.historicalContext == historicalContext &&
      other.period == period &&
      _listEquals(other.interestingFacts, interestingFacts) &&
      _listEquals(other.tags, tags);

  @override
  int get hashCode => Object.hash(
        id,
        title,
        location,
        physicalDescription,
        historicalContext,
        period,
        Object.hashAll(interestingFacts),
        Object.hashAll(tags),
      );

  @override
  String toString() => 'ExhibitMetadata($id, "$title")';
}

/// Order-sensitive list equality, used by the value objects' `==` so two records
/// with the same contents compare equal (needed for caching and tests).
bool _listEquals(List<String> a, List<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
