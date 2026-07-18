import '../controller/audio_description_state.dart';
import '../models/exhibit_id.dart';
import 'audio_description_interaction.dart';

/// The immutable outcome of handling one visitor interaction. It carries just
/// enough for a higher layer (UI / tour orchestrator) to react — the interaction
/// that ran, a status, and any product of that interaction (an updated narration
/// [state], a follow-up [answer], or diagnostics on failure). Pure value object:
/// no AI / voice / Firebase / UI imports.
class AudioDescriptionInteractionResult {
  /// Which interaction this result is for.
  final AudioDescriptionInteraction interaction;

  final AudioDescriptionInteractionStatus status;

  /// The exhibit the interaction acted on, when there was one in context.
  final ExhibitId? exhibitId;

  /// For re-narration interactions (repeat / tell-me-more / detail change): the
  /// controller state the pipeline resolved to. Null for non-narration outcomes.
  final AudioDescriptionState? state;

  /// For a follow-up question: the AI's answer text. Null otherwise.
  final String? answer;

  /// Human-readable diagnostics for logging on [AudioDescriptionInteractionStatus.failed]
  /// (never surfaced verbatim to visitors, never fabricated narration).
  final String? diagnostics;

  const AudioDescriptionInteractionResult({
    required this.interaction,
    required this.status,
    this.exhibitId,
    this.state,
    this.answer,
    this.diagnostics,
  });

  bool get isSuccess => status.isSuccess;
  bool get isFailure => status == AudioDescriptionInteractionStatus.failed;

  @override
  String toString() =>
      'AudioDescriptionInteractionResult(${interaction.storageKey} → '
      '${status.storageKey}${exhibitId != null ? ', $exhibitId' : ''}'
      '${diagnostics != null ? ', "$diagnostics"' : ''})';
}
