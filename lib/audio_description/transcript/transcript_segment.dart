/// One ordered, spoken unit of a narration transcript — typically a sentence.
/// Immutable value object: it carries the text, its position in the telling, and
/// the character range it occupies in the original narration (so a higher layer
/// can highlight it without re-splitting). No Flutter / AI / Firebase imports.
class TranscriptSegment {
  /// Zero-based position of this segment in the narration.
  final int index;

  /// The segment text (trimmed, non-empty).
  final String text;

  /// Inclusive start offset of [text] within the original narration string.
  final int start;

  /// Exclusive end offset of [text] within the original narration string.
  final int end;

  const TranscriptSegment({
    required this.index,
    required this.text,
    required this.start,
    required this.end,
  });

  /// Number of characters this segment spans in the source narration.
  int get length => end - start;

  @override
  bool operator ==(Object other) =>
      other is TranscriptSegment &&
      other.index == index &&
      other.text == text &&
      other.start == start &&
      other.end == end;

  @override
  int get hashCode => Object.hash(index, text, start, end);

  @override
  String toString() => 'TranscriptSegment(#$index, "$text")';
}
