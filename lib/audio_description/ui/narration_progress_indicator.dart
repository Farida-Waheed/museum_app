import 'package:flutter/material.dart';
import 'package:museum_app/accessibility/accessibility.dart';

import '../transcript/transcript_state.dart';

/// A stateless presentation of narration progress, driven entirely by the
/// injected [TranscriptState] (the transcript layer is the single source of
/// truth for "how far through the telling we are"). It contains no business
/// logic — it only renders the state it is given.
///
/// Accessibility-friendly: the whole indicator is one semantics node with a
/// spoken label ("Narration progress") and a percentage value, and it is a
/// live region so a screen reader announces each advance.
class NarrationProgressIndicator extends StatelessWidget {
  const NarrationProgressIndicator({
    super.key,
    required this.transcriptState,
    required this.profile,
  });

  final TranscriptState transcriptState;
  final AccessibilityProfile profile;

  static const Key progressBarKey = Key('narration-progress-bar');

  @override
  Widget build(BuildContext context) {
    final total = transcriptState.totalCount;
    final spoken = transcriptState.spokenCount;
    final progress = transcriptState.progress;
    final percent = (progress * 100).round();
    final highContrast = profile.display.highContrast;
    final colors = Theme.of(context).colorScheme;

    final label = total == 0
        ? 'Narration progress: nothing to speak'
        : 'Narration progress: sentence $spoken of $total';

    return Semantics(
      container: true,
      liveRegion: true,
      label: label,
      value: '$percent percent',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              key: progressBarKey,
              value: total == 0 ? 0 : progress,
              minHeight: highContrast ? 10 : 6,
              backgroundColor: colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                highContrast ? colors.primary : colors.primaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 4),
          ExcludeSemantics(
            child: Text(
              total == 0 ? '—' : '$spoken / $total',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}
