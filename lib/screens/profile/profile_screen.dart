import 'package:flutter/material.dart';
import '../../widgets/app_menu_shell.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/bottom_nav.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return AppMenuShell(
      title: l10n.profile.toUpperCase(),
      bottomNavigationBar: const BottomNav(currentIndex: 4),
      backgroundColor: AppColors.darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // A. Visitor Identity Header
            _VisitorHeader(isArabic: isArabic, l10n: l10n),
            const SizedBox(height: 32),

            // B. Visitor Statistics
            _SectionTitle(title: isArabic ? "إحصائيات الزائر" : "Visitor Statistics"),
            _VisitorStats(isArabic: isArabic),
            const SizedBox(height: 32),

            // C. My Tours
            _SectionTitle(title: isArabic ? "جولاتي" : "My Tours"),
            _MyTours(isArabic: isArabic),
            const SizedBox(height: 32),

            // D. Saved Exhibits
            _SectionTitle(title: isArabic ? "المعروضات المحفوظة" : "Saved Exhibits"),
            _SavedExhibits(isArabic: isArabic),
            const SizedBox(height: 32),

            // E. Learning Progress
            _SectionTitle(title: isArabic ? "تقدم التعلم" : "Learning Progress"),
            _LearningProgress(isArabic: isArabic),
            const SizedBox(height: 32),

            // F. Quick Preferences
            _SectionTitle(title: isArabic ? "التفضيلات السريعة" : "Quick Preferences"),
            _QuickPreferences(isArabic: isArabic),
            const SizedBox(height: 32),

            // G. My Tickets
            _SectionTitle(title: isArabic ? "تذاكري" : "My Tickets"),
            _MyTickets(isArabic: isArabic),
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
                child: Text(isArabic ? "تسجيل الخروج" : "Sign Out", style: AppTextStyles.buttonLabel(context).copyWith(color: AppColors.alertRed)),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Text(title.toUpperCase(), style: AppTextStyles.displaySectionTitle(context)),
      ),
    );
  }
}

class _VisitorHeader extends StatelessWidget {
  final bool isArabic;
  final AppLocalizations l10n;
  const _VisitorHeader({required this.isArabic, required this.l10n});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                Text(l10n.guestVisitor, style: AppTextStyles.titleLarge(context).copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isArabic ? "مستكشف" : "Explorer",
                    style: AppTextStyles.metadata(context).copyWith(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 8),
                Text(isArabic ? "عضو منذ أكتوبر ٢٠٢٣" : "Member since Oct 2023", style: AppTextStyles.metadata(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitorStats extends StatelessWidget {
  final bool isArabic;
  const _VisitorStats({required this.isArabic});
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(icon: Icons.explore_outlined, count: "12", label: isArabic ? "معرض مستكشف" : "Exhibits"),
        _StatCard(icon: Icons.route_outlined, count: "03", label: isArabic ? "جولة مكتملة" : "Tours"),
        _StatCard(icon: Icons.auto_stories_outlined, count: "45", label: isArabic ? "قطع تم تعلمها" : "Artifacts"),
        _StatCard(icon: Icons.quiz_outlined, count: "850", label: isArabic ? "نقاط الاختبار" : "Quiz Score"),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  const _StatCard({required this.icon, required this.count, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 20),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(count, style: AppTextStyles.titleLarge(context)),
              const SizedBox(width: 4),
              Flexible(child: Text(label, style: AppTextStyles.metadata(context).copyWith(fontSize: 10), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MyTours extends StatelessWidget {
  final bool isArabic;
  const _MyTours({required this.isArabic});
  @override
  Widget build(BuildContext context) {
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
          _TourRow(name: isArabic ? "أبرز مقتنيات الدولة الحديثة" : "New Kingdom Highlights", status: "Completed", progress: 1.0),
          const Divider(height: 32, color: AppColors.darkDivider),
          _TourRow(name: isArabic ? "جولة كنوز توت عنخ آمون" : "Tutankhamun Treasures", status: "In Progress", progress: 0.6),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: AppTextStyles.titleMedium(context).copyWith(fontSize: 15)),
            Text(status, style: AppTextStyles.metadata(context).copyWith(color: status == "Completed" ? Colors.green : AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 11)),
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
  final bool isArabic;
  const _SavedExhibits({required this.isArabic});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _SavedItem(image: "assets/images/pharaoh_head.jpg", name: isArabic ? "قناع توت عنخ آمون" : "Tut Mask"),
          _SavedItem(image: "assets/images/museum_interior.jpg", name: isArabic ? "تمثال رمسيس" : "Ramesses II"),
          _SavedItem(image: "assets/images/canopic_jars.jpg", name: isArabic ? "أواني كانوبية" : "Canopic Jars"),
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
          Padding(padding: const EdgeInsets.all(8.0), child: Text(name, style: AppTextStyles.metadata(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _LearningProgress extends StatelessWidget {
  final bool isArabic;
  const _LearningProgress({required this.isArabic});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkDivider),
      ),
      child: Column(
        children: [
          _LearningRow(label: isArabic ? "تاريخ مصر القديمة" : "Ancient Egypt History", progress: 0.4),
          const SizedBox(height: 16),
          _LearningRow(label: isArabic ? "أساسيات الهيروغليفية" : "Hieroglyph Basics", progress: 0.1),
          const SizedBox(height: 16),
          _LearningRow(label: isArabic ? "معرفة الأسر الفرعونية" : "Pharaoh Dynasty Knowledge", progress: 0.7),
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
        Expanded(child: Text(label, style: AppTextStyles.bodyPrimary(context).copyWith(color: Colors.white, fontSize: 13))),
        const SizedBox(width: 16),
        SizedBox(
          width: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: AppColors.darkBackground, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGold)),
          ),
        ),
        const SizedBox(width: 8),
        Text("${(progress * 100).round()}%", style: AppTextStyles.metadata(context).copyWith(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }
}

class _QuickPreferences extends StatelessWidget {
  final bool isArabic;
  const _QuickPreferences({required this.isArabic});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickAction(icon: Icons.language, label: isArabic ? "اللغة" : "Lang"),
        _QuickAction(icon: Icons.dark_mode, label: isArabic ? "المظهر" : "Dark"),
        _QuickAction(icon: Icons.volume_up, label: isArabic ? "الصوت" : "Audio"),
        _QuickAction(icon: Icons.accessibility, label: isArabic ? "الوصول" : "Access"),
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
            Text(label, style: AppTextStyles.metadata(context).copyWith(color: Colors.white, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _MyTickets extends StatelessWidget {
  final bool isArabic;
  const _MyTickets({required this.isArabic});
  @override
  Widget build(BuildContext context) {
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
                Text(isArabic ? "المتحف المصري الكبير" : "Grand Egyptian Museum", style: AppTextStyles.bodyPrimary(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                Text("Oct 25, 2023 • 10:00 AM", style: AppTextStyles.metadata(context)),
              ],
            ),
          ),
          const Icon(Icons.qr_code_2, color: Colors.white70, size: 32),
        ],
      ),
    );
  }
}
