import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';

class LanguageOption {
  final String code;
  final String name;
  final String flag;
  const LanguageOption(this.code, this.name, this.flag);
}

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  // Language Data
  static const List<LanguageOption> languages = [
    LanguageOption('en', 'English', '🇬🇧'),
    LanguageOption('ar', 'العربية', '🇪🇬'), // Added Arabic for your app
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
      appBar: AppBar(
        title: Text(isArabic ? "اللغة" : "Language"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- 1. Selection Card ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.language, color: Colors.blue, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? "اختر اللغة" : "Select Language",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              isArabic ? "اختر لغتك المفضلة للجولة" : "Choose your preferred language",
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Grid of Languages
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.5, // Makes buttons rectangular
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: languages.length,
                      itemBuilder: (context, index) {
                        final lang = languages[index];
                        final isSelected = prefs.language == lang.code;
                        
                        return InkWell(
                          onTap: () => prefs.setLanguage(lang.code),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue[50] : Colors.white,
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey.shade200,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(lang.flag, style: const TextStyle(fontSize: 24)),
                                    const SizedBox(width: 12),
                                    Text(
                                      lang.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.blue[900] : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle, color: Colors.blue, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- 2. Features Card (Blue) ---
            Card(
              elevation: 0,
              color: Colors.blue[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.blue.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? "ميزات اللغة" : "Language Features",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(isArabic ? "ترجمة جميع أوصاف المعروضات" : "All exhibit descriptions translated"),
                    _buildFeatureItem(isArabic ? "شرح صوتي باللغة المختارة" : "Audio guides in selected language"),
                    _buildFeatureItem(isArabic ? "الروبوت يتحدث لغتك" : "Robot speaks in your chosen language"),
                    _buildFeatureItem(isArabic ? "نصوص فورية متاحة" : "Live transcripts available"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: Colors.blue[800], fontSize: 14))),
        ],
      ),
    );
  }
}