import 'package:flutter_test/flutter_test.dart';
import 'package:museum_app/audio_description/ai/narration_generation_result.dart';
import 'package:museum_app/audio_description/models/exhibit_id.dart';
import 'package:museum_app/audio_description/transcript/narration_transcript.dart';
import 'package:museum_app/audio_description/transcript/sentence_segmenter.dart';
import 'package:museum_app/audio_description/transcript/transcript_controller.dart';
import 'package:museum_app/audio_description/transcript/transcript_segment.dart';
import 'package:museum_app/audio_description/transcript/transcript_state.dart';
import 'package:museum_app/audio_description/transcript/transcript_status.dart';

/// Phase 4 Task 10 — Transcript & Sentence Synchronization tests.
///
/// The transcript layer is pure orchestration/state management. These tests use
/// the real (pure) [DefaultSentenceSegmenter] and drive progress through the
/// controller's own API — no TTS, AI, timers, or robot logic involved. A tiny
/// [_FakeSegmenter] proves the segmenter is a DI seam.
void main() {
  final exhibit = ExhibitId('rosetta-stone');
  final other = ExhibitId('sphinx');
  const threeSentences =
      'The stone is dark granodiorite. It carries three scripts. '
      'It unlocked hieroglyphs.';

  TranscriptController build({SentenceSegmenter? segmenter}) =>
      segmenter == null
          ? TranscriptController()
          : TranscriptController(segmenter: segmenter);

  group('transcript creation', () {
    test('begin builds an active transcript with the first segment active', () {
      final c = build();

      final state = c.begin(exhibitId: exhibit, narration: threeSentences);

      expect(state.status, TranscriptStatus.active);
      expect(state.transcript, isNotNull);
      expect(state.transcript!.exhibitId, exhibit);
      expect(state.transcript!.fullText, threeSentences);
      expect(state.activeIndex, 0);
      expect(state.totalCount, 3);
    });

    test('beginFromResult uses the narration of a successful result', () {
      final c = build();

      final state = c.beginFromResult(
        exhibitId: exhibit,
        result: NarrationGenerationResult.success('One. Two.'),
      );

      expect(state.status, TranscriptStatus.active);
      expect(state.totalCount, 2);
    });

    test('beginFromResult with a failed result → empty completed transcript',
        () {
      final c = build();

      final state = c.beginFromResult(
        exhibitId: exhibit,
        result: NarrationGenerationResult.failure(
            NarrationGenerationStatus.aiFailure),
      );

      expect(state.status, TranscriptStatus.completed);
      expect(state.totalCount, 0);
    });
  });

  group('sentence segmentation', () {
    test('splits on . ! ? and keeps terminators, preserving offsets', () {
      const text = 'First sentence. Second one! Third?';
      final segments = const DefaultSentenceSegmenter().segment(text);

      expect(segments.map((s) => s.text).toList(), [
        'First sentence.',
        'Second one!',
        'Third?',
      ]);
      // Offsets point back at the original text.
      for (final s in segments) {
        expect(text.substring(s.start, s.end), s.text);
      }
      expect(segments.map((s) => s.index).toList(), [0, 1, 2]);
    });

    test('trailing text without a terminator becomes a final segment', () {
      final segments =
          const DefaultSentenceSegmenter().segment('Done. And more');
      expect(segments.map((s) => s.text).toList(), ['Done.', 'And more']);
    });

    test('consecutive terminators collapse into one segment', () {
      final segments =
          const DefaultSentenceSegmenter().segment('Really?! Yes...');
      expect(segments.map((s) => s.text).toList(), ['Really?!', 'Yes...']);
    });

    test('Arabic question mark is a terminator', () {
      final segments =
          const DefaultSentenceSegmenter().segment('ما هذا؟ إنه حجر.');
      expect(segments.length, 2);
    });
  });

  group('current segment progression', () {
    test('advance walks forward one segment at a time', () {
      final c = build()..begin(exhibitId: exhibit, narration: threeSentences);

      expect(c.advance().activeIndex, 1);
      expect(c.advance().activeIndex, 2);
      // Advancing past the last segment completes.
      final done = c.advance();
      expect(done.status, TranscriptStatus.completed);
      expect(done.activeIndex, 2);
    });

    test('advanceTo jumps forward and updates spoken count / progress', () {
      final c = build()..begin(exhibitId: exhibit, narration: threeSentences);

      final s = c.advanceTo(2);
      expect(s.activeIndex, 2);
      expect(s.spokenCount, 2);
      expect(s.progress, closeTo(2 / 3, 1e-9));
      expect(s.activeSegment, isNotNull);
    });

    test('activeSegment resolves to the right transcript segment', () {
      final c = build()..begin(exhibitId: exhibit, narration: threeSentences);
      c.advanceTo(1);
      expect(c.state.activeSegment!.text, 'It carries three scripts.');
    });
  });

  group('repeated / non-forward progress updates', () {
    test('re-reporting the same segment is idempotent', () {
      final c = build()..begin(exhibitId: exhibit, narration: threeSentences);
      c.advanceTo(1);

      final again = c.advanceTo(1);
      expect(again.activeIndex, 1);
    });

    test('a lower index (rewind) is ignored', () {
      final c = build()..begin(exhibitId: exhibit, narration: threeSentences);
      c.advanceTo(2);

      final back = c.advanceTo(0);
      expect(back.activeIndex, 2);
    });
  });

  group('pause', () {
    test('pause holds the active segment and stops progress', () {
      final c = build()..begin(exhibitId: exhibit, narration: threeSentences);
      c.advanceTo(1);

      final paused = c.pause();
      expect(paused.status, TranscriptStatus.paused);
      expect(paused.activeIndex, 1);

      // Progress is a no-op while paused.
      final blocked = c.advanceTo(2);
      expect(blocked.status, TranscriptStatus.paused);
      expect(blocked.activeIndex, 1);
    });

    test('pause is a no-op when not active', () {
      final c = build();
      expect(c.pause().status, TranscriptStatus.idle);
    });
  });

  group('resume', () {
    test('resume returns to active and lets progress continue', () {
      final c = build()..begin(exhibitId: exhibit, narration: threeSentences);
      c.advanceTo(1);
      c.pause();

      final resumed = c.resume();
      expect(resumed.status, TranscriptStatus.active);
      expect(resumed.activeIndex, 1);

      expect(c.advanceTo(2).activeIndex, 2);
    });

    test('resume is a no-op when not paused', () {
      final c = build()..begin(exhibitId: exhibit, narration: threeSentences);
      expect(c.resume().status, TranscriptStatus.active);
    });
  });

  group('cancel', () {
    test('cancel abandons an active transcript', () {
      final c = build()..begin(exhibitId: exhibit, narration: threeSentences);
      c.advanceTo(1);

      final cancelled = c.cancel();
      expect(cancelled.status, TranscriptStatus.cancelled);
      // Progress after cancel is ignored.
      expect(c.advanceTo(2).status, TranscriptStatus.cancelled);
    });

    test('cancel is a no-op when idle or terminal', () {
      final c = build();
      expect(c.cancel().status, TranscriptStatus.idle);

      c.begin(exhibitId: exhibit, narration: 'One.');
      c.complete();
      expect(c.cancel().status, TranscriptStatus.completed);
    });
  });

  group('completion', () {
    test('complete marks everything spoken with full progress', () {
      final c = build()..begin(exhibitId: exhibit, narration: threeSentences);

      final done = c.complete();
      expect(done.status, TranscriptStatus.completed);
      expect(done.spokenCount, 3);
      expect(done.progress, 1.0);
      expect(done.activeIndex, 2);
    });

    test('progress after completion is ignored', () {
      final c = build()..begin(exhibitId: exhibit, narration: threeSentences);
      c.complete();
      expect(c.advance().status, TranscriptStatus.completed);
    });
  });

  group('new exhibit resets transcript', () {
    test('begin for a new exhibit supersedes the previous transcript', () {
      final c = build()..begin(exhibitId: exhibit, narration: threeSentences);
      c.advanceTo(2);

      final fresh = c.begin(exhibitId: other, narration: 'Alpha. Beta.');
      expect(fresh.status, TranscriptStatus.active);
      expect(fresh.transcript!.exhibitId, other);
      expect(fresh.activeIndex, 0);
      expect(fresh.totalCount, 2);
    });

    test('reset returns to the idle initial state', () {
      final c = build()..begin(exhibitId: exhibit, narration: threeSentences);

      final reset = c.reset();
      expect(reset.status, TranscriptStatus.idle);
      expect(reset.transcript, isNull);
      expect(identical(reset, TranscriptState.initial), isTrue);
    });
  });

  group('empty narration', () {
    test('empty text → empty, immediately completed transcript', () {
      final c = build();

      final state = c.begin(exhibitId: exhibit, narration: '   ');
      expect(state.status, TranscriptStatus.completed);
      expect(state.totalCount, 0);
      expect(state.activeSegment, isNull);
      expect(state.progress, 1.0);
    });
  });

  group('single sentence narration', () {
    test('one sentence → one segment, advance completes', () {
      final c = build();

      final state = c.begin(exhibitId: exhibit, narration: 'Just one sentence.');
      expect(state.totalCount, 1);
      expect(state.activeIndex, 0);

      final done = c.advance();
      expect(done.status, TranscriptStatus.completed);
      expect(done.progress, 1.0);
    });

    test('single sentence with no terminator still yields one segment', () {
      final segments =
          const DefaultSentenceSegmenter().segment('no terminator here');
      expect(segments.length, 1);
      expect(segments.single.text, 'no terminator here');
    });
  });

  group('state transitions', () {
    test('published state always equals controller.state', () {
      final c = build();
      c.onStateChanged = (s) => expect(identical(c.state, s), isTrue);
      c.begin(exhibitId: exhibit, narration: threeSentences);
      c.advance();
      c.pause();
      c.resume();
      c.complete();
    });

    test('every transition is published in order', () {
      final c = build();
      final seen = <TranscriptStatus>[];
      c.onStateChanged = (s) => seen.add(s.status);

      c.begin(exhibitId: exhibit, narration: threeSentences); // active
      c.pause(); // paused
      c.resume(); // active
      c.complete(); // completed

      expect(seen, [
        TranscriptStatus.active,
        TranscriptStatus.paused,
        TranscriptStatus.active,
        TranscriptStatus.completed,
      ]);
    });
  });

  group('segmenter is a DI seam', () {
    test('a custom segmenter is used instead of the default', () {
      final c = build(segmenter: _FakeSegmenter());

      final state = c.begin(exhibitId: exhibit, narration: 'ignored input');
      expect(state.totalCount, 2);
      expect(state.transcript!.segments.map((s) => s.text).toList(),
          ['fake-a', 'fake-b']);
    });
  });

  group('NarrationTranscript model', () {
    test('build produces an unmodifiable segment list', () {
      final t = NarrationTranscript.build(
          exhibitId: exhibit, narration: 'One. Two.');
      expect(() => t.segments.add(const TranscriptSegment(
            index: 9,
            text: 'x',
            start: 0,
            end: 1,
          )), throwsUnsupportedError);
    });

    test('segmentAt returns null out of range', () {
      final t = NarrationTranscript.build(
          exhibitId: exhibit, narration: 'One.');
      expect(t.segmentAt(-1), isNull);
      expect(t.segmentAt(0), isNotNull);
      expect(t.segmentAt(5), isNull);
    });
  });
}

/// A segmenter that ignores its input and returns a fixed pair, proving the
/// controller delegates splitting to the injected seam.
class _FakeSegmenter implements SentenceSegmenter {
  @override
  List<TranscriptSegment> segment(String narration) => const [
        TranscriptSegment(index: 0, text: 'fake-a', start: 0, end: 6),
        TranscriptSegment(index: 1, text: 'fake-b', start: 7, end: 13),
      ];
}
