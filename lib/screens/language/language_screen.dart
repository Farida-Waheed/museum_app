import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../widgets/bottom_nav.dart';

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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      bottomNavigationBar: const BottomNav(currentIndex: 4),
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          isArabic ? "اللغة" : "Language",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card (simple, no glass)
          Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                textDirection:
                    isArabic ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.language,
                      color: cs.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: isArabic
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? "اختر لغتك" : "Choose your language",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isArabic
                              ? "سيتم تطبيق اللغة على جميع شاشات التطبيق."
                              : "Your choice applies across the whole app.",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // language options – grid but calm
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.6,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? cs.primary
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    textDirection:
                        isArabic ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Text(lang.flag, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lang.name,
                          textAlign:
                              isArabic ? TextAlign.right : TextAlign.left,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? cs.primary
                                : Colors.black87,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle,
                            size: 20, color: cs.primary),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // small info card
          Card(
            elevation: 0,
            color: cs.primary.withOpacity(0.06),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? "ماذا يتغير؟" : "What changes?",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isArabic
                        ? "واجهات التطبيق، نصوص المعروضات، والروبوت سيستخدمون اللغة التي تختارها."
                        : "App screens, exhibit text, and the robot guide will follow your language choice.",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
