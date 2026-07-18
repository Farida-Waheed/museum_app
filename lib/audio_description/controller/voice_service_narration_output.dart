import 'package:museum_app/voice/voice.dart';

import 'audio_description_state.dart';

/// The thin adapter that binds the audio-description controller's narrow
/// [NarrationVoiceOutput] seam to the existing Phase-3 [VoiceService], so the
/// controller never touches the voice stack directly and no second playback
/// path is introduced.
///
/// It only translates: narration text + a language code become a
/// [VoiceService.announce] call tagged as an exhibit introduction, and a
/// cancellation becomes [VoiceService.stop]. All queueing, personalization, and
/// TTS behavior stay owned by [VoiceService].
class VoiceServiceNarrationOutput implements NarrationVoiceOutput {
  VoiceServiceNarrationOutput(this._voice);

  final VoiceService _voice;

  @override
  Future<bool> speakNarration(
    String narration, {
    required String language,
  }) async {
    final result = _voice.announce(
      narration,
      event: VoiceEventType.exhibitIntroduction,
      language: VoiceLanguage.fromCode(language),
    );
    // The narration was accepted for playback unless the queue dropped it
    // (full/not urgent enough) or de-duplicated it away.
    return result == VoiceEnqueueResult.queued ||
        result == VoiceEnqueueResult.interrupt;
  }

  @override
  Future<void> stopNarration() => _voice.stop();
}
