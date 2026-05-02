import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class LiveStatusCard extends StatelessWidget {
  const LiveStatusCard({
    super.key,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.isArabic,
    this.trailingLabel,
  });

  final String label;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isArabic;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: const BoxConstraints(minHeight: 116),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: AppDecorations.premiumGlassCard(
              radius: 28,
              highlighted: true,
            ),
            child: Row(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGold.withValues(alpha: 0.12),
                    border: Border.all(color: AppColors.goldBorder(0.22)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.softGlow(0.12),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: AppColors.primaryGold, size: 27),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: isArabic
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        style: AppTextStyles.premiumSectionLabel(
                          context,
                        ).copyWith(fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        style: AppTextStyles.premiumCardTitle(
                          context,
                        ).copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        style: AppTextStyles.premiumMutedBody(
                          context,
                        ).copyWith(color: AppColors.bodyText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: isArabic
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    if (trailingLabel != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          trailingLabel!,
                          style: AppTextStyles.premiumMutedBody(
                            context,
                          ).copyWith(color: AppColors.softGold, fontSize: 12),
                        ),
                      ),
                    Icon(
                      isArabic
                          ? Icons.arrow_back_ios_rounded
                          : Icons.arrow_forward_ios_rounded,
                      color: AppColors.softGold.withValues(alpha: 0.7),
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
