import 'dart:async';

import '../models/speech_config.dart';
import '../models/voice_content.dart';
import 'tts_engine.dart';

/// Deterministic in-memory [TtsEngine] for unit tests and as a safe fallback on
/// platforms without TTS. Records every call and lets a test control timing.
///
/// It never touches a plugin, so the entire engine — queue, coordinator,
/// controller — is testable end-to-end with no Flutter binding.
class FakeTtsEngine implements TtsEngine {
  FakeTtsEngine({
    this.available = true,
    this.speakDuration = Duration.zero,
    this.throwOnSpeak = false,
  });

  /// Whether [initialize] reports the backend as available.
  bool available;

  /// Simulated speaking time; keep [Duration.zero] for instant tests.
  Duration speakDuration;

  /// When true, [speak] simulates a backend failure (returns normally, records
  /// nothing spoken) to exercise error resilience.
  bool throwOnSpeak;

  bool _initialized = false;
  bool _available = false;

  /// Everything that was spoken, in order (flattened text).
  final List<String> spoken = <String>[];

  /// Every config applied, in order.
  final List<SpeechConfig> appliedConfigs = <SpeechConfig>[];

  int stopCount = 0;
  int pauseCount = 0;
  int resumeCount = 0;

  Completer<void>? _current;
  void Function()? _onComplete;

  @override
  Future<bool> initialize() async {
    _initialized = true;
    _available = available;
    return _available;
  }

  @override
  bool get isAvailable => _initialized && _available;

  @override
  Future<void> applyConfig(SpeechConfig config) async {
    appliedConfigs.add(config);
  }

  @override
  Future<void> speak(VoiceContent content, SpeechConfig config) async {
    if (!isAvailable || throwOnSpeak) return;
    _current = Completer<void>();
    if (speakDuration == Duration.zero) {
      spoken.add(content.plainText);
      _finishCurrent();
    } else {
      Timer(speakDuration, () {
        spoken.add(content.plainText);
        _finishCurrent();
      });
    }
    await _current!.future;
  }

  void _finishCurrent() {
    final c = _current;
    _current = null;
    if (c != null && !c.isCompleted) c.complete();
    _onComplete?.call();
  }

  @override
  Future<void> stop() async {
    stopCount++;
    final c = _current;
    _current = null;
    if (c != null && !c.isCompleted) c.complete();
  }

  @override
  Future<void> pause() async {
    pauseCount++;
  }

  @override
  Future<void> resume() async {
    resumeCount++;
  }

  @override
  set onComplete(void Function()? handler) => _onComplete = handler;

  @override
  Future<void> dispose() async {
    await stop();
  }
}
