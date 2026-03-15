import 'package:flutter/material.dart';
import '../../widgets/app_menu_shell.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/primary_button.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

class TourPlannerScreen extends StatelessWidget {
  const TourPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return AppMenuShell(
      title: l10n.tourPlanner,
      backgroundColor: AppColors.cinematicBackground,
      bottomNavigationBar: const BottomNav(currentIndex: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.auto_awesome, size: 48, color: AppColors.primaryGold),
            const SizedBox(height: 20),
            Text(
              l10n.tourPlanner.toUpperCase(),
              style: AppTextStyles.sectionTitle(context),
            ),
            const SizedBox(height: 12),
            Text(
              isArabic
                  ? "قم بتخصيص جولتك في المتحف بناءً على اهتماماتك والوقت المتاح."
                  : "Customize your museum tour based on your interests and available time.",
              style: AppTextStyles.body(context).copyWith(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            _buildInterestSection(context, l10n),
            const SizedBox(height: 48),
            PrimaryButton(
              label: isArabic ? "إنشاء مساري" : "Generate My Route",
              onPressed: () => Navigator.pushNamed(context, '/map'),
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestSection(BuildContext context, AppLocalizations l10n) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final interests = isArabic
        ? ["الملوك", "الحياة اليومية", "التحنيط", "الفن العمارة"]
        : ["Royalty", "Daily Life", "Mummification", "Architecture"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? "ما هي اهتماماتك؟" : "What are your interests?",
          style: AppTextStyles.cardTitle(context).copyWith(fontSize: 18),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: interests.map((i) => _InterestChip(label: i)).toList(),
        ),
      ],
    );
  }
}

class _InterestChip extends StatefulWidget {
  final String label;
  const _InterestChip({required this.label});

  @override
  State<_InterestChip> createState() => _InterestChipState();
}

class _InterestChipState extends State<_InterestChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(widget.label, style: AppTextStyles.helper(context).copyWith(color: _selected ? AppColors.darkInk : Colors.white, fontWeight: FontWeight.bold)),
      selected: _selected,
      onSelected: (val) => setState(() => _selected = val),
      selectedColor: AppColors.primaryGold,
      checkmarkColor: AppColors.darkInk,
      backgroundColor: AppColors.cinematicCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _selected ? AppColors.primaryGold : Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }
}
