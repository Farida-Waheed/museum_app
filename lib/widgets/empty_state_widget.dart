import 'package:flutter/material.dart';
import '../core/constants/text_styles.dart';
import '../core/constants/sizes.dart';

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
          Icon(icon, size: 48),
          const SizedBox(height: AppSizes.md),
          Text(title, style: AppTextStyles.title(context), textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: AppSizes.sm),
            Text(subtitle!, style: AppTextStyles.body(context), textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
