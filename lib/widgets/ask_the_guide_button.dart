import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/constants/text_styles.dart';
import '../l10n/app_localizations.dart';
import '../screens/chat/chat_screen.dart';

/// Unified floating Ask the Guide component for AI assistant access.
/// Used consistently across all relevant screens.
///
/// Features:
/// - Premium visual design with glowing animation
/// - Consistent "Ask the Guide" title
/// - "Discover the story behind everything" subtitle
/// - Opens AI chat popup immediately
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
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final buttonText = widget.subtle
        ? (isArabic ? 'اسأل' : 'Ask')
        : l10n.askButton;
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
                  borderRadius: BorderRadius.circular(widget.subtle ? 24 : 30),
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
                      blurRadius: widget.subtle ? 6 : 24,
                      offset: Offset(0, widget.subtle ? 3 : 12),
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
                  horizontal: widget.subtle ? 13 : 18,
                  vertical: widget.subtle ? 8 : 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.primaryGold,
                      size: widget.subtle ? 16 : 24,
                    ),
                    SizedBox(width: widget.subtle ? 6 : 10),
                    Text(
                      buttonText,
                      style: AppTextStyles.buttonLabel(context).copyWith(
                        color: Colors.white.withValues(
                          alpha: widget.subtle ? 0.92 : 1.0,
                        ),
                        fontSize: widget.subtle ? 12 : 14,
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
