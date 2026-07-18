import 'audio_description_enums.dart';

/// The fully-resolved narration behaviour for one visitor at one moment — the
/// output of [NarrationProfileMapper]. It is the audio-description analogue of a
/// resolved `SpeechConfig`: a pure, immutable bundle the description engine and
/// the AI prompt builder read, so no downstream layer ever re-inspects the raw
/// accessibility profile.
///
/// Every field is a decision, not a raw preference — the mapping from profile +
/// preferences to these values is the whole point of the policy layer.
class NarrationPolicy {
  /// How long the narration should run.
  final NarrationLength length;

  /// Which story layers to include, in natural telling order. Always non-empty.
  final Set<StoryLayer> layers;

  /// How simple the language should be (true for cognitive assistance / children
  /// / the profile's simple explanation level).
  final bool useSimpleLanguage;

  /// How scholarly the content leans.
  final EducationalDepth educationalDepth;

  /// Child-mode telling: comparisons, playful framing, interactive questions.
  final bool childMode;

  /// Research-mode telling: maximum archaeological / historical depth.
  final bool researchMode;

  /// Whether to give extra-detailed physical description because the visitor
  /// relies on it (visual impairment / audio description / screen-reader-first).
  /// This is what guarantees the [StoryLayer.accessibility] layer is present.
  final bool emphasizePhysicalDescription;

  /// Whether the narration should end with an inviting follow-up question
  /// ("Would you like to know why…?"), encouraging natural conversation. Muted
  /// for the most concise/cognitive tellings so it does not add load.
  final bool inviteFollowUp;

  const NarrationPolicy({
    required this.length,
    required this.layers,
    required this.useSimpleLanguage,
    required this.educationalDepth,
    required this.childMode,
    required this.researchMode,
    required this.emphasizePhysicalDescription,
    required this.inviteFollowUp,
  });

  /// The layers this policy calls for, in natural telling order ([StoryLayer]
  /// index order) — the order the engine should speak them in.
  List<StoryLayer> get orderedLayers =>
      StoryLayer.values.where(layers.contains).toList();

  bool includesLayer(StoryLayer layer) => layers.contains(layer);

  @override
  bool operator ==(Object other) =>
      other is NarrationPolicy &&
      other.length == length &&
      other.useSimpleLanguage == useSimpleLanguage &&
      other.educationalDepth == educationalDepth &&
      other.childMode == childMode &&
      other.researchMode == researchMode &&
      other.emphasizePhysicalDescription == emphasizePhysicalDescription &&
      other.inviteFollowUp == inviteFollowUp &&
      _setEquals(other.layers, layers);

  @override
  int get hashCode => Object.hash(
        length,
        useSimpleLanguage,
        educationalDepth,
        childMode,
        researchMode,
        emphasizePhysicalDescription,
        inviteFollowUp,
        Object.hashAllUnordered(layers),
      );

  @override
  String toString() =>
      'NarrationPolicy(${length.storageKey}, '
      'layers: ${orderedLayers.map((l) => l.storageKey).join('+')}, '
      'simple: $useSimpleLanguage, depth: ${educationalDepth.storageKey}, '
      'child: $childMode, research: $researchMode)';
}

bool _setEquals(Set<StoryLayer> a, Set<StoryLayer> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  return a.every(b.contains);
}
