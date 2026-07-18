import 'dart:async';

import '../prompt/narration_prompt.dart';
import 'narration_generation_result.dart';
import 'narration_generator.dart';

/// Runs a [NarrationPrompt] through the app's existing AI infrastructure (via an
/// injected [NarrationCompletion]) and returns a structured
/// [NarrationGenerationResult]. It reuses whatever `ChatProvider` already calls —
/// this class adds NO second AI client and imports no backend/network code.
///
/// It is deliberately narrow (SRP): it only consumes a prompt and classifies the
/// outcome. It does NOT build prompts, read the AccessibilityProfile or
/// ExhibitMetadata, or re-derive any NarrationPolicy decision — all of that
/// happened in Tasks 2–4.
///
/// Failure handling: it never throws to the caller. A timeout, backend error,
/// malformed response, empty text, or cancellation each maps to a distinct
/// [NarrationGenerationStatus] with optional diagnostics, so Task 7 decides how
/// to fall back.
class AiNarrationGenerator implements NarrationGenerator {
  AiNarrationGenerator({
    required NarrationCompletion completion,
    Duration timeout = const Duration(seconds: 20),
    Future<bool> Function()? isCancelled,
  })  : _completion = completion,
        _timeout = timeout,
        _isCancelled = isCancelled;

  final NarrationCompletion _completion;
  final Duration _timeout;

  /// Optional cooperative cancellation check, polled before and after the call
  /// (e.g. the visitor skipped to the next exhibit). When it resolves true the
  /// result is [NarrationGenerationStatus.cancelled].
  final Future<bool> Function()? _isCancelled;

  @override
  Future<NarrationGenerationResult> generate(NarrationPrompt prompt) async {
    final stopwatch = Stopwatch()..start();

    // Pre-flight cancellation: don't even start if we're already cancelled.
    if (await _cancelled()) {
      return NarrationGenerationResult.failure(
        NarrationGenerationStatus.cancelled,
        duration: stopwatch.elapsed,
      );
    }

    try {
      final raw = await _completion(prompt).timeout(_timeout);

      // Cancelled while the AI was working → discard the (now unwanted) answer.
      if (await _cancelled()) {
        return NarrationGenerationResult.failure(
          NarrationGenerationStatus.cancelled,
          duration: stopwatch.elapsed,
        );
      }

      final text = raw.trim();
      if (text.isEmpty) {
        return NarrationGenerationResult.failure(
          NarrationGenerationStatus.emptyResponse,
          duration: stopwatch.elapsed,
          diagnostics: 'AI returned empty/whitespace-only text',
        );
      }

      return NarrationGenerationResult.success(
        text,
        duration: stopwatch.elapsed,
      );
    } on TimeoutException catch (e) {
      return NarrationGenerationResult.failure(
        NarrationGenerationStatus.timeout,
        duration: stopwatch.elapsed,
        diagnostics: 'AI timed out after ${_timeout.inMilliseconds}ms'
            '${e.message != null ? ': ${e.message}' : ''}',
      );
    } on FormatException catch (e) {
      // The completion signals an unparseable / malformed response this way.
      return NarrationGenerationResult.failure(
        NarrationGenerationStatus.malformedResponse,
        duration: stopwatch.elapsed,
        diagnostics: 'Malformed AI response: ${e.message}',
      );
    } catch (e) {
      return NarrationGenerationResult.failure(
        NarrationGenerationStatus.aiFailure,
        duration: stopwatch.elapsed,
        diagnostics: 'AI generation failed: $e',
      );
    }
  }

  Future<bool> _cancelled() async {
    final check = _isCancelled;
    if (check == null) return false;
    try {
      return await check();
    } catch (_) {
      // A faulty cancellation probe must not itself break generation.
      return false;
    }
  }
}
