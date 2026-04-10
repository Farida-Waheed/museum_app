import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceAssistantService {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _speechAvailable = false;
  bool _ttsAvailable = false;

  bool get speechAvailable => _speechAvailable;
  bool get ttsAvailable => _ttsAvailable;

  bool isListening = false;
  bool isSpeaking = false;
  String lastEngineLocale = 'en-US';

  Future<void> init() async {
    try {
      _speechAvailable = await _speech.initialize(
        onError: (error) {},
        onStatus: (status) {},
      );
    } catch (_) {
      _speechAvailable = false;
    }

    try {
      _ttsAvailable = true;
      await _tts.setSharedInstance(true);
      _tts.setStartHandler(() {
        isSpeaking = true;
      });
      _tts.setCompletionHandler(() {
        isSpeaking = false;
      });
      _tts.setErrorHandler((message) {
        isSpeaking = false;
      });
    } catch (_) {
      _ttsAvailable = false;
    }
  }

  String speechLocaleForLanguage(String language) {
    return language == 'ar' ? 'ar-EG' : 'en-US';
  }

  String ttsLocaleForLanguage(String language) {
    return language == 'ar' ? 'ar-EG' : 'en-US';
  }

  Future<bool> startListening({
    required String localeId,
    required ValueChanged<String> onResult,
    required ValueChanged<bool> onFinalResult,
  }) async {
    if (!_speechAvailable) {
      return false;
    }

    isListening = true;
    try {
      await _speech.listen(
        localeId: localeId,
        onResult: (result) {
          onResult(result.recognizedWords);
          if (result.finalResult) {
            onFinalResult(true);
          }
        },
        listenMode: ListenMode.confirmation,
        partialResults: true,
        pauseFor: const Duration(seconds: 2),
      );
      return true;
    } catch (_) {
      isListening = false;
      return false;
    }
  }

  Future<void> stopListening() async {
    if (!_speechAvailable || !isListening) return;
    await _speech.stop();
    isListening = false;
  }

  Future<bool> speak(String text, String language) async {
    if (!_ttsAvailable || text.trim().isEmpty) return false;
    try {
      await _tts.stop();
      final locale = ttsLocaleForLanguage(language);
      if (locale != lastEngineLocale) {
        await _tts.setLanguage(locale);
        lastEngineLocale = locale;
      }
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);
      await _tts.speak(text);
      return true;
    } catch (_) {
      isSpeaking = false;
      return false;
    }
  }

  Future<void> stopSpeaking() async {
    if (!_ttsAvailable) return;
    await _tts.stop();
    isSpeaking = false;
  }
}
