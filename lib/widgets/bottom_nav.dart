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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cinematicNav : AppColors.warmSurface,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.goldBorder(0.10)
                : AppColors.mutedText.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: handleTap,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primaryGold,
            unselectedItemColor: isDark
                ? AppColors.darkMutedText
                : AppColors.mutedText,
            showUnselectedLabels: true,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: AppTextStyles.premiumNavLabel(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
            unselectedLabelStyle: AppTextStyles.premiumNavLabel(context),
            elevation: 0,
            backgroundColor: Colors.transparent,
            items: [
              _buildNavItem(Icons.home_outlined, Icons.home_rounded, l10n.home),
              _buildNavItem(Icons.map_outlined, Icons.map_rounded, l10n.map),
              _buildNavItem(
                Icons.confirmation_number_outlined,
                Icons.confirmation_number_rounded,
                l10n.tickets,
              ),
              _buildNavItem(
                Icons.photo_library_outlined,
                Icons.photo_library_rounded,
                l10n.memories,
              ),
              _buildNavItem(
                Icons.person_outline,
                Icons.person_rounded,
                l10n.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 22),
      activeIcon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(activeIcon, size: 23),
          const SizedBox(height: 4),
          Container(
            width: 16,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.primaryGold,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
      label: label,
    );
  }
}
