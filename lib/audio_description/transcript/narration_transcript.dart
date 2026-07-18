import '../models/exhibit_id.dart';
import 'sentence_segmenter.dart';
import 'transcript_segment.dart';

/// An immutable transcript of one exhibit narration: the full text plus its
/// ordered [TranscriptSegment]s. It is pure data produced once when narration
/// begins; the mutable "which segment is active" cursor lives in
/// [TranscriptState], never here. No Flutter / AI / Firebase imports.
class NarrationTranscript {
  /// The exhibit this transcript belongs to.
  final ExhibitId exhibitId;

  /// The complete narration text the segments were derived from.
  final String fullText;

  /// The ordered spoken units. Empty when [fullText] has no speakable content.
  final List<TranscriptSegment> segments;

  const NarrationTranscript({
    required this.exhibitId,
    required this.fullText,
    required this.segments,
  });

  /// Build a transcript for [exhibitId] by splitting [narration] with the given
  /// [segmenter]. An empty / whitespace-only narration yields an empty segment
  /// list (a valid, "nothing to speak" transcript).
  factory NarrationTranscript.build({
    required ExhibitId exhibitId,
    required String narration,
    SentenceSegmenter segmenter = const DefaultSentenceSegmenter(),
  }) {
    return NarrationTranscript(
      exhibitId: exhibitId,
      fullText: narration,
      segments: List.unmodifiable(segmenter.segment(narration)),
    );
  }

  /// Whether there is at least one speakable segment.
  bool get isEmpty => segments.isEmpty;
  bool get isNotEmpty => segments.isNotEmpty;

  int get segmentCount => segments.length;

  /// The segment at [index], or null when out of range.
  TranscriptSegment? segmentAt(int index) =>
      (index >= 0 && index < segments.length) ? segments[index] : null;

  @override
  String toString() =>
      'NarrationTranscript($exhibitId, ${segments.length} segments)';
}
