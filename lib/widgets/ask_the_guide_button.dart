import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/colors.dart';
import '../core/constants/text_styles.dart';
import '../models/app_session_provider.dart' as session;
import '../models/tour_provider.dart';
import '../screens/chat/chat_screen.dart';

class AskHorusFloatingChip extends StatefulWidget {
  final String screen;
  final String? currentExhibitId;
  final bool subtle;

  const AskHorusFloatingChip({
    super.key,
    this.screen = 'home',
    this.currentExhibitId,
    this.subtle = true,
  });

  @override
  State<AskHorusFloatingChip> createState() => _AskHorusFloatingChipState();
}

class _AskHorusFloatingChipState extends State<AskHorusFloatingChip>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  bool _isHovered = false;

  late final AnimationController _glowCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  void _openChat() {
    showDialog(
      context: context,
      barrierColor: AppColors.dialogBarrier(0.46),
      builder: (_) => ChatScreen(
        isPopup: true,
        screen: widget.screen,
        currentExhibitId: widget.currentExhibitId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final light = AppColors.useLightSurfaces;
    final sessionProvider = context.watch<session.AppSessionProvider>();
    final tourProvider = context.watch<TourProvider>();
    final activeTour =
        sessionProvider.tourLifecycleState == session.TourLifecycleState.active ||
        sessionProvider.tourLifecycleState == session.TourLifecycleState.paused ||
        tourProvider.tourLifecycleState == TourLifecycleState.active ||
        tourProvider.tourLifecycleState == TourLifecycleState.paused;
    final label = activeTour ? 'Ask the Robot Guide' : 'Ask Horus';
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: AnimatedScale(
            scale: _pressed ? 0.96 : (_isHovered ? 1.02 : 1.0),
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTapDown: (_) => setState(() => _pressed = true),
              onTapUp: (_) => setState(() => _pressed = false),
              onTapCancel: () => setState(() => _pressed = false),
              onTap: _openChat,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: AppColors.useLightSurfaces
                      ? AppColors.cardGlass(0.88)
                      : AppColors.cardGlass(0.56),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(
                      alpha: light ? 0.36 : 0.46,
                    ),
                    width: 1.05,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkInk.withValues(
                        alpha: light ? 0.10 : 0.24,
                      ),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                    BoxShadow(
                      color: AppColors.primaryGold.withValues(
                        alpha: 0.06 + (_glowCtrl.value * 0.04),
                      ),
                      blurRadius: 16,
                    ),
                  ],
                ),
                constraints: const BoxConstraints(minHeight: 42, maxHeight: 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Row(
                  textDirection: Directionality.of(context),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.record_voice_over_outlined,
                      color: AppColors.primaryGold,
                      size: 17,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.buttonLabel(context).copyWith(
                        color: AppColors.resolvedTitleText,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AskTheGuideButton extends StatelessWidget {
  const AskTheGuideButton({
    super.key,
    this.screen = 'home',
    this.currentExhibitId,
    this.subtle = true,
  });

  final String screen;
  final String? currentExhibitId;
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    return AskHorusFloatingChip(
      screen: screen,
      currentExhibitId: currentExhibitId,
      subtle: subtle,
    );
  }
}
