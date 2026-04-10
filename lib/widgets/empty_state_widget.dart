import 'package:flutter/material.dart';
import '../core/constants/text_styles.dart';
import '../core/constants/sizes.dart';
import '../core/constants/colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.primaryGold),
          const SizedBox(height: AppSizes.md),
          Text(
            title,
            style: AppTextStyles.titleLarge(context).copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              subtitle!,
              style: AppTextStyles.bodyPrimary(context),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
