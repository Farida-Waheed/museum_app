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
          decoration: BoxDecoration(
            color: AppColors.secondaryGlass(0.60),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.goldBorder(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
              BoxShadow(color: AppColors.bronzeGlow(0.035), blurRadius: 18),
            ],
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: _InfoCardHighlight()),
              Row(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryGold.withValues(alpha: 0.12),
                      border: Border.all(color: AppColors.goldBorder(0.14)),
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
                          textAlign: isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                          style: AppTextStyles.premiumSectionLabel(
                            context,
                          ).copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: isArabic
                              ? TextAlign.right
                              : TextAlign.left,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCardHighlight extends StatelessWidget {
  const _InfoCardHighlight();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.030),
              Colors.white.withValues(alpha: 0.008),
              Colors.transparent,
            ],
            stops: const [0.0, 0.20, 0.52],
          ),
        ),
      ),
    );
  }
}
