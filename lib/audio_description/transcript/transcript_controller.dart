import '../ai/narration_generation_result.dart';
import '../models/exhibit_id.dart';
import 'narration_transcript.dart';
import 'sentence_segmenter.dart';
import 'transcript_state.dart';
import 'transcript_status.dart';

/// Maintains a live transcript of the current exhibit narration, keeping the
/// spoken narration synchronized with transcript state (the Phase-4 "Live
/// Transcript" requirement).
///
/// It is pure orchestration / state management: it builds an immutable
/// [NarrationTranscript] from narration text (via the injected
/// [SentenceSegmenter]), tracks the active segment as spoken-progress signals
/// arrive, and publishes an immutable [TranscriptState] on every change. It does
/// NOT drive playback, call any TTS engine, do AI, localization, repositories,
/// speech recognition, robot logic, or analytics — it only reflects narration
/// that some other layer is producing/speaking. It never throws.
///
/// Progress is fed in through [advanceTo] / [advance] (a higher layer maps a TTS
/// word/sentence-boundary callback or a timer to these), so this layer needs no
/// timing dependency of its own — keeping it deterministic and unit-testable.
class TranscriptController {
  TranscriptController({
    SentenceSegmenter segmenter = const DefaultSentenceSegmenter(),
  }) : _segmenter = segmenter;

  final SentenceSegmenter _segmenter;

  TranscriptState _state = TranscriptState.initial;
  TranscriptState get state => _state;

  /// The transcript currently tracked, if any.
  NarrationTranscript? get transcript => _state.transcript;

  /// Published on every transcript state change.
  void Function(TranscriptState state)? onStateChanged;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Begin a transcript for [exhibitId] from [narration]. Splits the text into
  /// segments and activates the first one. An empty / whitespace-only narration
  /// produces an empty transcript that is immediately [TranscriptStatus.completed]
  /// (there is nothing to speak). Starting a transcript always supersedes any
  /// previous one (new exhibit resets cleanly).
  TranscriptState begin({
    required ExhibitId exhibitId,
    required String narration,
  }) {
    final transcript = NarrationTranscript.build(
      exhibitId: exhibitId,
      narration: narration,
      segmenter: _segmenter,
    );

    if (transcript.isEmpty) {
      // Nothing speakable — a valid, already-finished transcript.
      return _publish(TranscriptState(
        status: TranscriptStatus.completed,
        transcript: transcript,
        activeIndex: -1,
      ));
    }

    return _publish(TranscriptState(
      status: TranscriptStatus.active,
      transcript: transcript,
      activeIndex: 0,
    ));
  }

  /// Convenience: begin a transcript from an existing successful
  /// [NarrationGenerationResult]. A non-success / empty result yields an empty
  /// completed transcript (there is no narration to track).
  TranscriptState beginFromResult({
    required ExhibitId exhibitId,
    required NarrationGenerationResult result,
  }) {
    final text = result.isSuccess ? (result.narration ?? '') : '';
    return begin(exhibitId: exhibitId, narration: text);
  }

  /// Reset to the idle, empty transcript (e.g. leaving an exhibit with no
  /// immediate replacement). Idempotent.
  TranscriptState reset() {
    if (_state.status == TranscriptStatus.idle && _state.transcript == null) {
      return _state;
    }
    return _publish(TranscriptState.initial);
  }

  // ---------------------------------------------------------------------------
  // Progress
  // ---------------------------------------------------------------------------

  /// Mark segment [index] as the one now being spoken. Advancing is monotonic —
  /// a lower or equal index is ignored (idempotent against repeated progress
  /// updates for the same segment). Progress only applies while active; it is a
  /// no-op when idle/paused/terminal. Advancing past the last segment completes
  /// the transcript.
  TranscriptState advanceTo(int index) {
    if (_state.status != TranscriptStatus.active) return _state;
    final transcript = _state.transcript;
    if (transcript == null || transcript.isEmpty) return _state;

    // Reached / passed the end → completed.
    if (index >= transcript.segmentCount) {
      return _publish(_state.copyWith(
        status: TranscriptStatus.completed,
        activeIndex: transcript.segmentCount - 1,
      ));
    }
    // Ignore out-of-range low values and non-forward updates (repeat/rewind).
    if (index <= _state.activeIndex) return _state;

    return _publish(_state.copyWith(activeIndex: index));
  }

  /// Advance to the next segment, completing when the last one is passed.
  TranscriptState advance() => advanceTo(_state.activeIndex + 1);

  /// Mark the whole transcript as spoken.
  TranscriptState complete() {
    if (_state.status.isTerminal) return _state;
    final transcript = _state.transcript;
    if (transcript == null) return _state;
    return _publish(_state.copyWith(
      status: TranscriptStatus.completed,
      activeIndex:
          transcript.isEmpty ? -1 : transcript.segmentCount - 1,
    ));
  }

  // ---------------------------------------------------------------------------
  // Pause / resume / cancel
  // ---------------------------------------------------------------------------

  /// Pause tracking; the active segment is held. No-op unless active.
  TranscriptState pause() {
    if (_state.status != TranscriptStatus.active) return _state;
    return _publish(_state.copyWith(status: TranscriptStatus.paused));
  }

  /// Resume tracking from where it paused. No-op unless paused.
  TranscriptState resume() {
    if (_state.status != TranscriptStatus.paused) return _state;
    return _publish(_state.copyWith(status: TranscriptStatus.active));
  }

  /// Abandon the current transcript (visitor skipped / moved on). No-op when
  /// idle or already terminal.
  TranscriptState cancel() {
    if (_state.status == TranscriptStatus.idle || _state.status.isTerminal) {
      return _state;
    }
    return _publish(_state.copyWith(status: TranscriptStatus.cancelled));
  }

  // ---------------------------------------------------------------------------
  TranscriptState _publish(TranscriptState next) {
    _state = next;
    onStateChanged?.call(next);
    return next;
  }
}
