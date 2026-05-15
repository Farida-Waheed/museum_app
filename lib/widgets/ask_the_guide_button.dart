import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/constants/text_styles.dart';
import '../l10n/app_localizations.dart';
import '../models/app_session_provider.dart' as session;
import '../models/tour_provider.dart';
import '../screens/chat/chat_screen.dart';
import 'package:provider/provider.dart';

/// Unified floating Ask Horus component for tour fallback questions.
/// Used consistently across all relevant screens.
///
/// Features:
/// - Premium visual design with glowing animation
/// - Consistent Ask Horus title
/// - Opens the fallback question popup only during a tour
/// - Responsive and accessible
class AskTheGuideButton extends StatefulWidget {
  final String screen;
  final String? currentExhibitId;
  final bool subtle;

  const AskTheGuideButton({
    super.key,
    this.screen = 'home',
    this.currentExhibitId,
    this.subtle = false,
  });

  @override
  State<AskTheGuideButton> createState() => _AskTheGuideButtonState();
}

class _AskTheGuideButtonState extends State<AskTheGuideButton>
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
    final sessionProvider = context.read<session.AppSessionProvider>();
    final tourProvider = context.read<TourProvider>();
    final canAsk =
        sessionProvider.hasRestorableTourSession ||
        tourProvider.tourLifecycleState == TourLifecycleState.active ||
        tourProvider.tourLifecycleState == TourLifecycleState.paused;
    if (!canAsk) {
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'يمكنك سؤال حورس أثناء الجولة فقط.'
                : 'You can ask Horus during an active tour only.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.cinematicElevated,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => ChatScreen(
        isPopup: true,
        screen: widget.screen,
        currentExhibitId: widget.currentExhibitId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final buttonText = l10n.askTheGuide;
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
                  color: widget.subtle
                      ? AppColors.cardGlass(0.46)
                      : AppColors.cinematicElevated,
                  borderRadius: BorderRadius.circular(widget.subtle ? 26 : 30),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(
                      alpha: widget.subtle
                          ? 0.30
                          : 0.6 + (_glowCtrl.value * 0.4),
                    ),
                    width: widget.subtle ? 1.0 : (_isHovered ? 1.5 : 1.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: widget.subtle ? 0.18 : 0.6,
                      ),
                      blurRadius: widget.subtle ? 10 : 24,
                      offset: Offset(0, widget.subtle ? 5 : 12),
                    ),
                    if (!widget.subtle)
                      BoxShadow(
                        color: AppColors.primaryGold.withValues(
                          alpha: 0.2 + (_glowCtrl.value * 0.3),
                        ),
                        blurRadius: _isHovered ? 30 : 22,
                        spreadRadius: _isHovered ? 8 : 5,
                      ),
                  ],
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: widget.subtle ? 17 : 18,
                  vertical: widget.subtle ? 10 : 12,
                ),
                child: Row(
                  textDirection: Directionality.of(context),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.record_voice_over_outlined,
                      color: AppColors.primaryGold,
                      size: widget.subtle ? 18 : 24,
                    ),
                    SizedBox(width: widget.subtle ? 8 : 10),
                    Text(
                      buttonText,
                      style: AppTextStyles.buttonLabel(context).copyWith(
                        color: Colors.white.withValues(
                          alpha: widget.subtle ? 0.92 : 1.0,
                        ),
                        fontSize: widget.subtle ? 13 : 14,
                        fontWeight: FontWeight.w800,
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
