import 'dart:ui';
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

    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: const BottomNav(currentIndex: 4),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          isArabic ? "اللغة" : "Language",
          style: const TextStyle(color: Colors.black),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ========= HEADER GLASS HERO =========
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(.25),
                      Colors.purple.withOpacity(.18),
                      Colors.black.withOpacity(.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.language, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? "اختر لغتك" : "Choose Your Language",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            isArabic
                                ? "ستُحدث اللغة في جميع شاشات التطبيق"
                                : "Your language will apply across the app",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withOpacity(.6)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 26),

          // ========= LANGUAGE SELECTOR GRID =========
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.4,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final lang = languages[index];
              final isSelected = prefs.language == lang.code;

              return GestureDetector(
                onTap: () => prefs.setLanguage(lang.code),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: 2,
                    ),
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              Colors.blue.withOpacity(.2),
                              Colors.blue.withOpacity(.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              Colors.white.withOpacity(.85),
                              Colors.white.withOpacity(.70),
                            ],
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Text(lang.flag, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          lang.name,
                          textAlign: isArabic ? TextAlign.right : TextAlign.left,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color:
                                isSelected ? Colors.blue.shade900 : Colors.black87,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.blue, size: 22),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          // ========= LANGUAGE FEATURES (GLASS CARD) =========
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment:
                      isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? "ميزات اللغة" : "Language Features",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildFeatureItem(
                        isArabic ? "ترجمة جميع أوصاف المعروضات" : "All exhibit descriptions translated"),
                    _buildFeatureItem(
                        isArabic ? "شرح صوتي باللغة المختارة" : "Audio guides in selected language"),
                    _buildFeatureItem(
                        isArabic ? "الروبوت يتحدث لغتك" : "Robot speaks in your chosen language"),
                    _buildFeatureItem(
                        isArabic ? "نصوص فورية متاحة" : "Live transcripts available"),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 26),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, color: Colors.blue[800]),
            ),
          ),
        ],
      ),
    );
  }
}
