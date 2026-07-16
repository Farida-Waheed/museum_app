import 'package:flutter/material.dart';

import '../constants/voice_constants.dart';
import '../enums/voice_enums.dart';
import '../extensions/voice_context_extensions.dart';
import '../state/voice_controller.dart';

/// A Material 3 transport bar for the Voice Communication Engine.
///
/// It reflects the live [VoiceController] state — Ready / Speaking / Listening /
/// Paused / Muted / Unavailable and the "now speaking" caption — and exposes the
/// visitor's manual controls: Replay, Pause/Resume, Mute, and Speech-rate.
///
/// This widget is *purely a control surface*. It holds no business logic: every
/// button calls an existing [VoiceController] method and the engine decides what
/// actually happens (queue, gating, persistence, config resolution). The only
/// local state is the speech-rate bias the stepper is nudging, because the
/// controller does not expose the current bias for read-back.
class VoiceControlBar extends StatefulWidget {
  const VoiceControlBar({
    super.key,
    this.showCaption = true,
    this.padding = const EdgeInsets.all(12),
  });

  /// Whether to show the "now speaking" caption line above the controls.
  final bool showCaption;

  final EdgeInsetsGeometry padding;

  @override
  State<VoiceControlBar> createState() => _VoiceControlBarState();
}

class _VoiceControlBarState extends State<VoiceControlBar> {
  // Local view of the rate nudge the stepper applies on top of the profile
  // baseline. The engine clamps the resolved rate; here we only bound the bias
  // so the stepper has sensible end-stops.
  static const double _biasStep = VoiceConstants.speechRateStep;
  static const double _minBias = -0.5;
  static const double _maxBias = 0.5;

  double _rateBias = 0.0;

  void _nudgeRate(VoiceController voice, double delta) {
    final next = (_rateBias + delta).clamp(_minBias, _maxBias).toDouble();
    if (next == _rateBias) return;
    setState(() => _rateBias = next);
    voice.setSpeechRateBias(next);
  }

  @override
  Widget build(BuildContext context) {
    final voice = context.watchVoice;
    final status = voice.status;
    final scheme = Theme.of(context).colorScheme;

    final unavailable =
        status.status == VoiceStatus.unavailable || !status.ttsAvailable;

    return Semantics(
      container: true,
      label: 'Voice controls',
      child: Container(
        padding: widget.padding,
        decoration: ShapeDecoration(
          color: scheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: scheme.outlineVariant),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusLine(voice: voice),
            if (widget.showCaption &&
                (status.nowSpeaking?.trim().isNotEmpty ?? false)) ...[
              const SizedBox(height: 6),
              Text(
                status.nowSpeaking!.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                // Replay
                _ControlButton(
                  icon: Icons.replay_rounded,
                  tooltip: 'Replay',
                  onPressed:
                      status.canReplay && !unavailable ? voice.replay : null,
                ),
                const SizedBox(width: 8),
                // Pause / Resume — Resume shown instead of Pause while paused.
                if (status.isPaused)
                  _ControlButton(
                    icon: Icons.play_arrow_rounded,
                    tooltip: 'Resume',
                    filled: true,
                    onPressed: unavailable ? null : () => voice.resume(),
                  )
                else
                  _ControlButton(
                    icon: Icons.pause_rounded,
                    tooltip: 'Pause',
                    filled: true,
                    onPressed: unavailable || !status.isSpeaking
                        ? null
                        : () => voice.pause(),
                  ),
                const SizedBox(width: 8),
                // Mute / Unmute toggle
                _ControlButton(
                  icon: status.muted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  tooltip: status.muted ? 'Unmute' : 'Mute',
                  selected: status.muted,
                  onPressed: () => voice.toggleMute(),
                ),
                const Spacer(),
                // Speech-rate stepper
                _RateStepper(
                  onSlower: _rateBias > _minBias && !unavailable
                      ? () => _nudgeRate(voice, -_biasStep)
                      : null,
                  onFaster: _rateBias < _maxBias && !unavailable
                      ? () => _nudgeRate(voice, _biasStep)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The status label + pending-count line, driven entirely by the snapshot.
class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.voice});

  final VoiceController voice;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = voice.status;

    final (IconData icon, String label, Color color) = switch (status.status) {
      VoiceStatus.listening => (
          Icons.mic_rounded,
          'Listening',
          scheme.tertiary,
        ),
      VoiceStatus.speaking => (
          Icons.graphic_eq_rounded,
          'Speaking',
          scheme.primary,
        ),
      VoiceStatus.paused => (
          Icons.pause_circle_outline_rounded,
          'Paused',
          scheme.secondary,
        ),
      VoiceStatus.muted => (
          Icons.volume_off_rounded,
          'Muted',
          scheme.onSurfaceVariant,
        ),
      VoiceStatus.unavailable => (
          Icons.mic_off_rounded,
          'Voice unavailable',
          scheme.error,
        ),
      VoiceStatus.ready => (
          Icons.check_circle_outline_rounded,
          'Ready',
          scheme.primary,
        ),
    };

    return Semantics(
      liveRegion: true,
      label: 'Voice assistant',
      value: label,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (status.pending > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: ShapeDecoration(
                color: scheme.secondaryContainer,
                shape: const StadiumBorder(),
              ),
              child: Text(
                '+${status.pending}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSecondaryContainer,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A single Material 3 transport button (filled-tonal, or filled for the primary
/// pause/resume action, or a selected toggle for mute). A null [onPressed]
/// renders it disabled — the standard M3 affordance.
class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.filled = false,
    this.selected = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool filled;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    // Enforce a comfortable, accessible 48x48 minimum tap target.
    const constraints = BoxConstraints(minWidth: 48, minHeight: 48);

    if (filled) {
      return IconButton.filled(
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: onPressed,
        constraints: constraints,
      );
    }
    if (selected) {
      return IconButton.filledTonal(
        icon: Icon(icon),
        tooltip: tooltip,
        isSelected: true,
        onPressed: onPressed,
        constraints: constraints,
      );
    }
    return IconButton.filledTonal(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
      constraints: constraints,
    );
  }
}

/// Slower / faster speech-rate stepper. Both buttons simply call back out; all
/// bounds and persistence live in the state/controller, not here.
class _RateStepper extends StatelessWidget {
  const _RateStepper({required this.onSlower, required this.onFaster});

  final VoidCallback? onSlower;
  final VoidCallback? onFaster;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerHighest,
        shape: StadiumBorder(side: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded),
            tooltip: 'Slower speech',
            onPressed: onSlower,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
          Icon(Icons.speed_rounded, size: 18, color: scheme.onSurfaceVariant),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Faster speech',
            onPressed: onFaster,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
        ],
      ),
    );
  }
}
