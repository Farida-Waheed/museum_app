import 'dart:ui';

import 'package:flutter/material.dart';

import '../app/router.dart';
import '../core/constants/colors.dart';
import '../core/constants/text_styles.dart';
import '../l10n/app_localizations.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void handleTap(int index) {
      if (index == currentIndex) return;

      final route = switch (index) {
        0 => AppRoutes.mainHome,
        1 => AppRoutes.map,
        2 => AppRoutes.tickets,
        3 => AppRoutes.memories,
        _ => AppRoutes.profile,
      };

      Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
    }

    final items = [
      _NavItem(Icons.home_outlined, Icons.home_rounded, l10n.home),
      _NavItem(Icons.map_outlined, Icons.map_rounded, l10n.map),
      _NavItem(
        Icons.confirmation_number_outlined,
        Icons.confirmation_number_rounded,
        l10n.tickets,
      ),
      _NavItem(
        Icons.photo_library_outlined,
        Icons.photo_library_rounded,
        l10n.memories,
      ),
      _NavItem(Icons.person_outline, Icons.person_rounded, l10n.profile),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.cinematicNav : AppColors.warmSurface)
                    .withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? AppColors.goldBorder(0.20)
                      : AppColors.mutedText.withValues(alpha: 0.12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavButton(
                        item: items[i],
                        selected: i == currentIndex,
                        isDark: isDark,
                        onTap: () => handleTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.activeIcon, this.label);

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.primaryGold
        : (isDark ? AppColors.darkMutedText : AppColors.mutedText);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryGold.withValues(alpha: 0.13)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: selected
              ? Border.all(color: AppColors.goldBorder(0.28))
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.premiumNavLabel(context).copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
