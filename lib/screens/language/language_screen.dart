import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/user_preferences.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_menu_shell.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

class LanguageOption {
  final String code;
  final String name;
  final String flag;
  const LanguageOption(this.code, this.name, this.flag);
}

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const List<LanguageOption> languages = [
    LanguageOption('en', 'English', '🇬🇧'),
    LanguageOption('ar', 'العربية', '🇪🇬'),
    LanguageOption('es', 'Español', '🇪🇸'),
    LanguageOption('fr', 'Français', '🇫🇷'),
    LanguageOption('de', 'Deutsch', '🇩🇪'),
    LanguageOption('zh', '中文', '🇨🇳'),
  ];

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AppMenuShell(
      title: l10n.language.toUpperCase(),
      backgroundColor: AppColors.cinematicBackground,
      bottomNavigationBar: const BottomNav(currentIndex: 4),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cinematicCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.language,
                    color: AppColors.primaryGold,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? "اختر لغتك" : "Choose your language",
                        style: AppTextStyles.titleMedium(context).copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic
                            ? "سيتم تطبيق اللغة على جميع شاشات التطبيق."
                            : "Your choice applies across the whole app.",
                        style: AppTextStyles.metadata(context).copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // language options
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final lang = languages[index];
              final isSelected = prefs.language == lang.code;

              return InkWell(
                onTap: () => prefs.setLanguage(lang.code),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.cinematicCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGold
                          : Colors.white.withOpacity(0.05),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(lang.flag, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lang.name,
                          style: AppTextStyles.bodyPrimary(context).copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.primaryGold
                                : Colors.white70,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            size: 18, color: AppColors.primaryGold),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // info card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryGold.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? "ماذا يتغير؟" : "What changes?",
                  style: AppTextStyles.displaySectionTitle(context).copyWith(fontSize: 12),
                ),
                const SizedBox(height: 12),
                Text(
                  isArabic
                      ? "واجهات التطبيق، نصوص المعروضات، والروبوت سيستخدمون اللغة التي تختارها."
                      : "App screens, exhibit text, and the robot guide will follow your language choice.",
                  style: AppTextStyles.bodyPrimary(context).copyWith(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
