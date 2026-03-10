import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/user_preferences.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_menu_shell.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppMenuShell(
      title: l10n.settingsAccessibility,
      bottomNavigationBar: const BottomNav(currentIndex: 4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.comfortableApp,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.adjustSettings,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _SectionTitle(
              title: l10n.displayText,
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
                      icon: Icons.contrast_rounded,
                      title: l10n.highContrast,
                      subtitle: l10n.highContrastSubtitle,
                      value: prefs.isHighContrast,
                      onChanged: prefs.toggleHighContrast,
                    ),

                    const SizedBox(height: 12),

                    // THEME MODE (System / Light / Dark)
                    _ThemeModeSetting(
                      themeMode: prefs.themeMode,      // <-- uses your prefs
                      onChanged: prefs.setThemeMode,   // <-- uses your prefs
                    ),

                    const Divider(height: 16),

                    // Font size
                    _FontSizeSetting(
                      fontScale: prefs.fontScale,
                      onChanged: prefs.setFontScale,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            _SectionTitle(
              title: l10n.language,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.appLanguage,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.appLanguageSubtitle,
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
              l10n.saveNote,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black45,
              ),
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

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }
}

class _SettingRowSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingRowSwitch({
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
          activeTrackColor: theme.colorScheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// NEW: Theme mode row (System / Light / Dark)
class _ThemeModeSetting extends StatelessWidget {
  final String themeMode; // 'system' | 'light' | 'dark'
  final ValueChanged<String> onChanged;

  const _ThemeModeSetting({
    required this.themeMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    Widget buildChip({
      required String value,
      required IconData icon,
      required String label,
    }) {
      final bool selected = themeMode == value;

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.appearanceMode,
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
              label: l10n.system,
            ),
            const SizedBox(width: 6),
            buildChip(
              value: 'light',
              icon: Icons.light_mode_rounded,
              label: l10n.light,
            ),
            const SizedBox(width: 6),
            buildChip(
              value: 'dark',
              icon: Icons.dark_mode_rounded,
              label: l10n.dark,
            ),
          ],
        ),
      ],
    );
  }
}

class _FontSizeSetting extends StatelessWidget {
  final double fontScale;
  final ValueChanged<double> onChanged;

  const _FontSizeSetting({
    required this.fontScale,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Clamp value just in case
    final clamped = fontScale.clamp(0.8, 1.4);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.textSize,
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
          children: [
            Text(
              l10n.smaller,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
            const Spacer(),
            Text(
              l10n.larger,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ],
        ),
      ],
    );
  }
}
