import 'package:flutter/material.dart';
import '../screens/chat/chat_screen.dart';
import '../core/constants/colors.dart';
import '../core/constants/text_styles.dart';
import '../l10n/app_localizations.dart';

class RoboGuideEntry extends StatefulWidget {
  const RoboGuideEntry({super.key});

  @override
  State<RoboGuideEntry> createState() => _RoboGuideEntryState();
}

class _RoboGuideEntryState extends State<RoboGuideEntry> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _glowCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (context, child) {
        return AnimatedScale(
          scale: _pressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: () => showDialog(
              context: context,
              barrierColor: Colors.black54,
              builder: (_) => const ChatScreen(isPopup: true),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cinematicElevated,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.6 + (_glowCtrl.value * 0.4)), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.15 + (_glowCtrl.value * 0.25)),
                    blurRadius: 18,
                    spreadRadius: 3,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat_bubble_rounded, color: AppColors.primaryGold, size: 22),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.askTheGuide,
                        style: AppTextStyles.button(context).copyWith(color: Colors.white, fontSize: 14),
                      ),
                      Row(
                        children: [
                          Container(width: 7, height: 7, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(
                            l10n.alwaysAvailable,
                            style: AppTextStyles.metadata(context).copyWith(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
