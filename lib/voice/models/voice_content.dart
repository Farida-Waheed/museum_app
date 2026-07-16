import '../enums/voice_enums.dart';

/// A single spoken segment within a [VoiceContent]. Modelling speech as a list
/// of segments — rather than one flat string — is what lets the engine insert
/// deliberate pauses, emphasise an exhibit name, and apply pronunciation fixes,
/// so AI/exhibit output "sounds intentional" rather than read-aloud.
///
/// Pure value object, no plugin imports.
class VoiceSegment {
  /// The text to speak. If [ssmlHint] is provided a backend that supports SSML
  /// may use it; plain [text] is always the safe fallback.
  final String text;

  /// Silence to insert AFTER this segment (a "pause point"). Lets narration
  /// breathe between sentences or before a key fact.
  final Duration pauseAfter;

  /// When true, this segment is a title/name the engine may emphasise (slightly
  /// slower rate / raised pitch) — e.g. the exhibit name in "We have arrived at
  /// the Rosetta Stone."
  final bool emphasize;

  /// Optional per-segment language override for mixed-language content (a French
  /// exhibit title inside an English sentence). Falls back to the message
  /// language when null — future multilingual speech.
  final VoiceLanguage? language;

  const VoiceSegment(
    this.text, {
    this.pauseAfter = Duration.zero,
    this.emphasize = false,
    this.language,
  });

  /// Convenience: an emphasised segment followed by a short breath.
  const VoiceSegment.emphasis(this.text)
      : pauseAfter = const Duration(milliseconds: 250),
        emphasize = true,
        language = null;

  bool get isEmpty => text.trim().isEmpty;

  VoiceSegment copyWith({
    String? text,
    Duration? pauseAfter,
    bool? emphasize,
    VoiceLanguage? language,
  }) =>
      VoiceSegment(
        text ?? this.text,
        pauseAfter: pauseAfter ?? this.pauseAfter,
        emphasize: emphasize ?? this.emphasize,
        language: language ?? this.language,
      );

  @override
  bool operator ==(Object other) =>
      other is VoiceSegment &&
      other.text == text &&
      other.pauseAfter == pauseAfter &&
      other.emphasize == emphasize &&
      other.language == language;

  @override
  int get hashCode => Object.hash(text, pauseAfter, emphasize, language);
}

/// Structured, speakable content — the contract the AI and exhibit layers hand
/// to the engine INSTEAD of a raw string (the "AI does not simply return text"
/// requirement). The engine can render it to a backend with pauses/emphasis, or
/// flatten it to [plainText] for captions, logs, and dedup keys.
class VoiceContent {
  final List<VoiceSegment> segments;

  /// Pronunciation overrides applied before speaking: map of the written form
  /// to a spoken/phonetic form (e.g. "Hatshepsut" → "Hat-shep-soot", or an
  /// Arabic diacritised spelling). Applied by the engine adapter, backend-agnostic.
  final Map<String, String> pronunciations;

  const VoiceContent({
    required this.segments,
    this.pronunciations = const {},
  });

  /// Build content from a single plain string (the common case: one sentence,
  /// no pauses). Splits on sentence boundaries so even plain text gets natural
  /// breaths between sentences.
  factory VoiceContent.plain(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return const VoiceContent(segments: []);
    final sentences = _splitSentences(trimmed);
    return VoiceContent(
      segments: [
        for (final s in sentences)
          VoiceSegment(s, pauseAfter: const Duration(milliseconds: 180)),
      ],
    );
  }

  bool get isEmpty => segments.every((s) => s.isEmpty);

  /// Flattened text — used for captions/live-captions, dedup keys, cache keys,
  /// logging, and any backend that cannot do segment-level control.
  String get plainText =>
      segments.map((s) => s.text.trim()).where((t) => t.isNotEmpty).join(' ');

  VoiceContent withPronunciations(Map<String, String> extra) => VoiceContent(
        segments: segments,
        pronunciations: {...pronunciations, ...extra},
      );

  static List<String> _splitSentences(String text) {
    // Split on ., !, ?, and Arabic full stop / question mark, keeping content.
    final parts = text
        .split(RegExp(r'(?<=[\.\!\?؟۔])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.isEmpty ? [text] : parts;
  }

  @override
  String toString() => 'VoiceContent("${plainText.length > 40 ? '${plainText.substring(0, 40)}…' : plainText}")';
}
