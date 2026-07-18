import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:museum_app/audio_description/ai/ai_narration_generator.dart';
import 'package:museum_app/audio_description/ai/narration_generation_result.dart';
import 'package:museum_app/audio_description/ai/narration_generator.dart';
import 'package:museum_app/audio_description/models/audio_description_enums.dart';
import 'package:museum_app/audio_description/prompt/narration_prompt.dart';

/// Phase 4 Task 5 — AI narration generator tests.
///
/// Every test injects a FAKE [NarrationCompletion] (the seam over the app's
/// existing AI infra). The real AI service is never called. The generator must
/// never throw — each failure mode must resolve to a distinct structured status.
void main() {
  const prompt = NarrationPrompt(
    systemPrompt: 'You are Horus.',
    userPrompt: 'Describe the Rosetta Stone.',
    language: 'en',
    length: NarrationLength.standard,
    layers: [StoryLayer.visual, StoryLayer.historical],
  );

  AiNarrationGenerator generator(
    NarrationCompletion completion, {
    Duration timeout = const Duration(seconds: 20),
    Future<bool> Function()? isCancelled,
  }) =>
      AiNarrationGenerator(
        completion: completion,
        timeout: timeout,
        isCancelled: isCancelled,
      );

  group('success', () {
    test('returns trimmed narration, ai source, measured duration', () async {
      final gen = generator((_) async => '  A tall basalt slab of decrees.  ');

      final result = await gen.generate(prompt);

      expect(result.status, NarrationGenerationStatus.success);
      expect(result.isSuccess, isTrue);
      expect(result.narration, 'A tall basalt slab of decrees.');
      expect(result.source, NarrationSource.ai);
      expect(result.fallbackUsed, isFalse);
      expect(result.duration, isNotNull);
    });

    test('forwards the exact prompt it was given to the completion', () async {
      NarrationPrompt? seen;
      final gen = generator((p) async {
        seen = p;
        return 'ok';
      });

      await gen.generate(prompt);

      expect(identical(seen, prompt), isTrue);
    });
  });

  group('timeout', () {
    test('a completion that never resolves in time → timeout status', () async {
      final gen = generator(
        (_) => Completer<String>().future, // never completes
        timeout: const Duration(milliseconds: 30),
      );

      final result = await gen.generate(prompt);

      expect(result.status, NarrationGenerationStatus.timeout);
      expect(result.isSuccess, isFalse);
      expect(result.narration, isNull);
      expect(result.diagnostics, contains('timed out'));
    });

    test('an explicit TimeoutException from the backend → timeout status',
        () async {
      final gen = generator((_) async => throw TimeoutException('backend slow'));

      final result = await gen.generate(prompt);

      expect(result.status, NarrationGenerationStatus.timeout);
    });
  });

  group('ai failure', () {
    test('a thrown backend error → aiFailure with diagnostics', () async {
      final gen = generator((_) async => throw StateError('backend exploded'));

      final result = await gen.generate(prompt);

      expect(result.status, NarrationGenerationStatus.aiFailure);
      expect(result.source, NarrationSource.none);
      expect(result.diagnostics, contains('backend exploded'));
    });
  });

  group('malformed response', () {
    test('a FormatException from the completion → malformedResponse', () async {
      final gen = generator(
        (_) async => throw const FormatException('not valid narration JSON'),
      );

      final result = await gen.generate(prompt);

      expect(result.status, NarrationGenerationStatus.malformedResponse);
      expect(result.diagnostics, contains('Malformed'));
    });
  });

  group('empty response', () {
    test('empty string → emptyResponse', () async {
      final gen = generator((_) async => '');
      final result = await gen.generate(prompt);
      expect(result.status, NarrationGenerationStatus.emptyResponse);
      expect(result.isSuccess, isFalse);
    });

    test('whitespace-only string → emptyResponse', () async {
      final gen = generator((_) async => '   \n\t ');
      final result = await gen.generate(prompt);
      expect(result.status, NarrationGenerationStatus.emptyResponse);
    });
  });

  group('cancellation', () {
    test('pre-flight cancellation short-circuits before calling the AI',
        () async {
      var called = false;
      final gen = generator(
        (_) async {
          called = true;
          return 'should not run';
        },
        isCancelled: () async => true,
      );

      final result = await gen.generate(prompt);

      expect(result.status, NarrationGenerationStatus.cancelled);
      expect(called, isFalse, reason: 'must not hit the AI once cancelled');
    });

    test('cancellation after the AI responds discards the answer', () async {
      var checks = 0;
      final gen = generator(
        (_) async => 'a valid but now-unwanted narration',
        // false on the pre-flight check, true once the answer is back.
        isCancelled: () async => checks++ > 0,
      );

      final result = await gen.generate(prompt);

      expect(result.status, NarrationGenerationStatus.cancelled);
      expect(result.narration, isNull);
    });

    test('a throwing cancellation probe is treated as not-cancelled', () async {
      final gen = generator(
        (_) async => 'narration',
        isCancelled: () async => throw StateError('probe fault'),
      );

      final result = await gen.generate(prompt);

      expect(result.status, NarrationGenerationStatus.success);
    });
  });

  group('diagnostics & structured failure object', () {
    test('every failure carries a duration and never a narration', () async {
      final failures = <NarrationGenerationResult>[
        await generator((_) async => throw StateError('x')).generate(prompt),
        await generator((_) async => '').generate(prompt),
        await generator(
          (_) async => throw const FormatException('m'),
        ).generate(prompt),
      ];

      for (final r in failures) {
        expect(r.isSuccess, isFalse);
        expect(r.narration, isNull);
        expect(r.duration, isNotNull);
        expect(r.source, NarrationSource.none);
      }
    });

    test('the generator never throws, even on a synchronous completion throw',
        () async {
      final gen = generator((_) => throw StateError('sync throw'));
      // Should complete normally with a structured failure, not rethrow.
      final result = await gen.generate(prompt);
      expect(result.status, NarrationGenerationStatus.aiFailure);
    });

    test('success result exposes a clean toString without diagnostics', () {
      final r = NarrationGenerationResult.success('hi');
      expect(r.toString(), contains('success'));
      expect(r.toString(), contains('ai'));
    });

    test('fallbackUsed can be layered on by a higher tier via copyWith', () {
      final r = NarrationGenerationResult.failure(
        NarrationGenerationStatus.aiFailure,
      ).copyWith(fallbackUsed: true, source: NarrationSource.fallback);
      expect(r.fallbackUsed, isTrue);
      expect(r.source, NarrationSource.fallback);
    });
  });
}
