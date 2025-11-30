import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Global shared flag so the alert shows only ONCE per app session.
bool _tourAlertShown = false;

/// Call this from ANY screen.
///
/// Example:
///   final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
///   showTourAlertOnce(
///     context,
///     isArabic: prefs.language == 'ar',
///     hallNameEn: 'Hall A',
///     hallNameAr: 'القاعة (أ)',
///     minutes: 5,
///     onViewMap: () => Navigator.pushNamed(context, AppRoutes.map),
///   );
///
/// It will:
///   ✓ wait a few seconds
///   ✓ play alert sound + haptic
///   ✓ show a top pop-up card
///   ✓ NEVER show again after first time
void showTourAlertOnce(
  BuildContext context, {
  required bool isArabic,
  String hallNameEn = 'Hall A',
  String hallNameAr = 'القاعة (أ)',
  int minutes = 5,
  VoidCallback? onViewMap,
}) {
  if (_tourAlertShown) return; // already shown before
  _tourAlertShown = true; // lock it

  // Capture navigator for safe mounted check later
  final navigator = Navigator.of(context);

  // Delay so it appears naturally in the flow
  Future.delayed(const Duration(seconds: 5), () async {
    if (!navigator.mounted) return;

    // Sound + tiny haptic feedback (like travel apps)
    await SystemSound.play(SystemSoundType.alert);
    HapticFeedback.mediumImpact();

    final title = isArabic ? "تنبيه الجولة" : "Tour Starting Soon";
    final hallName = isArabic ? hallNameAr : hallNameEn;
    final bodyText = isArabic
        ? "تبدأ جولة أنخو في $hallName خلال $minutes دقائق.\nيرجى التوجه لنقطة البداية."
        : "Ankhu’s tour in $hallName begins in $minutes minutes.\nPlease head to the starting point.";

    showGeneralDialog(
      context: navigator.context,
      barrierDismissible: true,
      barrierLabel: 'tour-alert',
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, _, __) {
        final primary = Theme.of(ctx).colorScheme.primary;

        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header row: Ankhu icon + title + close
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/ankh.png',
                            width: 26,
                            height: 26,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => navigator.pop(),
                            icon: const Icon(Icons.close, size: 18),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Body text
                      Align(
                        alignment: isArabic
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Text(
                          bodyText,
                          textAlign:
                              isArabic ? TextAlign.right : TextAlign.left,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Actions row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => navigator.pop(),
                            child: Text(isArabic ? "لاحقاً" : "Later"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              navigator.pop();
                              if (onViewMap != null) {
                                onViewMap();
                              }
                            },
                            child: Text(
                              isArabic ? "افتح الخريطة" : "Open Map",
                            ),
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
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.2),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(
            opacity: curved,
            child: child,
          ),
        );
      },
    );
  });
}
