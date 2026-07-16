import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../constants/voice_constants.dart';
import '../enums/voice_enums.dart';
import '../models/speech_config.dart';
import '../models/voice_content.dart';
import 'tts_engine.dart';

/// Production [TtsEngine] backed by the `flutter_tts` plugin. This is the ONLY
/// place in the app that imports `flutter_tts`; everything upstream depends on
/// the abstract [TtsEngine], so the plugin can be replaced by a cloud/robot TTS
/// engine without touching a single caller.
///
/// It renders a [VoiceContent] segment-by-segment so pauses and emphasis are
/// honoured (raising pitch / slowing rate briefly on emphasised segments and
/// inserting real silence between segments) — the difference between "reading
/// aloud" and speech that "sounds intentional". Pronunciation overrides are
/// applied as plain text substitutions, which works on every backend.
///
/// Every plugin call is guarded: a backend error never throws to the coordinator,
/// so the queue keeps draining and the app never breaks because TTS hiccuped.
class FlutterTtsEngine implements TtsEngine {
  FlutterTtsEngine({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _available = false;
  bool _initialized = false;
  void Function()? _onComplete;

  /// The last language we configured on the backend, to avoid redundant calls.
  String? _appliedLocale;

  @override
  bool get isAvailable => _available;

  @override
  Future<bool> initialize() async {
    if (_initialized) return _available;
    _initialized = true;
    try {
      // Resolve after each utterance so [speak] awaits completion — this is what
      // lets the queue advance exactly when a message finishes.
      await _tts.awaitSpeakCompletion(true);
      _tts.setCompletionHandler(() => _onComplete?.call());
      _tts.setErrorHandler((msg) {
        debugPrint('FlutterTtsEngine error: $msg');
        _onComplete?.call();
      });
      // Availability heuristic: languages can be enumerated.
      final languages = await _tts.getLanguages;
      _available = languages is List && languages.isNotEmpty;
      return _available;
    } catch (e, s) {
      debugPrint('FlutterTtsEngine init failed: $e\n$s');
      _available = false;
      return false;
    }
  }

  @override
  Future<void> applyConfig(SpeechConfig config) async {
    if (!_available) return;
    try {
      final locale = config.language.bcp47;
      if (_appliedLocale != locale) {
        await _tts.setLanguage(locale);
        _appliedLocale = locale;
        await _applyGender(config.gender, config.language);
      }
      await _tts.setSpeechRate(_mapRate(config.rate));
      await _tts.setPitch(config.pitch
          .clamp(VoiceConstants.minPitch, VoiceConstants.maxPitch)
          .toDouble());
      await _tts.setVolume(config.volume
          .clamp(VoiceConstants.minVolume, VoiceConstants.maxVolume)
          .toDouble());
    } catch (e) {
      debugPrint('FlutterTtsEngine applyConfig error: $e');
    }
  }

  @override
  Future<void> speak(VoiceContent content, SpeechConfig config) async {
    if (!_available) return;
    await applyConfig(config);
    for (final segment in content.segments) {
      final text = _applyPronunciations(segment.text, content.pronunciations);
      if (text.trim().isEmpty) continue;
      try {
        if (segment.emphasize) {
          // Briefly slow down and lift pitch to mark a name/title, then restore.
          await _tts.setSpeechRate(_mapRate(config.rate * 0.9));
          await _tts.setPitch((config.pitch + 0.08)
              .clamp(VoiceConstants.minPitch, VoiceConstants.maxPitch)
              .toDouble());
          await _tts.speak(text);
          await _tts.setSpeechRate(_mapRate(config.rate));
          await _tts.setPitch(config.pitch);
        } else {
          await _tts.speak(text);
        }
      } catch (e) {
        debugPrint('FlutterTtsEngine speak error: $e');
        return; // bail out of this message; coordinator moves on
      }
      if (segment.pauseAfter > Duration.zero) {
        await Future<void>.delayed(segment.pauseAfter);
      }
    }
  }

  Future<void> _applyGender(VoiceGender gender, VoiceLanguage language) async {
    if (gender == VoiceGender.system) return;
    try {
      final voices = await _tts.getVoices;
      if (voices is! List) return;
      final wanted = gender == VoiceGender.female ? 'female' : 'male';
      for (final v in voices) {
        if (v is! Map) continue;
        final name = '${v['name'] ?? ''}'.toLowerCase();
        final locale = '${v['locale'] ?? ''}'.toLowerCase();
        if (locale.startsWith(language.code) && name.contains(wanted)) {
          await _tts.setVoice({
            'name': '${v['name']}',
            'locale': '${v['locale']}',
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('FlutterTtsEngine gender select skipped: $e');
    }
  }

  /// Our config rate is a 0.5..1.5 multiplier around "normal"; flutter_tts wants
  /// 0.0..1.0 where ~0.5 is a natural pace on Android. Map so 1.0 → 0.5.
  double _mapRate(double multiplier) {
    final m = multiplier
        .clamp(VoiceConstants.minSpeechRate, VoiceConstants.maxSpeechRate)
        .toDouble();
    return (m * 0.5).clamp(0.0, 1.0).toDouble();
  }

  String _applyPronunciations(String text, Map<String, String> map) {
    if (map.isEmpty) return text;
    var out = text;
    map.forEach((from, to) {
      if (from.trim().isEmpty) return;
      out = out.replaceAll(from, to);
    });
    return out;
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('FlutterTtsEngine stop error: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _tts.pause();
    } catch (e) {
      debugPrint('FlutterTtsEngine pause error: $e');
    }
  }

  @override
  Future<void> resume() async {
    // flutter_tts has no universal resume; the coordinator re-speaks the pending
    // message instead. Kept for interface symmetry.
  }

  @override
  set onComplete(void Function()? handler) => _onComplete = handler;

  @override
  Future<void> dispose() async {
    await stop();
  }
}
