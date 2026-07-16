import 'package:flutter/material.dart';

import '../enums/voice_enums.dart';
import '../extensions/voice_context_extensions.dart';
import '../models/voice_status_snapshot.dart';

/// A compact, self-describing pill that surfaces the live state of the Voice
/// Communication Engine — Listening / Speaking / Paused / Muted / Ready /
/// Unavailable — so the visitor (and a sighted companion) always knows what the
/// assistant is doing.
///
/// It reads the shared [VoiceStatusSnapshot] from the [VoiceController] via
/// `context.voiceStatus`, so it rebuilds automatically whenever the engine's
/// state changes; no screen wires anything up. Purely presentational — it issues
/// no commands (that is [VoiceControlBar]'s job).
///
/// Material 3 throughout: colours come from the active [ColorScheme] (so it works
/// in light, dark, and high-contrast themes), the shape is a rounded "chip", and
/// a gentle pulse animates the icon while the engine is actively speaking or
/// listening — automatically disabled when the platform requests reduced motion.
class VoiceStatusIndicator extends StatefulWidget {
  const VoiceStatusIndicator({
    super.key,
    this.compact = false,
    this.showLabel = true,
  });

  /// When true, renders icon-only (no text label) for tight spaces such as an
  /// app-bar action; the accessible label is still exposed via [Semantics].
  final bool compact;

  /// Whether to show the textual status label beside the icon (ignored when
  /// [compact] is true).
  final bool showLabel;

  @override
  State<VoiceStatusIndicator> createState() => _VoiceStatusIndicatorState();
}

class _VoiceStatusIndicatorState extends State<VoiceStatusIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _syncPulse({required bool active, required bool reduceMotion}) {
    if (active && !reduceMotion) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else if (_pulse.isAnimating || _pulse.value != 0) {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final VoiceStatusSnapshot snapshot = context.voiceStatus;
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final visual = _VoiceStatusVisual.of(snapshot, scheme);
    final animate =
        snapshot.status == VoiceStatus.speaking ||
        snapshot.status == VoiceStatus.listening;
    _syncPulse(active: animate, reduceMotion: reduceMotion);

    final icon = FadeTransition(
      opacity: animate && !reduceMotion
          ? Tween<double>(begin: 0.45, end: 1.0).animate(
              CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
            )
          : const AlwaysStoppedAnimation<double>(1.0),
      child: Icon(visual.icon, size: 18, color: visual.foreground),
    );

    final content = widget.compact || !widget.showLabel
        ? icon
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 6),
              Text(
                visual.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: visual.foreground,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          );

    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Voice assistant',
      value: visual.label,
      child: AnimatedContainer(
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(
          horizontal: widget.compact ? 8 : 12,
          vertical: 8,
        ),
        decoration: ShapeDecoration(
          color: visual.background,
          shape: StadiumBorder(
            side: BorderSide(color: visual.foreground.withValues(alpha: 0.25)),
          ),
        ),
        child: content,
      ),
    );
  }
}

/// Resolves a status snapshot to an icon, label, and Material 3 colour pair.
class _VoiceStatusVisual {
  const _VoiceStatusVisual({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;

  factory _VoiceStatusVisual.of(
    VoiceStatusSnapshot snapshot,
    ColorScheme scheme,
  ) {
    switch (snapshot.status) {
      case VoiceStatus.listening:
        return _VoiceStatusVisual(
          icon: Icons.mic_rounded,
          label: 'Listening',
          foreground: scheme.onTertiaryContainer,
          background: scheme.tertiaryContainer,
        );
      case VoiceStatus.speaking:
        return _VoiceStatusVisual(
          icon: Icons.graphic_eq_rounded,
          label: 'Speaking',
          foreground: scheme.onPrimaryContainer,
          background: scheme.primaryContainer,
        );
      case VoiceStatus.paused:
        return _VoiceStatusVisual(
          icon: Icons.pause_circle_outline_rounded,
          label: 'Paused',
          foreground: scheme.onSecondaryContainer,
          background: scheme.secondaryContainer,
        );
      case VoiceStatus.muted:
        return _VoiceStatusVisual(
          icon: Icons.volume_off_rounded,
          label: 'Muted',
          foreground: scheme.onSurfaceVariant,
          background: scheme.surfaceContainerHighest,
        );
      case VoiceStatus.unavailable:
        return _VoiceStatusVisual(
          icon: Icons.mic_off_rounded,
          label: 'Voice unavailable',
          foreground: scheme.onErrorContainer,
          background: scheme.errorContainer,
        );
      case VoiceStatus.ready:
        return _VoiceStatusVisual(
          icon: Icons.record_voice_over_rounded,
          label: 'Ready',
          foreground: scheme.onSurfaceVariant,
          background: scheme.surfaceContainerHighest,
        );
    }
  }
}
