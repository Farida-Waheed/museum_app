import '../models/audio_description_enums.dart' show StoryLayer, NarrationLength;

/// The structured result of [NarrationPromptBuilder] — everything Task 5 needs
/// to send a narration request to the AI backend, kept as data so the builder
/// itself never touches a network/AI client.
///
/// Pure value object (no Flutter/AI/Firebase imports): the prompt *text* the AI
/// will receive, plus the metadata (language, length, layers, audience) a caller
/// or analytics may want without re-parsing the string. Mirrors the "produce
/// structured content, not a bare string" ethos of the Phase 3 voice layer.
class NarrationPrompt {
  /// System-level instruction: role, tone, factuality, and output constraints.
  /// Sent as the system / developer message by Task 5.
  final String systemPrompt;

  /// The user-level instruction: the concrete exhibit facts + what to produce.
  final String userPrompt;

  /// BCP-ish short language code the narration must be written in ('en' / 'ar').
  final String language;

  final NarrationLength length;

  /// The story layers the AI was asked to cover, in telling order.
  final List<StoryLayer> layers;

  const NarrationPrompt({
    required this.systemPrompt,
    required this.userPrompt,
    required this.language,
    required this.length,
    required this.layers,
  });

  /// The two prompts joined, for backends that take a single combined string.
  String get combined => '$systemPrompt\n\n$userPrompt';

  bool get isArabic => language == 'ar';

  @override
  String toString() =>
      'NarrationPrompt($language, ${length.storageKey}, '
      'layers: ${layers.map((l) => l.storageKey).join('+')})';
}
