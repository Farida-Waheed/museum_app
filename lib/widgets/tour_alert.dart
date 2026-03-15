import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/assets.dart';
import '../core/constants/sizes.dart';
import '../core/constants/text_styles.dart';
import '../core/constants/colors.dart';

/// Shows tour alerts safely and avoids random glitches.
/// You can show it "once per key" (e.g., once per hall or tour).
///
/// Example key ideas:
/// - "tour_start_hall_a"
/// - "tour_start_hall_b"
/// - "tour_start_global"
final Set<String> _shownTourAlertKeys = {};

/// Reset all tour alerts (use when starting a new tour or for demo refresh).
void resetAllTourAlerts() {
  _shownTourAlertKeys.clear();
}

/// Reset one specific key only.
void resetTourAlertKey(String key) {
  _shownTourAlertKeys.remove(key);
}

/// Show an alert only once per [key].
/// If you want the old behavior (once per session), use a fixed key like "global".
void showTourAlertOnce(
  BuildContext context, {
  required String key,
  required bool isArabic,
  String hallNameEn = 'Hall A',
  String hallNameAr = 'القاعة (أ)',
  int minutes = 5,
  Duration delay = const Duration(seconds: 3),
  VoidCallback? onViewMap,
}) {
  if (_shownTourAlertKeys.contains(key)) return;
  _shownTourAlertKeys.add(key);

  final navigator = Navigator.of(context);

  Future.delayed(delay, () async {
    if (!navigator.mounted) return;

    // Sound + haptic feedback
    await SystemSound.play(SystemSoundType.alert);
    HapticFeedback.mediumImpact();

    final title = isArabic ? "تنبيه الجولة" : "Tour Starting Soon";
    final hallName = isArabic ? hallNameAr : hallNameEn;

    final bodyText = isArabic
        ? "تبدأ الجولة في $hallName خلال $minutes دقائق.\nيرجى التوجه لنوقة البداية."
        : "The tour in $hallName begins in $minutes minutes.\nPlease head to the starting point.";

    if (!navigator.context.mounted) return;

    showGeneralDialog(
      context: navigator.context,
      barrierDismissible: true,
      barrierLabel: 'tour-alert',
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (ctx, _, __) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                color: AppColors.cinematicElevated,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.md,
                    AppSizes.sm,
                    AppSizes.md,
                    AppSizes.sm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            AppAssets.ankhIcon,
                            width: 26,
                            height: 26,
                            errorBuilder: (_, __, ___) => const Icon(Icons.notifications),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Text(
                              title,
                              style: AppTextStyles.cardTitle(ctx).copyWith(fontSize: 16),
                            ),
                          ),
                          IconButton(
                            onPressed: () => navigator.pop(),
                            icon: const Icon(Icons.close, size: 18, color: Colors.white54),
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: isArabic
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Text(
                          bodyText,
                          textAlign: isArabic ? TextAlign.right : TextAlign.left,
                          style: AppTextStyles.body(ctx).copyWith(
                            color: Colors.white.withOpacity(0.92),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => navigator.pop(),
                            child: Text(isArabic ? "لاحقاً" : "Later", style: AppTextStyles.button(ctx).copyWith(color: AppColors.neutralMedium)),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGold,
                              foregroundColor: AppColors.darkInk,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                              ),
                            ),
                            onPressed: () {
                              navigator.pop();
                              onViewMap?.call();
                            },
                            child: Text(isArabic ? "افتح الخريطة" : "Open Map", style: AppTextStyles.button(ctx)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  });
}
