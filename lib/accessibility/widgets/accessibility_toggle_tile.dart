import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

/// A branded, fully-accessible toggle row. Reused by every later accessibility
/// screen so switches look and behave identically app-wide (spec #17).
///
/// Accessibility built in:
/// * Wrapped in [Semantics] as a toggle with a live label + hint, so screen
///   readers announce state changes correctly.
/// * A minimum 48dp (or larger) tap target across the whole row.
/// * RTL-aware layout via directional widgets.
///
/// The [title]/[subtitle]/[semanticHint] are passed in already localized.
class AccessibilityToggleTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData? icon;
  final String? semanticHint;
  final double minHeight;

  const AccessibilityToggleTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
    this.semanticHint,
    this.minHeight = 48,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = Theme.of(context).colorScheme.onSurface;
    final enabled = onChanged != null;

    return Semantics(
      toggled: value,
      enabled: enabled,
      label: title,
      hint: semanticHint,
      // Exclude descendants so the row is announced once, not field-by-field.
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? () => onChanged!(!value) : null,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.primaryGold, size: 22),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyPrimary(context).copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTextStyles.metadata(context)
                              .copyWith(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch.adaptive(
                  value: value,
                  onChanged: onChanged,
                  activeTrackColor:
                      AppColors.primaryGold.withValues(alpha: 0.36),
                  activeThumbColor: AppColors.primaryGold,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
