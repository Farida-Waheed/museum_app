import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/primary_button.dart';

class TourPlannerScreen extends StatelessWidget {
  const TourPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final interests = isArabic
        ? const ['الملوك', 'الحياة اليومية', 'التحنيط', 'العمارة']
        : const ['Royalty', 'Daily Life', 'Mummification', 'Architecture'];

    return AppMenuShell(
      title: l10n.tourPlanner.toUpperCase(),
      backgroundColor: AppColors.cinematicBackground,
      bottomNavigationBar: const BottomNav(currentIndex: 4),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradients.screenBackground,
        ),
        child: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 28, 20, 120),
            child: Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _PlannerIntroCard(l10n: l10n, isArabic: isArabic),
                const SizedBox(height: 28),
                Text(
                  (isArabic ? 'ما هي اهتماماتك؟' : 'What are your interests?')
                      .toUpperCase(),
                  style: AppTextStyles.displaySectionTitle(
                    context,
                  ).copyWith(color: AppColors.softGold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: interests
                      .map((interest) => _InterestChip(label: interest))
                      .toList(),
                ),
                const SizedBox(height: 36),
                PrimaryButton(
                  label: isArabic ? 'إنشاء مساري' : 'Generate My Route',
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.map),
                  fullWidth: true,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.buyTickets),
                    icon: const Icon(Icons.confirmation_number_outlined),
                    label: Text(isArabic ? 'حجز التذاكر' : 'Buy Tickets'),
                    style: AppDecorations.secondaryButton(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlannerIntroCard extends StatelessWidget {
  const _PlannerIntroCard({required this.l10n, required this.isArabic});

  final AppLocalizations l10n;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: AppDecorations.premiumGlassCard(
        radius: 24,
        highlighted: true,
      ),
      child: Row(
        textDirection: Directionality.of(context),
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.premiumGold,
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.darkInk),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tourPlanner,
                  textAlign: TextAlign.start,
                  style: AppTextStyles.titleLarge(
                    context,
                  ).copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  isArabic
                      ? 'خصص جولتك في المتحف حسب اهتماماتك والوقت المتاح.'
                      : 'Customize your museum tour based on your interests and available time.',
                  textAlign: TextAlign.start,
                  style: AppTextStyles.bodyPrimary(
                    context,
                  ).copyWith(color: AppColors.neutralMedium, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestChip extends StatefulWidget {
  const _InterestChip({required this.label});

  final String label;

  @override
  State<_InterestChip> createState() => _InterestChipState();
}

class _InterestChipState extends State<_InterestChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        widget.label,
        style: AppTextStyles.metadata(context).copyWith(
          color: _selected ? AppColors.darkInk : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: _selected,
      onSelected: (value) => setState(() => _selected = value),
      selectedColor: AppColors.primaryGold,
      checkmarkColor: AppColors.darkInk,
      backgroundColor: AppColors.cinematicCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _selected ? AppColors.primaryGold : AppColors.goldBorder(0.14),
        ),
      ),
    );
  }
}
