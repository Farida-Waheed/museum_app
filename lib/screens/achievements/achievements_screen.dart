import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_menu_shell.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/bottom_nav.dart';
import '../../models/tour_provider.dart';
import '../../widgets/app_card.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tourProvider = Provider.of<TourProvider>(context);
    final visitedCount = tourProvider.visitedExhibitIds.length;

    return AppMenuShell(
      title: l10n.myJourney.toUpperCase(),
      backgroundColor: AppColors.cinematicBackground,
      bottomNavigationBar: const BottomNav(currentIndex: 4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cinematicCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.stars,
                    size: 48,
                    color: AppColors.primaryGold,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.exhibitsFound.toUpperCase(),
                          style: AppTextStyles.displaySectionTitle(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$visitedCount",
                          style: AppTextStyles.titleLarge(context).copyWith(
                            fontSize: 32,
                            color: AppColors.primaryGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.achievements.toUpperCase(),
              style: AppTextStyles.displaySectionTitle(context),
            ),
            const SizedBox(height: 16),
            _buildAchievementTile(
              context,
              Icons.explore,
              l10n.pioneer,
              l10n.pioneerDesc,
              visitedCount >= 1,
            ),
            _buildAchievementTile(
              context,
              Icons.history_edu,
              l10n.scholar,
              l10n.scholarDesc,
              false,
            ),
            _buildAchievementTile(
              context,
              Icons.map,
              l10n.wayfinder,
              l10n.wayfinderDesc,
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool isUnlocked,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cinematicCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked
              ? AppColors.primaryGold.withOpacity(0.3)
              : Colors.white.withOpacity(0.03),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(
          icon,
          color: isUnlocked ? AppColors.primaryGold : AppColors.neutralDark,
        ),
        title: Text(
          title,
          style: AppTextStyles.titleMedium(context).copyWith(
            fontSize: 16,
            color: isUnlocked ? Colors.white : AppColors.neutralMedium,
          ),
        ),
        subtitle: Text(subtitle, style: AppTextStyles.metadata(context)),
        trailing: isUnlocked
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(
                Icons.lock_outline,
                size: 18,
                color: AppColors.neutralDark,
              ),
      ),
    );
  }
}
