import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tour_provider.dart';
import '../models/user_preferences.dart';
import '../l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import '../core/constants/text_styles.dart';

class RobotStatusBanner extends StatelessWidget {
  const RobotStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final tourProvider = Provider.of<TourProvider>(context);
    final prefs = Provider.of<UserPreferencesModel>(context);
    final l10n = AppLocalizations.of(context)!;

    final state = tourProvider.robotState;
    final connectionState = tourProvider.connectionState;
    final statusMsg = tourProvider.getStatusMessage(prefs.language);

    Color statusColor;
    IconData statusIcon;
    bool isPulsing = false;

    if (connectionState == RobotConnectionState.disconnected) {
      statusColor = Colors.red;
      statusIcon = Icons.signal_wifi_off;
    } else if (connectionState == RobotConnectionState.connecting) {
      statusColor = Colors.amber;
      statusIcon = Icons.sync;
      isPulsing = true;
    } else {
      switch (state) {
        case RobotState.moving:
          statusColor = Colors.blue;
          statusIcon = Icons.directions_walk;
          isPulsing = true;
          break;
        case RobotState.speaking:
          statusColor = Colors.green;
          statusIcon = Icons.volume_up;
          break;
        case RobotState.thinking:
          statusColor = Colors.purple;
          statusIcon = Icons.psychology;
          isPulsing = true;
          break;
        case RobotState.disconnected:
          statusColor = Colors.red;
          statusIcon = Icons.signal_wifi_off;
          break;
        case RobotState.syncing:
          statusColor = Colors.teal;
          statusIcon = Icons.sync;
          isPulsing = true;
          break;
        case RobotState.approaching:
          statusColor = Colors.amber;
          statusIcon = Icons.location_on;
          isPulsing = true;
          break;
        case RobotState.waiting:
          statusColor = Colors.orange;
          statusIcon = Icons.pause_circle_outline;
          break;
        case RobotState.listening:
          statusColor = Colors.orange;
          statusIcon = Icons.mic;
          isPulsing = true;
          break;
        case RobotState.idle:
          statusColor = Colors.blueGrey;
          statusIcon = Icons.smart_toy_outlined;
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cinematicNav,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            _StatusIndicator(
              color: statusColor,
              icon: statusIcon,
              isPulsing: isPulsing,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.guideStatus.toUpperCase(),
                    style: AppTextStyles.displaySectionTitle(context).copyWith(
                      fontSize: 10,
                      letterSpacing: 1.2,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusMsg,
                    style: AppTextStyles.bodyPrimary(context).copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (state == RobotState.moving &&
                tourProvider.nextExhibitId != null)
              _EstimatedArrival(
                seconds: tourProvider.estimatedTimeToNext,
                color: statusColor,
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatefulWidget {
  final Color color;
  final IconData icon;
  final bool isPulsing;

  const _StatusIndicator({
    required this.color,
    required this.icon,
    this.isPulsing = false,
  });

  @override
  State<_StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<_StatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
    if (widget.isPulsing) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_StatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPulsing && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.isPulsing)
          FadeTransition(
            opacity: _animation,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: widget.color.withOpacity(0.2), width: 1),
          ),
          child: Icon(widget.icon, size: 16, color: widget.color),
        ),
      ],
    );
  }
}

class _EstimatedArrival extends StatelessWidget {
  final double seconds;
  final Color color;
  const _EstimatedArrival({required this.seconds, required this.color});

  @override
  Widget build(BuildContext context) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    final timeStr = mins > 0 ? "${mins}m ${secs}s" : "${secs}s";
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        l10n.robotArrivalIn(timeStr),
        style: AppTextStyles.metadata(
          context,
        ).copyWith(fontSize: 11, fontWeight: FontWeight.w900, color: color),
      ),
    );
  }
}
