import 'package:flutter/material.dart';
import 'package:museum_app/accessibility/accessibility.dart';

import '../transcript/transcript_segment.dart';
import '../transcript/transcript_state.dart';

/// A stateless rendering of the live transcript. It highlights the currently
/// spoken sentence using the active-index in the injected [TranscriptState] and
/// nothing else — it holds no state, does no segmentation, and drives no
/// playback. All of that already lives in the transcript layer (Task 10).
///
/// Accessibility-friendly: each sentence is its own semantics node; the active
/// one is marked as a live region and labelled "current sentence" so a screen
/// reader announces it as narration advances. Highlight styling also respects
/// high-contrast and bold-text display settings.
class TranscriptView extends StatelessWidget {
  const TranscriptView({
    super.key,
    required this.transcriptState,
    required this.profile,
  });

  final TranscriptState transcriptState;
  final AccessibilityProfile profile;

  static const Key emptyKey = Key('transcript-empty');
  static Key segmentKey(int index) => Key('transcript-segment-$index');

  @override
  Widget build(BuildContext context) {
    final transcript = transcriptState.transcript;
    if (transcript == null || transcript.isEmpty) {
      return const Padding(
        key: emptyKey,
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('No transcript available yet.'),
      );
    }

    final activeIndex = transcriptState.activeIndex;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final segment in transcript.segments)
          _SegmentText(
            key: segmentKey(segment.index),
            segment: segment,
            isActive: segment.index == activeIndex,
            profile: profile,
          ),
      ],
    );
  }
}

/// One transcript sentence. Highlighted when active; a plain, readable line
/// otherwise. Split out so the highlight styling stays in one place.
class _SegmentText extends StatelessWidget {
  const _SegmentText({
    super.key,
    required this.segment,
    required this.isActive,
    required this.profile,
  });

  final TranscriptSegment segment;
  final bool isActive;
  final AccessibilityProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final display = profile.display;

    final baseStyle = theme.textTheme.bodyLarge ?? const TextStyle();
    final style = baseStyle.copyWith(
      color: isActive ? colors.onPrimaryContainer : colors.onSurface,
      fontWeight: (isActive || display.boldText)
          ? FontWeight.w700
          : FontWeight.w400,
    );

    return Semantics(
      liveRegion: isActive,
      label: isActive ? 'Current sentence: ${segment.text}' : segment.text,
      selected: isActive,
      child: AnimatedContainer(
        duration: display.reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isActive
              ? (display.highContrast
                  ? colors.primary.withValues(alpha: 0.25)
                  : colors.primaryContainer)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive && display.highContrast
              ? Border.all(color: colors.primary, width: 2)
              : null,
        ),
        child: ExcludeSemantics(child: Text(segment.text, style: style)),
      ),
    );
  }
}
