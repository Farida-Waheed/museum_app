import 'package:flutter/material.dart';
import 'package:museum_app/accessibility/accessibility.dart';

import '../controller/audio_description_status.dart';
import '../transcript/transcript_status.dart';

/// The narration control bar: replay, pause/resume, tell-me-more, ask a
/// question, bookmark, skip. It is a STATELESS view — every button forwards to
/// an injected callback and its enabled/disabled state is derived purely from
/// the [narrationStatus] / [transcriptStatus] it is handed. It contains no
/// business logic and calls no controller directly; the owning panel wires each
/// callback to the appropriate existing controller.
///
/// Accessibility-friendly: every action is an [IconButton] with a spoken
/// tooltip + semantics label, and tap targets grow when the visitor has enabled
/// large tap targets.
class NarrationControls extends StatelessWidget {
  const NarrationControls({
    super.key,
    required this.narrationStatus,
    required this.transcriptStatus,
    required this.profile,
    required this.onReplay,
    required this.onPause,
    required this.onResume,
    required this.onTellMeMore,
    required this.onAskQuestion,
    required this.onBookmark,
    required this.onSkip,
  });

  final AudioDescriptionStatus narrationStatus;
  final TranscriptStatus transcriptStatus;
  final AccessibilityProfile profile;

  final VoidCallback onReplay;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onTellMeMore;
  final VoidCallback onAskQuestion;
  final VoidCallback onBookmark;
  final VoidCallback onSkip;

  static const Key replayKey = Key('narration-control-replay');
  static const Key pauseKey = Key('narration-control-pause');
  static const Key resumeKey = Key('narration-control-resume');
  static const Key tellMeMoreKey = Key('narration-control-tell-me-more');
  static const Key askQuestionKey = Key('narration-control-ask-question');
  static const Key bookmarkKey = Key('narration-control-bookmark');
  static const Key skipKey = Key('narration-control-skip');

  bool get _hasExhibit => narrationStatus != AudioDescriptionStatus.idle;
  bool get _isSpeaking => transcriptStatus == TranscriptStatus.active;
  bool get _isPaused => transcriptStatus == TranscriptStatus.paused;

  /// Actions that only make sense once a narration exists for an exhibit.
  bool get _actionsEnabled => _hasExhibit;

  @override
  Widget build(BuildContext context) {
    final large = profile.display.largeTapTargets;
    final iconSize = large ? 32.0 : 24.0;

    // Show pause while actively speaking; otherwise offer resume (disabled
    // unless actually paused). This mirrors the transcript state exactly.
    final showPause = _isSpeaking;

    return Semantics(
      container: true,
      label: 'Narration controls',
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: large ? 8 : 4,
        children: [
          _button(
            key: NarrationControls.replayKey,
            icon: Icons.replay,
            label: 'Replay narration',
            iconSize: iconSize,
            onPressed: _actionsEnabled ? onReplay : null,
          ),
          if (showPause)
            _button(
              key: NarrationControls.pauseKey,
              icon: Icons.pause,
              label: 'Pause narration',
              iconSize: iconSize,
              onPressed: onPause,
            )
          else
            _button(
              key: NarrationControls.resumeKey,
              icon: Icons.play_arrow,
              label: 'Resume narration',
              iconSize: iconSize,
              onPressed: _isPaused ? onResume : null,
            ),
          _button(
            key: NarrationControls.tellMeMoreKey,
            icon: Icons.more_horiz,
            label: 'Tell me more',
            iconSize: iconSize,
            onPressed: _actionsEnabled ? onTellMeMore : null,
          ),
          _button(
            key: NarrationControls.askQuestionKey,
            icon: Icons.help_outline,
            label: 'Ask a question',
            iconSize: iconSize,
            onPressed: _actionsEnabled ? onAskQuestion : null,
          ),
          _button(
            key: NarrationControls.bookmarkKey,
            icon: Icons.bookmark_border,
            label: 'Bookmark this exhibit',
            iconSize: iconSize,
            onPressed: _actionsEnabled ? onBookmark : null,
          ),
          _button(
            key: NarrationControls.skipKey,
            icon: Icons.skip_next,
            label: 'Skip narration',
            iconSize: iconSize,
            onPressed: _actionsEnabled ? onSkip : null,
          ),
        ],
      ),
    );
  }

  Widget _button({
    required Key key,
    required IconData icon,
    required String label,
    required double iconSize,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      key: key,
      icon: Icon(icon),
      iconSize: iconSize,
      tooltip: label,
      onPressed: onPressed,
      // Explicit semantics so the label is spoken even where the tooltip is not.
      style: IconButton.styleFrom(
        minimumSize: Size.square(iconSize + 16),
      ),
    );
  }
}
