import '../enums/voice_enums.dart';
import '../models/voice_content.dart';
import '../models/voice_message.dart';
import '../services/voice_service.dart';

/// The contract an AI/exhibit response implements so it arrives at the engine as
/// *structured, speakable content* rather than a raw string — realising the
/// "AI does not simply return text" requirement. Any response type can implement
/// this (or use [SpokenAiResponse]) and be spoken with correct pauses, emphasis,
/// pronunciation, and language without the AI layer knowing anything about TTS.
abstract class VoiceEnabledResponse {
  VoiceContent toVoiceContent();
  VoiceLanguage get voiceLanguage;
}

/// A concrete, immutable AI response carrying both the on-screen text and its
/// speakable form. Built by [AiVoiceAdapter] from a plain answer, or directly by
/// an AI layer that wants explicit pauses/emphasis/pronunciations.
class SpokenAiResponse implements VoiceEnabledResponse {
  /// The text shown on screen / used for captions.
  final String displayText;
  final VoiceContent content;
  final VoiceLanguage language;

  const SpokenAiResponse({
    required this.displayText,
    required this.content,
    this.language = VoiceLanguage.english,
  });

  @override
  VoiceContent toVoiceContent() => content;

  @override
  VoiceLanguage get voiceLanguage => language;
}

/// Turns AI answers into voice, and speaks them through the [VoiceService] as
/// interactive-priority content. This is the single seam the chat/AI layer uses;
/// it never touches the queue or a plugin.
///
/// Every AI response automatically becomes voice-enabled: pass the raw answer to
/// [fromAnswer] to get a [SpokenAiResponse] (segmented into natural sentences,
/// with optional emphasis terms and pronunciation hints), then [speak] it.
class AiVoiceAdapter {
  AiVoiceAdapter(this._voice);

  final VoiceService _voice;

  /// Build a voice-enabled response from a plain AI answer string.
  ///
  /// * [emphasize] — terms to stress (e.g. the exhibit name) so they stand out.
  /// * [pronunciations] — written→spoken overrides (e.g. "Hatshepsut" →
  ///   "Hat-shep-soot") applied by the engine, backend-agnostic.
  static SpokenAiResponse fromAnswer(
    String answer, {
    VoiceLanguage language = VoiceLanguage.english,
    List<String> emphasize = const [],
    Map<String, String> pronunciations = const {},
  }) {
    var content = VoiceContent.plain(answer);
    if (emphasize.isNotEmpty) {
      content = VoiceContent(
        segments: [
          for (final s in content.segments)
            _emphasizeIn(s, emphasize),
        ],
        pronunciations: content.pronunciations,
      );
    }
    if (pronunciations.isNotEmpty) {
      content = content.withPronunciations(pronunciations);
    }
    return SpokenAiResponse(
      displayText: answer,
      content: content,
      language: language,
    );
  }

  /// Speak a voice-enabled response. Returns immediately; playback is queued.
  void speak(VoiceEnabledResponse response) {
    _voice.speak(VoiceMessage(
      content: response.toVoiceContent(),
      event: VoiceEventType.aiAnswer,
      priority: VoicePriority.interactive,
      language: response.voiceLanguage,
    ));
  }

  /// Convenience: build from a plain answer and speak it in one call.
  SpokenAiResponse speakAnswer(
    String answer, {
    VoiceLanguage language = VoiceLanguage.english,
    List<String> emphasize = const [],
    Map<String, String> pronunciations = const {},
  }) {
    final response = fromAnswer(
      answer,
      language: language,
      emphasize: emphasize,
      pronunciations: pronunciations,
    );
    speak(response);
    return response;
  }

  static VoiceSegment _emphasizeIn(VoiceSegment segment, List<String> terms) {
    final lower = segment.text.toLowerCase();
    for (final term in terms) {
      if (term.trim().isNotEmpty && lower.contains(term.toLowerCase())) {
        return segment.copyWith(emphasize: true);
      }
    }
    return segment;
  }
}
