import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../constants/voice_constants.dart';
import '../enums/voice_enums.dart';
import 'speech_recognizer.dart';

/// Production [SpeechRecognizer] backed by the `speech_to_text` plugin. This is
/// the ONLY place in the app that imports `speech_to_text`; everything upstream
/// depends on the abstract [SpeechRecognizer], so the recognizer can later be
/// swapped for an on-device or cloud engine without touching a single caller.
///
/// Permission and availability are handled here and reported through the
/// [SpeechRecognitionResult.outcome], so a denied mic degrades to touch controls
/// instead of throwing — the rest of the voice engine is unaffected.
class SpeechToTextRecognizer implements SpeechRecognizer {
  SpeechToTextRecognizer({stt.SpeechToText? speech})
      : _speech = speech ?? stt.SpeechToText();

  final stt.SpeechToText _speech;
  bool _available = false;
  bool _initialized = false;

  @override
  bool get isAvailable => _available;

  @override
  bool get isListening => _speech.isListening;

  @override
  Future<bool> initialize() async {
    if (_initialized) return _available;
    _initialized = true;
    try {
      _available = await _speech.initialize(
        onError: (e) => debugPrint('SpeechToTextRecognizer error: ${e.errorMsg}'),
        onStatus: (s) => debugPrint('SpeechToTextRecognizer status: $s'),
      );
      return _available;
    } catch (e, s) {
      debugPrint('SpeechToTextRecognizer init failed: $e\n$s');
      _available = false;
      return false;
    }
  }

  @override
  Future<SpeechRecognitionResult> listen({
    required VoiceLanguage language,
    void Function(String partial)? onPartial,
  }) async {
    if (!_available) {
      // Try a late init (permission may have been granted since).
      final ok = await initialize();
      if (!ok) {
        return SpeechRecognitionResult(
          outcome: _speech.isAvailable
              ? SpeechRecognitionOutcome.unavailable
              : SpeechRecognitionOutcome.permissionDenied,
          language: language,
        );
      }
    }

    final completer = Completer<SpeechRecognitionResult>();
    var finished = false;
    void finish(SpeechRecognitionResult r) {
      if (finished) return;
      finished = true;
      if (!completer.isCompleted) completer.complete(r);
    }

    try {
      await _speech.listen(
        localeId: language.bcp47,
        listenFor: VoiceConstants.listenTimeout,
        pauseFor: VoiceConstants.listenPauseTimeout,
        onResult: (result) {
          onPartial?.call(result.recognizedWords);
          if (result.finalResult) {
            final words = result.recognizedWords.trim();
            finish(SpeechRecognitionResult(
              outcome: words.isEmpty
                  ? SpeechRecognitionOutcome.noSpeech
                  : SpeechRecognitionOutcome.success,
              transcript: words,
              confidence: result.hasConfidenceRating ? result.confidence : 0.8,
              language: language,
            ));
          }
        },
      );
    } catch (e) {
      debugPrint('SpeechToTextRecognizer listen error: $e');
      finish(SpeechRecognitionResult(
        outcome: SpeechRecognitionOutcome.error,
        language: language,
      ));
    }

    // Safety timeout so we never hang if no final result arrives.
    Timer(VoiceConstants.listenTimeout + const Duration(seconds: 2), () async {
      if (!finished) {
        await stop();
        finish(SpeechRecognitionResult(
          outcome: SpeechRecognitionOutcome.noSpeech,
          language: language,
        ));
      }
    });

    return completer.future;
  }

  @override
  Future<void> stop() async {
    try {
      await _speech.stop();
    } catch (e) {
      debugPrint('SpeechToTextRecognizer stop error: $e');
    }
  }

  @override
  Future<void> cancel() async {
    try {
      await _speech.cancel();
    } catch (e) {
      debugPrint('SpeechToTextRecognizer cancel error: $e');
    }
  }

  @override
  Future<void> dispose() async {
    await cancel();
  }
}
