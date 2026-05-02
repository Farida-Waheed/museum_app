import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class HomeStatsRow extends StatelessWidget {
  const HomeStatsRow({
    super.key,
    required this.items,
  });

  final List<HomeStatItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canFitRow = constraints.maxWidth >= 344;
        if (canFitRow) {
          return Row(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                Expanded(child: _StatCard(item: items[i])),
                if (i != items.length - 1) const SizedBox(width: 12),
              ],
            ],
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _StatCard(item: items[i]),
                if (i != items.length - 1) const SizedBox(width: 12),
              ],
            ],
          ),
        );
      },
    );
  }
}

class HomeStatItem {
  const HomeStatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final HomeStatItem item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 104,
          height: 88,
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.secondaryGlassCard(radius: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, color: AppColors.primaryGold, size: 22),
              const Spacer(),
              Text(
                item.value,
                style: AppTextStyles.premiumScreenTitle(context).copyWith(
                  fontSize: 19,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: AppTextStyles.premiumMutedBody(context).copyWith(
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
