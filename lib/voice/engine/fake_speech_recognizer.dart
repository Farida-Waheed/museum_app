import 'dart:async';

import '../enums/voice_enums.dart';
import 'speech_recognizer.dart';

/// Deterministic [SpeechRecognizer] for unit tests and as the safe default when
/// the plugin is absent. A test scripts the next transcript/outcome; production
/// swaps in `SpeechToTextRecognizer` with no other change.
class FakeSpeechRecognizer implements SpeechRecognizer {
  FakeSpeechRecognizer({
    this.available = true,
    this.outcome = SpeechRecognitionOutcome.success,
    this.confidence = 0.9,
  });

  /// Whether [initialize] reports availability (false simulates denied/no-mic).
  bool available;

  /// Outcome returned by the next [listen].
  SpeechRecognitionOutcome outcome;
  double confidence;

  /// Queue of transcripts returned by successive [listen] calls.
  final List<String> scriptedTranscripts = <String>[];

  bool _initialized = false;
  bool _available = false;
  bool _listening = false;
  int listenCount = 0;

  void enqueueTranscript(String t) => scriptedTranscripts.add(t);

  @override
  Future<bool> initialize() async {
    _initialized = true;
    _available = available;
    return _available;
  }

  @override
  bool get isAvailable => _initialized && _available;

  @override
  bool get isListening => _listening;

  @override
  Future<SpeechRecognitionResult> listen({
    required VoiceLanguage language,
    void Function(String partial)? onPartial,
  }) async {
    listenCount++;
    if (!isAvailable) {
      return const SpeechRecognitionResult(
        outcome: SpeechRecognitionOutcome.unavailable,
      );
    }
    if (outcome != SpeechRecognitionOutcome.success) {
      return SpeechRecognitionResult(outcome: outcome, language: language);
    }
    _listening = true;
    final transcript =
        scriptedTranscripts.isNotEmpty ? scriptedTranscripts.removeAt(0) : '';
    onPartial?.call(transcript);
    _listening = false;
    if (transcript.trim().isEmpty) {
      return SpeechRecognitionResult(
        outcome: SpeechRecognitionOutcome.noSpeech,
        language: language,
      );
    }
    return SpeechRecognitionResult(
      outcome: SpeechRecognitionOutcome.success,
      transcript: transcript,
      confidence: confidence,
      language: language,
    );
  }

  @override
  Future<void> stop() async => _listening = false;

  @override
  Future<void> cancel() async => _listening = false;

  @override
  Future<void> dispose() async => _listening = false;
}
