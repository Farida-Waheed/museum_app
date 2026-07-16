import '../enums/accessibility_enums.dart';
import '../utils/accessibility_parse.dart';

/// Voice / audio preferences shared by the app's TTS, the AI voice output, and
/// the robot's spoken narration. Consumed by Voice Navigation (Phase 3) and the
/// Audio Description Engine (Phase 4).
class VoiceSettings {
  /// Master switch: read screens/exhibits aloud and enable spoken guidance.
  final bool voiceGuidanceEnabled;

  /// Describe purely-visual content in words (audio description).
  final bool audioDescriptionEnabled;

  /// Screen-reader-first experience (visitor does not rely on the screen).
  final bool screenReaderFirst;

  final SpeechRate speechRate;

  const VoiceSettings({
    this.voiceGuidanceEnabled = false,
    this.audioDescriptionEnabled = false,
    this.screenReaderFirst = false,
    this.speechRate = SpeechRate.normal,
  });

  static const VoiceSettings standard = VoiceSettings();

  bool get isNeutral =>
      !voiceGuidanceEnabled &&
      !audioDescriptionEnabled &&
      !screenReaderFirst &&
      speechRate == SpeechRate.normal;

  VoiceSettings copyWith({
    bool? voiceGuidanceEnabled,
    bool? audioDescriptionEnabled,
    bool? screenReaderFirst,
    SpeechRate? speechRate,
  }) {
    return VoiceSettings(
      voiceGuidanceEnabled: voiceGuidanceEnabled ?? this.voiceGuidanceEnabled,
      audioDescriptionEnabled:
          audioDescriptionEnabled ?? this.audioDescriptionEnabled,
      screenReaderFirst: screenReaderFirst ?? this.screenReaderFirst,
      speechRate: speechRate ?? this.speechRate,
    );
  }

  Map<String, dynamic> toMap() => {
        'voice_guidance_enabled': voiceGuidanceEnabled,
        'audio_description_enabled': audioDescriptionEnabled,
        'screen_reader_first': screenReaderFirst,
        'speech_rate': speechRate.storageKey,
      };

  factory VoiceSettings.fromMap(Map<String, dynamic> map) => VoiceSettings(
        voiceGuidanceEnabled:
            AccessibilityParse.asBool(map['voice_guidance_enabled']),
        audioDescriptionEnabled:
            AccessibilityParse.asBool(map['audio_description_enabled']),
        screenReaderFirst:
            AccessibilityParse.asBool(map['screen_reader_first']),
        speechRate: SpeechRate.fromStorage(map['speech_rate']),
      );

  @override
  bool operator ==(Object other) =>
      other is VoiceSettings &&
      other.voiceGuidanceEnabled == voiceGuidanceEnabled &&
      other.audioDescriptionEnabled == audioDescriptionEnabled &&
      other.screenReaderFirst == screenReaderFirst &&
      other.speechRate == speechRate;

  @override
  int get hashCode => Object.hash(voiceGuidanceEnabled, audioDescriptionEnabled,
      screenReaderFirst, speechRate);
}
