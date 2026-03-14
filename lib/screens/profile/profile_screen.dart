import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/section_title.dart';
import '../../widgets/stat_card.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/bottom_nav.dart';
import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/user_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppMenuShell(
      title: l10n.profile,
      bottomNavigationBar: const BottomNav(currentIndex: 4),
      backgroundColor: AppColors.darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // A. Visitor Identity Header
            const _VisitorHeader(),
            const SizedBox(height: 32),

            // B. Visitor Statistics
            SectionTitle(title: l10n.visitorStats),
            const _VisitorStats(),
            const SizedBox(height: 16),

            // C. My Tours
            SectionTitle(title: l10n.myTours),
            const _MyTours(),
            const SizedBox(height: 32),

            // D. Saved Exhibits
            SectionTitle(title: l10n.savedExhibits),
            const _SavedExhibits(),
            const SizedBox(height: 32),

            // E. Learning Progress
            SectionTitle(title: l10n.learningProgress),
            const _LearningProgress(),
            const SizedBox(height: 32),

            // F. Quick Preferences
            SectionTitle(title: l10n.quickPreferences),
            const _QuickPreferences(),
            const SizedBox(height: 32),

            // G. My Tickets
            SectionTitle(title: l10n.myTickets),
            const _MyTickets(),
            const SizedBox(height: 48),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.alertRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: AppColors.darkSurface,
                ),
                child: Text(l10n.signOut, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}


class _VisitorHeader extends StatelessWidget {
  const _VisitorHeader();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.darkDivider),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: AppColors.primaryGold, shape: BoxShape.circle),
                child: const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.darkBackground,
                  child: Icon(Icons.person_outline, size: 40, color: Colors.white),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppColors.primaryGold, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, size: 12, color: AppColors.darkInk),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Guest Visitor", style: AppTextStyles.cardTitle(context).copyWith(fontSize: 20)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.explorer,
                    style: const TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(l10n.memberSince, style: AppTextStyles.helper(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitorStats extends StatelessWidget {
  const _VisitorStats();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        StatCard(icon: Icons.explore_outlined, value: "12", label: l10n.exhibits, isVertical: false),
        StatCard(icon: Icons.route_outlined, value: "03", label: l10n.tour, isVertical: false),
        StatCard(icon: Icons.auto_stories_outlined, value: "45", label: l10n.exhibit, isVertical: false),
        StatCard(icon: Icons.quiz_outlined, value: "850", label: l10n.quiz, isVertical: false),
      ],
    );
  }
}

class _MyTours extends StatelessWidget {
  const _MyTours();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkDivider),
      ),
      child: Column(
        children: [
          _TourRow(name: l10n.newKingdomHighlights, status: l10n.completed, progress: 1.0),
          const Divider(height: 32, color: AppColors.darkDivider),
          _TourRow(name: l10n.tutankhamunTreasures, status: l10n.inProgress, progress: 0.6),
        ],
      ),
    );
  }
}

class _TourRow extends StatelessWidget {
  final String name;
  final String status;
  final double progress;
  const _TourRow({required this.name, required this.status, required this.progress});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: AppTextStyles.cardTitle(context).copyWith(fontSize: 15)),
            Text(status, style: TextStyle(color: status == l10n.completed ? Colors.green : AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.darkBackground,
            valueColor: AlwaysStoppedAnimation<Color>(progress == 1.0 ? Colors.green : AppColors.primaryGold),
          ),
        ),
      ],
    );
  }
}

class _SavedExhibits extends StatelessWidget {
  const _SavedExhibits();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _SavedItem(image: "assets/images/pharaoh_head.jpg", name: l10n.tutMask),
          _SavedItem(image: "assets/images/museum_interior.jpg", name: l10n.ramesses2),
          _SavedItem(image: "assets/images/canopic_jars.jpg", name: l10n.canopicJars),
        ],
      ),
    );
  }
}

class _SavedItem extends StatelessWidget {
  final String image;
  final String name;
  const _SavedItem({required this.image, required this.name});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkDivider),
      ),
      child: Column(
        children: [
          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), child: Image.asset(image, fit: BoxFit.cover, width: double.infinity))),
          Padding(padding: const EdgeInsets.all(8.0), child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _LearningProgress extends StatelessWidget {
  const _LearningProgress();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkDivider),
      ),
      child: Column(
        children: [
          _LearningRow(label: l10n.ancientEgyptHistory, progress: 0.4),
          const SizedBox(height: 16),
          _LearningRow(label: l10n.hieroglyphBasics, progress: 0.1),
          const SizedBox(height: 16),
          _LearningRow(label: l10n.pharaohDynastyKnowledge, progress: 0.7),
        ],
      ),
    );
  }
}

class _LearningRow extends StatelessWidget {
  final String label;
  final double progress;
  const _LearningRow({required this.label, required this.progress});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13))),
        const SizedBox(width: 16),
        SizedBox(
          width: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: AppColors.darkBackground, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGold)),
          ),
        ),
        const SizedBox(width: 8),
        Text("${(progress * 100).round()}%", style: const TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _QuickPreferences extends StatelessWidget {
  const _QuickPreferences();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _QuickAction(icon: Icons.language, label: l10n.lang),
        _QuickAction(icon: Icons.dark_mode, label: l10n.dark),
        _QuickAction(icon: Icons.volume_up, label: l10n.audio),
        _QuickAction(icon: Icons.accessibility, label: l10n.access),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickAction({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.darkDivider)),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryGold, size: 20),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _MyTickets extends StatelessWidget {
  const _MyTickets();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.darkDivider)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primaryGold.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.confirmation_number_outlined, color: AppColors.primaryGold)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Grand Egyptian Museum", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Oct 25, 2023 • 10:00 AM", style: AppTextStyles.helper(context)),
              ],
            ),
          ),
          const Icon(Icons.qr_code_2, color: Colors.white70, size: 32),
        ],
      ),
    );
  }
}
