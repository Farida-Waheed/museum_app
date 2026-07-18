import 'transcript_segment.dart';

/// The narrow seam that splits a narration string into ordered
/// [TranscriptSegment]s. Abstracted (DIP) so the transcript layer never hard-
/// codes a splitting strategy — a future locale-aware or TTS-boundary-aware
/// segmenter can drop in without touching the controller. This is pure text
/// work: no AI, localization service, or speech recognition.
abstract class SentenceSegmenter {
  /// Split [narration] into ordered segments. Returns an empty list for empty /
  /// whitespace-only input. Each returned segment carries its character range in
  /// [narration].
  List<TranscriptSegment> segment(String narration);
}

/// Default segmenter: splits on sentence-ending punctuation (`.`, `!`, `?`,
/// and the Arabic question mark `؟`), keeping the terminator with its sentence
/// and preserving the source character offsets. Any trailing text without a
/// terminator becomes a final segment, so no narration is ever dropped.
///
/// It is deliberately conservative — it does not try to be a full NLP sentence
/// tokenizer (abbreviations, decimals). That is enough for highlighting spoken
/// narration and keeps the behavior fully deterministic and testable.
class DefaultSentenceSegmenter implements SentenceSegmenter {
  const DefaultSentenceSegmenter();

  static const Set<String> _terminators = {'.', '!', '?', '؟'};

  @override
  List<TranscriptSegment> segment(String narration) {
    final segments = <TranscriptSegment>[];
    var pendingStart = 0;
    var index = 0;

    void flush(int endExclusive) {
      if (endExclusive <= pendingStart) return;
      final raw = narration.substring(pendingStart, endExclusive);
      final trimmed = raw.trim();
      if (trimmed.isEmpty) {
        pendingStart = endExclusive;
        return;
      }
      // Tighten the recorded range to the trimmed text so offsets point at real
      // characters, not surrounding whitespace.
      final leading = raw.indexOf(trimmed[0]);
      final start = pendingStart + leading;
      segments.add(TranscriptSegment(
        index: index++,
        text: trimmed,
        start: start,
        end: start + trimmed.length,
      ));
      pendingStart = endExclusive;
    }

    for (var i = 0; i < narration.length; i++) {
      if (_terminators.contains(narration[i])) {
        // Consume any run of consecutive terminators (e.g. "?!", "...").
        var j = i;
        while (j + 1 < narration.length &&
            _terminators.contains(narration[j + 1])) {
          j++;
        }
        flush(j + 1);
        i = j;
      }
    }
    // Trailing text with no terminator.
    flush(narration.length);

    return segments;
  }
}
