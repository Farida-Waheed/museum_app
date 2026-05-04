import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class HomeQuickActionItem {
  const HomeQuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? subtitle;
}

class HomeQuickActionsGrid extends StatelessWidget {
  const HomeQuickActionsGrid({super.key, required this.items});

  final List<HomeQuickActionItem> items;

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.34,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGlass(0.60),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.goldBorder(0.16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.24),
                        blurRadius: 18,
                        offset: const Offset(0, 9),
                      ),
                      BoxShadow(
                        color: AppColors.bronzeGlow(0.035),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      const Positioned.fill(child: _QuickActionHighlight()),
                      Column(
                        crossAxisAlignment: isArabic
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.cardGlass(0.62),
                              border: Border.all(
                                color: AppColors.goldBorder(0.18),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.20),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              item.icon,
                              color: AppColors.primaryGold,
                              size: 26,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: isArabic
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: isArabic
                                    ? TextAlign.right
                                    : TextAlign.left,
                                style: AppTextStyles.premiumCardTitle(
                                  context,
                                ).copyWith(fontSize: 16),
                              ),
                              if (item.subtitle != null) ...[
                                const SizedBox(height: 3),
                                Text(
                                  item.subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: isArabic
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  style: AppTextStyles.premiumMutedBody(
                                    context,
                                  ).copyWith(fontSize: 12),
                                ),
                              ],
                            ],
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
    );
  }
}

class _QuickActionHighlight extends StatelessWidget {
  const _QuickActionHighlight();

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
            stops: const [0.0, 0.18, 0.52],
          ),
        ),
      ),
    );
  }
}
