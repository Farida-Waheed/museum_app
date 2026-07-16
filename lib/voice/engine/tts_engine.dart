import '../models/speech_config.dart';
import '../models/voice_content.dart';

/// Abstract text-to-speech backend. This is the ONLY speech-synthesis contract
/// the rest of the engine knows about — no widget, service, or coordinator ever
/// imports `flutter_tts` directly (DIP, exactly like the accessibility module's
/// repository interface).
///
/// Implementations:
/// * `FlutterTtsEngine`  — production, wraps the `flutter_tts` plugin.
/// * `FakeTtsEngine`     — deterministic, records calls, used by every unit test.
/// * (future) a cloud-TTS or robot-TTS engine drops in here with no other change.
abstract class TtsEngine {
  /// Prepare the backend (query available voices/languages, set handlers).
  /// Returns false if TTS is unavailable on this device — the engine then
  /// degrades to a silent/visual experience instead of failing.
  Future<bool> initialize();

  /// Whether initialization succeeded and speech can be produced.
  bool get isAvailable;

  /// Apply voice parameters (rate/pitch/volume/language/gender) before speaking.
  Future<void> applyConfig(SpeechConfig config);

  /// Speak [content] to completion using [config]. Must honour the segment
  /// pauses/emphasis where the backend supports it and fall back to plain text
  /// otherwise. Completes when playback finishes or is stopped.
  ///
  /// Implementations must not throw on backend errors — return normally so the
  /// queue keeps draining.
  Future<void> speak(VoiceContent content, SpeechConfig config);

  /// Stop any current utterance immediately (used by interruptions / "stop").
  Future<void> stop();

  /// Pause / resume the current utterance where supported.
  Future<void> pause();
  Future<void> resume();

  /// Called when a spoken utterance finishes on its own — set by the coordinator
  /// so it can advance the queue. Optional; the coordinator also awaits [speak].
  set onComplete(void Function()? handler);

  Future<void> dispose();
}
