import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class HomeInfoCard extends StatelessWidget {
  const HomeInfoCard({
    super.key,
    required this.title,
    required this.body,
    required this.icon,
    this.bodyColor,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color? bodyColor;

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: AppDecorations.secondaryGlassCard(radius: 24),
          child: Row(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGold.withValues(alpha: 0.12),
                ),
                child: Icon(icon, color: AppColors.primaryGold, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: isArabic
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      style: AppTextStyles.premiumSectionLabel(
                        context,
                      ).copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      style: AppTextStyles.premiumBody(context).copyWith(
                        fontSize: 14,
                        color: bodyColor ?? AppColors.whiteTitle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
