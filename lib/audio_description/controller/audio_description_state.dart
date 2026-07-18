import '../ai/narration_generation_result.dart';
import '../models/exhibit_id.dart';
import 'audio_description_status.dart';

/// An immutable snapshot of the controller's current narration run, published on
/// every state change. Pure value object — no AI/voice/Firebase/UI imports.
class AudioDescriptionState {
  final AudioDescriptionStatus status;

  /// The exhibit this run is for (null only in [AudioDescriptionStatus.idle]).
  final ExhibitId? exhibitId;

  /// The narration text once generated (available from
  /// [AudioDescriptionStatus.speaking] onward on success).
  final String? narration;

  /// The active language of this run ('en' / 'ar').
  final String language;

  /// On failure, which pipeline stage failed.
  final AudioDescriptionFailureStage? failureStage;

  /// Human-readable diagnostics for logging (never fabricated narration).
  final String? diagnostics;

  const AudioDescriptionState({
    required this.status,
    this.exhibitId,
    this.narration,
    this.language = 'en',
    this.failureStage,
    this.diagnostics,
  });

  static const AudioDescriptionState initial =
      AudioDescriptionState(status: AudioDescriptionStatus.idle);

  bool get isFailed => status == AudioDescriptionStatus.failed;
  bool get isCompleted => status == AudioDescriptionStatus.completed;
  bool get isBusy =>
      status == AudioDescriptionStatus.loading ||
      status == AudioDescriptionStatus.generating ||
      status == AudioDescriptionStatus.speaking;

  AudioDescriptionState copyWith({
    AudioDescriptionStatus? status,
    ExhibitId? exhibitId,
    String? narration,
    String? language,
    AudioDescriptionFailureStage? failureStage,
    String? diagnostics,
  }) =>
      AudioDescriptionState(
        status: status ?? this.status,
        exhibitId: exhibitId ?? this.exhibitId,
        narration: narration ?? this.narration,
        language: language ?? this.language,
        failureStage: failureStage ?? this.failureStage,
        diagnostics: diagnostics ?? this.diagnostics,
      );

  @override
  String toString() =>
      'AudioDescriptionState(${status.storageKey}, ${exhibitId ?? 'none'}, '
      '$language${failureStage != null ? ', ${failureStage!.storageKey}' : ''})';
}

/// The narrow voice seam the controller depends on, so it never constructs or
/// binds to the concrete `VoiceService`/coordinator stack. A thin adapter
/// (`VoiceServiceNarrationOutput`, in `voice_service_narration_output.dart`)
/// forwards `speakNarration`/`stopNarration` to the real
/// `VoiceService.announce`/`VoiceService.stop`.
///
/// Returns true when the narration was accepted for playback; false / throwing
/// is treated as a voice-stage failure by the controller.
abstract class NarrationVoiceOutput {
  Future<bool> speakNarration(String narration, {required String language});

  /// Stop any narration currently playing so a cancelled run (visitor skipped,
  /// robot must move) does not keep speaking after the controller state flips.
  /// Must be safe to call when nothing is speaking (no-op in that case).
  Future<void> stopNarration();
}

/// Signals how a generation result maps to a narration string when handing off
/// to voice — kept here so [AudioDescriptionState] and the controller share it.
extension NarrationResultText on NarrationGenerationResult {
  String? get speakableText =>
      isSuccess ? narration : null;
}
