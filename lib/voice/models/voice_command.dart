import '../enums/voice_enums.dart';

/// The result of parsing a recognized utterance into an actionable intent.
/// Produced by `VoiceCommandParser`, consumed by the coordinator/app. Immutable.
class VoiceCommand {
  final VoiceCommandIntent intent;

  /// The raw recognized transcript that produced this command.
  final String transcript;

  /// Parser confidence 0..1 (from the recognizer and/or the match quality).
  final double confidence;

  /// The language the command was recognized in.
  final VoiceLanguage language;

  const VoiceCommand({
    required this.intent,
    this.transcript = '',
    this.confidence = 1.0,
    this.language = VoiceLanguage.english,
  });

  static const VoiceCommand unknown =
      VoiceCommand(intent: VoiceCommandIntent.unknown);

  bool get isRecognized => intent.isRecognized;

  /// A command is actionable when recognized and confident enough. The threshold
  /// is deliberately low for [VoiceCommandIntent.isImmediate] safety commands
  /// (stop/assistance) so they are never missed.
  bool get isActionable {
    if (!intent.isRecognized) return false;
    final threshold = intent.isImmediate ? 0.3 : 0.5;
    return confidence >= threshold;
  }

  @override
  bool operator ==(Object other) =>
      other is VoiceCommand &&
      other.intent == intent &&
      other.transcript == transcript &&
      (other.confidence - confidence).abs() < 0.0001 &&
      other.language == language;

  @override
  int get hashCode => Object.hash(intent, transcript, confidence, language);

  @override
  String toString() =>
      'VoiceCommand(${intent.storageKey}, conf: ${confidence.toStringAsFixed(2)}, "$transcript")';
}
