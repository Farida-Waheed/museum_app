import 'package:flutter/material.dart';
import '../../widgets/app_menu_shell.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/primary_button.dart';

class TourPlannerScreen extends StatelessWidget {
  const TourPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppMenuShell(
      title: l10n.tourPlanner,
      bottomNavigationBar: const BottomNav(currentIndex: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.auto_awesome, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              l10n.tourPlanner,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? "قم بتخصيص جولتك في المتحف بناءً على اهتماماتك والوقت المتاح."
                  : "Customize your museum tour based on your interests and available time.",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            _buildInterestSection(context, l10n),
            const SizedBox(height: 32),
            PrimaryButton(
              label: Localizations.localeOf(context).languageCode == 'ar' ? "إنشاء مساري" : "Generate My Route",
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
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
      label: Text(widget.label),
      selected: _selected,
      onSelected: (val) => setState(() => _selected = val),
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
    );
  }
}
