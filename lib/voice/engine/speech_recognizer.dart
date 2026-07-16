import '../enums/voice_enums.dart';

/// Outcome of a single listen attempt, so callers can distinguish "no speech"
/// from "permission denied" from "backend unavailable" and fall back correctly.
enum SpeechRecognitionOutcome {
  success('success'),
  noSpeech('no_speech'),
  permissionDenied('permission_denied'),
  unavailable('unavailable'),
  error('error');

  const SpeechRecognitionOutcome(this.storageKey);
  final String storageKey;

  bool get isFallbackToTouch =>
      this == permissionDenied || this == unavailable || this == error;
}

/// The result of one recognition session.
class SpeechRecognitionResult {
  final SpeechRecognitionOutcome outcome;
  final String transcript;
  final double confidence;
  final VoiceLanguage language;

  const SpeechRecognitionResult({
    required this.outcome,
    this.transcript = '',
    this.confidence = 0.0,
    this.language = VoiceLanguage.english,
  });

  const SpeechRecognitionResult.unavailable()
      : outcome = SpeechRecognitionOutcome.unavailable,
        transcript = '',
        confidence = 0.0,
        language = VoiceLanguage.english;

  bool get hasTranscript =>
      outcome == SpeechRecognitionOutcome.success && transcript.trim().isNotEmpty;
}

/// Abstract speech-recognition backend — the sole microphone/STT contract the
/// engine depends on. No widget or service imports `speech_to_text` directly.
///
/// Implementations:
/// * `SpeechToTextRecognizer` — production, wraps the `speech_to_text` plugin
///   incl. permission handling.
/// * `FakeSpeechRecognizer`   — scripted transcripts for tests.
/// * (future) an on-device or cloud recognizer drops in unchanged.
///
/// If the mic is unavailable or permission is denied, [listen] returns a result
/// whose [SpeechRecognitionResult.outcome] signals a graceful fallback to touch;
/// it never throws and never blocks the rest of the engine.
abstract class SpeechRecognizer {
  /// Prepare the backend and check permission WITHOUT starting to listen.
  /// Returns false if recognition is unavailable (no mic, denied, unsupported).
  Future<bool> initialize();

  bool get isAvailable;

  /// Whether the engine is mid-listen.
  bool get isListening;

  /// Listen for a single command in [language]. Resolves when speech ends, the
  /// caller cancels, or a timeout elapses. Partial-result callbacks are optional.
  Future<SpeechRecognitionResult> listen({
    required VoiceLanguage language,
    void Function(String partial)? onPartial,
  });

  /// Stop listening and finalize the current result early.
  Future<void> stop();

  /// Abort listening and discard any partial result.
  Future<void> cancel();

  Future<void> dispose();
}
