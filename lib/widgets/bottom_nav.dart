import 'package:flutter/material.dart';
import '../app/router.dart';
import '../l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import '../core/constants/text_styles.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void handleTap(int index) {
      if (index == 0) {
        // Home must reset navigation stack
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.mainHome, (route) => false);
        return;
      }

      if (index == currentIndex) return;

      String route;
      switch (index) {
        case 1:
          route = AppRoutes.map;
          break;
        case 2:
          route = AppRoutes.liveTour;
          break;
        case 3:
          route = AppRoutes.tickets;
          break;
        case 4:
        default:
          route = AppRoutes.profile;
          break;
      }

      Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cinematicNav : AppColors.warmSurface,
        border: Border(top: BorderSide(color: isDark ? AppColors.cinematicSection : AppColors.mutedText.withOpacity(0.1))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: handleTap,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primaryGold,
            unselectedItemColor: isDark ? AppColors.darkMutedText : AppColors.mutedText,
            showUnselectedLabels: true,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: AppTextStyles.navLabel(context).copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppTextStyles.navLabel(context),
            elevation: 0,
            backgroundColor: Colors.transparent,
            items: [
              _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, l10n.home),
              _buildNavItem(1, Icons.map_outlined, Icons.map_rounded, l10n.map),
              _buildNavItem(2, Icons.radio_button_checked_outlined, Icons.radio_button_checked_rounded, l10n.tour),
              _buildNavItem(3, Icons.confirmation_number_outlined, Icons.confirmation_number_rounded, l10n.tickets),
              _buildNavItem(4, Icons.person_outline, Icons.person_rounded, l10n.profile),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 22),
      activeIcon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(activeIcon, size: 24),
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
