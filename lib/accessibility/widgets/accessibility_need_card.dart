import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../l10n/accessibility_category_presentation.dart';

/// A selectable, multi-select-friendly card representing one accessibility
/// category in the setup wizard. Brand-consistent (gold accent, glass surface),
/// fully accessible (announced as a checkbox with label + description), and
/// RTL-aware. A visitor may select several of these at once.
class AccessibilityNeedCard extends StatelessWidget {
  final AccessibilityCategoryPresentation presentation;
  final bool selected;
  final VoidCallback onTap;
  final double minHeight;

  const AccessibilityNeedCard({
    super.key,
    required this.presentation,
    required this.selected,
    required this.onTap,
    this.minHeight = 72,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = Theme.of(context).colorScheme.onSurface;

    return Semantics(
      button: true,
      checked: selected,
      inMutuallyExclusiveGroup: false,
      label: presentation.label,
      hint: presentation.description,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: BoxConstraints(minHeight: minHeight),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryGold.withValues(alpha: 0.14)
                : AppColors.secondaryGlass(0.52),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primaryGold.withValues(alpha: 0.75)
                  : AppColors.goldBorder(0.16),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold
                      .withValues(alpha: selected ? 0.20 : 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(presentation.icon,
                    color: AppColors.primaryGold, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      presentation.label,
                      style: AppTextStyles.bodyPrimary(context).copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      presentation.description,
                      style: AppTextStyles.metadata(context).copyWith(
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _SelectionIndicator(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  final bool selected;
  const _SelectionIndicator({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primaryGold : Colors.transparent,
        border: Border.all(
          color: selected
              ? AppColors.primaryGold
              : AppColors.resolvedMutedText.withValues(alpha: 0.5),
          width: 1.6,
        ),
      ),
      child: selected
          ? const Icon(Icons.check, size: 16, color: AppColors.darkInk)
          : null,
    );
  }
}
