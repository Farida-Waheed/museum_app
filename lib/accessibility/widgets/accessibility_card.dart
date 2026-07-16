import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

/// A branded glass card for accessibility surfaces. Wraps the app's existing
/// [AppDecorations.secondaryGlassCard] so every accessibility screen shares one
/// consistent container — no bespoke styling, no divergence from the Horus-Bot
/// visual identity. Reusable across all later phases (spec #17).
///
/// User-facing strings are passed in by callers (already localized), so this
/// widget never hardcodes text.
class AccessibilityCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final IconData? leadingIcon;
  final String? title;
  final String? subtitle;

  /// Optional semantics label for the whole card (falls back to title).
  final String? semanticLabel;

  const AccessibilityCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.leadingIcon,
    this.title,
    this.subtitle,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = Theme.of(context).colorScheme.onSurface;
    final hasHeader = title != null || leadingIcon != null;

    return Semantics(
      container: true,
      label: semanticLabel ?? title,
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: AppDecorations.secondaryGlassCard(radius: radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasHeader) ...[
              Row(
                children: [
                  if (leadingIcon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(leadingIcon,
                          color: AppColors.primaryGold, size: 22),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null)
                          Text(
                            title!,
                            style: AppTextStyles.titleMedium(context).copyWith(
                              color: titleColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: AppTextStyles.metadata(context)
                                .copyWith(fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
