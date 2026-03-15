import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';

class ProjectInfoScreen extends StatelessWidget {
  const ProjectInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : AppColors.darkInk;
    final secondaryTextColor = isDark ? Colors.white70 : AppColors.mutedText;

    return AppMenuShell(
      title: "About Horus-Bot",
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.warmSurface,
      bottomNavigationBar: BottomNav(currentIndex: 4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _InfoCard(
              child: Column(
                children: [
                  Image.asset("assets/icons/ankh.png", width: 64, height: 64),
                  const SizedBox(height: 16),
                  Text(
                    "Horus-Bot",
                    style: AppTextStyles.screenTitle(context).copyWith(fontSize: 28, fontWeight: FontWeight.w900, color: textColor, letterSpacing: 1),
                  ),
                  Text(
                    "Version 1.0",
                    style: AppTextStyles.helper(context).copyWith(fontSize: 14, color: AppColors.primaryGold, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Smart Autonomous Museum Guide",
                    style: AppTextStyles.body(context).copyWith(fontSize: 16, color: secondaryTextColor, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            _SectionTitle(title: "Project Description"),
            _InfoCard(
              child: Text(
                "Horus-Bot is a smart autonomous museum guide robot designed to enhance museum visitor experience through autonomous navigation, multilingual interaction, and a companion mobile application.",
                style: AppTextStyles.body(context).copyWith(fontSize: 15, color: textColor, height: 1.6),
              ),
            ),

            const SizedBox(height: 32),
            _SectionTitle(title: "Technologies Used"),
            _InfoCard(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _TechChip(label: "ROS 2"),
                  _TechChip(label: "Navigation2"),
                  _TechChip(label: "Flutter"),
                  _TechChip(label: "Firebase"),
                  _TechChip(label: "Raspberry Pi"),
                  _TechChip(label: "Arduino"),
                ],
              ),
            ),

            const SizedBox(height: 32),
            _SectionTitle(title: "Developed By"),
            _InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Benha University", style: AppTextStyles.cardTitle(context).copyWith(fontSize: 17, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 4),
                  Text("Faculty of Engineering at Shoubra", style: AppTextStyles.body(context).copyWith(fontSize: 15, color: secondaryTextColor)),
                  const SizedBox(height: 4),
                  Text("Computer & Communication Engineering Program", style: AppTextStyles.helper(context).copyWith(fontSize: 14, color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 32),
            _SectionTitle(title: "Team"),
            _InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _TeamMember(name: "Mohammed Ahmed Mohamed Hassan"),
                  _TeamMember(name: "Farida Waheed Abdelbary"),
                  _TeamMember(name: "Abdelrahman Salaheldein Abdelaziz"),
                  _TeamMember(name: "Raneem Ahmed Refaat"),
                  _TeamMember(name: "Mohaned Mohamed Talaat"),
                  _TeamMember(name: "Lujain Ahmed Youssef"),
                  _TeamMember(name: "Abdelrahman Afify Hussien"),
                ],
              ),
            ),

            const SizedBox(height: 32),
            _SectionTitle(title: "Supervisor"),
            _InfoCard(
              child: Text("Dr. Mohamed Hussein", style: AppTextStyles.cardTitle(context).copyWith(fontSize: 17, fontWeight: FontWeight.bold, color: textColor)),
            ),

            const SizedBox(height: 48),
            Center(
              child: Column(
                children: [
                  Text(
                    "Copyright © 2026 Horus-Bot Project",
                    style: AppTextStyles.helper(context).copyWith(fontSize: 12, color: secondaryTextColor),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.sectionTitle(context).copyWith(
          fontSize: 13,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  const _TechChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.helper(context).copyWith(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

class _TeamMember extends StatelessWidget {
  final String name;
  const _TeamMember({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.person_pin_rounded, size: 18, color: AppColors.primaryGold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.body(context).copyWith(
                fontSize: 15,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.darkInk,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
