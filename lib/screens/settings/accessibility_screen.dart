import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../widgets/bottom_nav.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      bottomNavigationBar: const BottomNav(currentIndex: 4),
      appBar: AppBar(
        title: Text(
          isArabic ? "الإعدادات وإمكانية الوصول" : "Settings & Accessibility",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.5,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Hero / context card (matches Ticket / Feedback style)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.accessibility_new_rounded,
                        color: theme.colorScheme.primary,
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
                            isArabic
                                ? "اجعل التطبيق مريحاً لك"
                                : "Make the app comfortable for you",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isArabic
                                ? "عدّل حجم الخط والتباين واللغة لتناسب احتياجاتك."
                                : "Adjust text size, contrast, and language to suit your needs.",
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

            const SizedBox(height: 24),

            _SectionTitle(
              title: isArabic ? "العرض والنص" : "Display & text",
              isArabic: isArabic,
            ),

            const SizedBox(height: 8),

            // DISPLAY & TEXT CARD
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: [
                    // High contrast toggle
                    _SettingRowSwitch(
                      isArabic: isArabic,
                      icon: Icons.contrast_rounded,
                      title: isArabic
                          ? "وضع تباين عالٍ"
                          : "High contrast mode",
                      subtitle: isArabic
                          ? "زيادة وضوح الألوان والعناصر للنظر الضعيف أو الإضاءة المنخفضة."
                          : "Increase color and element contrast for low vision or low light.",
                      value: prefs.isHighContrast,
                      onChanged: prefs.toggleHighContrast,
                    ),

                    const SizedBox(height: 12),

                    // THEME MODE (System / Light / Dark)
                    _ThemeModeSetting(
                      isArabic: isArabic,
                      themeMode: prefs.themeMode,      // <-- uses your prefs
                      onChanged: prefs.setThemeMode,   // <-- uses your prefs
                    ),

                    const Divider(height: 16),

                    // Font size
                    _FontSizeSetting(
                      isArabic: isArabic,
                      fontScale: prefs.fontScale,
                      onChanged: prefs.setFontScale,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            _SectionTitle(
              title: isArabic ? "اللغة" : "Language",
              isArabic: isArabic,
            ),

            const SizedBox(height: 8),

            // LANGUAGE CARD
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(
                      Icons.language_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: isArabic
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? "لغة التطبيق" : "App language",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isArabic
                                ? "اختر اللغة المفضلة لواجهة التطبيق والمحتوى."
                                : "Choose your preferred language for the app UI and content.",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: prefs.language,
                        borderRadius: BorderRadius.circular(12),
                        items: [
                          DropdownMenuItem(
                            value: 'en',
                            child: Text(
                              "English",
                              style: TextStyle(
                                fontWeight: prefs.language == 'en'
                                    ? FontWeight.bold
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'ar',
                            child: Text(
                              "العربية",
                              style: TextStyle(
                                fontWeight: prefs.language == 'ar'
                                    ? FontWeight.bold
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) prefs.setLanguage(val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Small note
            Text(
              isArabic
                  ? "يتم حفظ هذه الإعدادات على هذا الجهاز فقط."
                  : "These settings are saved on this device only.",
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black45,
              ),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Small reusable widgets =====

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isArabic;

  const _SectionTitle({
    required this.title,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }
}

class _SettingRowSwitch extends StatelessWidget {
  final bool isArabic;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingRowSwitch({
    required this.isArabic,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
                isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch.adaptive(
          value: value,
          activeColor: theme.colorScheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// NEW: Theme mode row (System / Light / Dark)
class _ThemeModeSetting extends StatelessWidget {
  final bool isArabic;
  final String themeMode; // 'system' | 'light' | 'dark'
  final ValueChanged<String> onChanged;

  const _ThemeModeSetting({
    required this.isArabic,
    required this.themeMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildChip({
      required String value,
      required IconData icon,
      required String labelEn,
      required String labelAr,
    }) {
      final bool selected = themeMode == value;
      final label = isArabic ? labelAr : labelEn;

      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: selected
                  ? theme.colorScheme.primary.withOpacity(0.10)
                  : Colors.grey.shade100,
              border: Border.all(
                color: selected
                    ? theme.colorScheme.primary
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? theme.colorScheme.primary
                      : Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? theme.colorScheme.primary
                          : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? "وضع المظهر" : "Appearance mode",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            buildChip(
              value: 'system',
              icon: Icons.phone_iphone_rounded,
              labelEn: 'System',
              labelAr: 'حسب النظام',
            ),
            const SizedBox(width: 6),
            buildChip(
              value: 'light',
              icon: Icons.light_mode_rounded,
              labelEn: 'Light',
              labelAr: 'فاتح',
            ),
            const SizedBox(width: 6),
            buildChip(
              value: 'dark',
              icon: Icons.dark_mode_rounded,
              labelEn: 'Dark',
              labelAr: 'داكن',
            ),
          ],
        ),
      ],
    );
  }
}

class _FontSizeSetting extends StatelessWidget {
  final bool isArabic;
  final double fontScale;
  final ValueChanged<double> onChanged;

  const _FontSizeSetting({
    required this.isArabic,
    required this.fontScale,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Clamp value just in case
    final clamped = fontScale.clamp(0.8, 1.4);

    return Column(
      crossAxisAlignment:
          isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              isArabic ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Text(
              isArabic ? "حجم النص" : "Text size",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "${clamped.toStringAsFixed(1)}x",
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: clamped,
            min: 0.8,
            max: 1.4,
            divisions: 6,
            label: "${clamped.toStringAsFixed(1)}x",
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment:
              isArabic ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Text(
              isArabic ? "أصغر" : "Smaller",
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
            const Spacer(),
            Text(
              isArabic ? "أكبر" : "Larger",
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ],
        ),
      ],
    );
  }
}
