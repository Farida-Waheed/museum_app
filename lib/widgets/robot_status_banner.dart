import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tour_provider.dart';
import '../models/user_preferences.dart';

class RobotStatusBanner extends StatelessWidget {
  const RobotStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final tourProvider = Provider.of<TourProvider>(context);
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    final state = tourProvider.robotState;
    final statusMsg = tourProvider.getStatusMessage(prefs.language);

    Color statusColor;
    IconData statusIcon;
    bool isPulsing = false;

    switch (state) {
      case RobotState.moving:
        statusColor = Colors.orange;
        statusIcon = Icons.directions_walk;
        isPulsing = true;
        break;
      case RobotState.speaking:
        statusColor = Colors.blue;
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
      case RobotState.listening:
        statusColor = Colors.green;
        statusIcon = Icons.mic;
        isPulsing = true;
        break;
      case RobotState.idle:
        statusColor = Colors.blueGrey;
        statusIcon = Icons.smart_toy_outlined;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        border: Border(
          bottom: BorderSide(color: statusColor.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          _StatusIndicator(
            color: statusColor,
            icon: statusIcon,
            isPulsing: isPulsing,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isArabic ? "حالة حوروس" : "HORUS-BOT STATUS",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: statusColor.withOpacity(0.8),
                  ),
                ),
                Text(
                  statusMsg,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (state == RobotState.moving && tourProvider.nextExhibitId != null)
            _EstimatedArrival(seconds: tourProvider.estimatedTimeToNext, isArabic: isArabic),
        ],
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
              width: 32,
              height: 32,
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
            color: widget.color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(widget.icon, size: 16, color: widget.color),
        ),
      ],
    );
  }
}

class _EstimatedArrival extends StatelessWidget {
  final double seconds;
  final bool isArabic;
  const _EstimatedArrival({required this.seconds, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    final timeStr = mins > 0 ? "${mins}m ${secs}s" : "${secs}s";
    final label = isArabic ? "وصول خلال $timeStr" : "Arrival in $timeStr";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
