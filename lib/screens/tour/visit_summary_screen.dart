import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/tour_provider.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/primary_button.dart';

class VisitSummaryScreen extends StatelessWidget {
  const VisitSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tourProvider = Provider.of<TourProvider>(context);
    final visitedCount = tourProvider.visitedExhibitIds.length;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final totalQuizScore = tourProvider.quizScores.values.fold(0, (sum, score) => sum + score);
    final totalQuizzesCompleted = tourProvider.quizScores.length;
    final skippedQuizzesCount = tourProvider.skippedQuizzes.length;

    return AppMenuShell(
      title: l10n.visitSummary,
      backgroundColor: AppColors.darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          children: [
            // 1. Trophy Icon with Glow
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGold.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(color: AppColors.primaryGold.withOpacity(0.1), blurRadius: 40, spreadRadius: 10),
                    ],
                  ),
                ),
                const Icon(Icons.emoji_events_rounded, size: 80, color: AppColors.primaryGold),
              ],
            ),
            const SizedBox(height: 32),

            // 2. Main Congrats
            Text(l10n.congrats, style: AppTextStyles.screenTitle(context).copyWith(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Colors.white)),
            const SizedBox(height: 12),
            Text(
              l10n.visitComplete,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(context).copyWith(fontSize: 16, color: AppColors.helperText, height: 1.5),
            ),
            const SizedBox(height: 48),

            // 3. Stats Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.darkDivider),
              ),
              child: Column(
                children: [
                  _buildStatRow(context, l10n.exhibitsVisited, "$visitedCount", Icons.museum_outlined),
                  const Divider(height: 32, thickness: 1, color: AppColors.darkDivider),
                  _buildStatRow(context, l10n.totalTime, "45 min", Icons.timer_outlined),
                  const Divider(height: 32, thickness: 1, color: AppColors.darkDivider),
                  _buildStatRow(
                    context,
                    isArabic ? "الاختبارات المكتملة" : "Quizzes Completed",
                    "$totalQuizzesCompleted",
                    Icons.quiz_outlined,
                  ),
                  if (totalQuizzesCompleted > 0) ...[
                    const SizedBox(height: 8),
                    _buildStatRow(
                      context,
                      isArabic ? "إجمالي النقاط" : "Total Quiz Score",
                      "$totalQuizScore",
                      Icons.star_outline,
                      valueColor: AppColors.primaryGold,
                    ),
                  ],
                  if (skippedQuizzesCount > 0) ...[
                    const Divider(height: 32, thickness: 1, color: AppColors.darkDivider),
                    _buildStatRow(
                      context,
                      isArabic ? "اختبارات لم تُحل" : "Skipped Quizzes",
                      "$skippedQuizzesCount",
                      Icons.help_outline,
                      valueColor: AppColors.helperText,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 56),

            // 4. Primary Actions
            PrimaryButton(
              label: l10n.shareVisit,
              onPressed: () {},
              icon: Icons.share,
              fullWidth: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: AppColors.primaryGold),
                ),
                child: Text(
                  l10n.done,
                  style: AppTextStyles.button(context).copyWith(color: AppColors.primaryGold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, IconData icon, {Color valueColor = AppColors.primaryGold}) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.helperText),
        const SizedBox(width: 16),
        Text(label, style: AppTextStyles.body(context).copyWith(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
        const Spacer(),
        Text(value, style: AppTextStyles.statNumber(context).copyWith(fontSize: 18, fontWeight: FontWeight.w900, color: valueColor)),
      ],
    );
  }
}
