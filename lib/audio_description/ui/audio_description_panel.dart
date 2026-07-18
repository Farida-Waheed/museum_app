import 'package:flutter/material.dart';
import 'package:museum_app/accessibility/accessibility.dart';

import '../controller/audio_description_controller.dart';
import '../controller/audio_description_state.dart';
import '../controller/audio_description_status.dart';
import '../interaction/audio_description_interaction.dart';
import '../interaction/audio_description_interaction_controller.dart';
import '../transcript/transcript_controller.dart';
import '../transcript/transcript_state.dart';
import 'narration_controls.dart';
import 'narration_progress_indicator.dart';
import 'transcript_view.dart';

/// Signature for obtaining a follow-up question from the visitor. Injected so
/// the panel does not hard-code how the question is captured (a dialog, a voice
/// prompt, a test stub). Returns null / empty when the visitor cancels.
typedef AskQuestionPrompt = Future<String?> Function(BuildContext context);

/// The top-level UI for exhibit narration. It is a thin, reactive view over the
/// existing Phase-4 controllers: it subscribes to [AudioDescriptionController]
/// and [TranscriptController] state and rebuilds, and forwards every action to
/// the injected [AudioDescriptionInteractionController] (replay / tell-me-more /
/// ask / bookmark / skip) or to the [TranscriptController] (pause / resume). It
/// contains NO AI, repository, robot, or narration business logic and never
/// duplicates controller logic — it only reflects state and delegates intent.
///
/// Everything visual reacts solely to controller state, so the panel is fully
/// driven by (and testable through) the controllers it is given.
class AudioDescriptionPanel extends StatefulWidget {
  const AudioDescriptionPanel({
    super.key,
    required this.narrationController,
    required this.transcriptController,
    required this.interactionController,
    required this.profile,
    this.askQuestionPrompt,
    this.onPauseAudio,
    this.onResumeAudio,
  });

  final AudioDescriptionController narrationController;
  final TranscriptController transcriptController;
  final AudioDescriptionInteractionController interactionController;
  final AccessibilityProfile profile;

  /// How to capture a follow-up question. Defaults to a simple text dialog.
  final AskQuestionPrompt? askQuestionPrompt;

  /// Optional audio pause/resume hooks (the voice layer owns actual playback;
  /// the panel only signals intent). Transcript pause/resume always happens.
  final Future<void> Function()? onPauseAudio;
  final Future<void> Function()? onResumeAudio;

  static const Key rootKey = Key('audio-description-panel');
  static const Key idleKey = Key('audio-description-idle');
  static const Key loadingKey = Key('audio-description-loading');
  static const Key narrationTextKey = Key('audio-description-narration-text');
  static const Key errorKey = Key('audio-description-error');

  @override
  State<AudioDescriptionPanel> createState() => _AudioDescriptionPanelState();
}

class _AudioDescriptionPanelState extends State<AudioDescriptionPanel> {
  late AudioDescriptionState _narration;
  late TranscriptState _transcript;

  // Retain any previously-installed listeners so we can chain rather than
  // clobber, and restore them on dispose (the panel is a subscriber, not owner).
  void Function(AudioDescriptionState)? _prevNarrationListener;
  void Function(TranscriptState)? _prevTranscriptListener;

  @override
  void initState() {
    super.initState();
    _narration = widget.narrationController.state;
    _transcript = widget.transcriptController.state;

    _prevNarrationListener = widget.narrationController.onStateChanged;
    widget.narrationController.onStateChanged = (state) {
      _prevNarrationListener?.call(state);
      if (mounted) setState(() => _narration = state);
    };

    _prevTranscriptListener = widget.transcriptController.onStateChanged;
    widget.transcriptController.onStateChanged = (state) {
      _prevTranscriptListener?.call(state);
      if (mounted) setState(() => _transcript = state);
    };
  }

  @override
  void dispose() {
    widget.narrationController.onStateChanged = _prevNarrationListener;
    widget.transcriptController.onStateChanged = _prevTranscriptListener;
    super.dispose();
  }

  // --- Action forwarding (delegation only — no business logic here) ----------

  void _replay() =>
      widget.interactionController.handle(AudioDescriptionInteraction.repeat);

  Future<void> _pause() async {
    widget.transcriptController.pause();
    if (widget.onPauseAudio != null) await widget.onPauseAudio!();
  }

  Future<void> _resume() async {
    widget.transcriptController.resume();
    if (widget.onResumeAudio != null) await widget.onResumeAudio!();
  }

  void _tellMeMore() => widget.interactionController
      .handle(AudioDescriptionInteraction.tellMeMore);

  Future<void> _askQuestion() async {
    final prompt = widget.askQuestionPrompt ?? _defaultQuestionPrompt;
    final question = await prompt(context);
    if (question == null || question.trim().isEmpty) return;
    await widget.interactionController.handle(
      AudioDescriptionInteraction.askFollowUp,
      question: question,
    );
  }

  void _bookmark() =>
      widget.interactionController.handle(AudioDescriptionInteraction.bookmark);

  void _skip() =>
      widget.interactionController.handle(AudioDescriptionInteraction.skip);

  Future<String?> _defaultQuestionPrompt(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ask about this exhibit'),
        content: TextField(
          key: const Key('audio-description-question-field'),
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Type your question'),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Ask'),
          ),
        ],
      ),
    );
  }

  // --- Build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Card(
      key: AudioDescriptionPanel.rootKey,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _body(context),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    switch (_narration.status) {
      case AudioDescriptionStatus.idle:
        return const Padding(
          key: AudioDescriptionPanel.idleKey,
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text('Select an exhibit to begin narration.')),
        );
      case AudioDescriptionStatus.loading:
      case AudioDescriptionStatus.generating:
        return _loading(context);
      case AudioDescriptionStatus.failed:
        return _error(context);
      case AudioDescriptionStatus.speaking:
      case AudioDescriptionStatus.completed:
      case AudioDescriptionStatus.cancelled:
        return _narrationBody(context);
    }
  }

  Widget _loading(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'Preparing narration',
      child: const Padding(
        key: AudioDescriptionPanel.loadingKey,
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _error(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      key: AudioDescriptionPanel.errorKey,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.error),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Narration is unavailable right now.'),
          ),
          TextButton(
            key: const Key('audio-description-retry'),
            onPressed: _replay,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _narrationBody(BuildContext context) {
    final narration = _narration.narration;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (narration != null && narration.isNotEmpty)
          Semantics(
            label: 'Exhibit narration',
            child: Padding(
              key: AudioDescriptionPanel.narrationTextKey,
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                narration,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        NarrationProgressIndicator(
          transcriptState: _transcript,
          profile: widget.profile,
        ),
        const SizedBox(height: 12),
        TranscriptView(
          transcriptState: _transcript,
          profile: widget.profile,
        ),
        const SizedBox(height: 12),
        NarrationControls(
          narrationStatus: _narration.status,
          transcriptStatus: _transcript.status,
          profile: widget.profile,
          onReplay: _replay,
          onPause: _pause,
          onResume: _resume,
          onTellMeMore: _tellMeMore,
          onAskQuestion: _askQuestion,
          onBookmark: _bookmark,
          onSkip: _skip,
        ),
      ],
    );
  }
}
