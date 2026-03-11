import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../app/router.dart';
import '../../models/user_preferences.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/dialogs/location_permission_dialog.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = prefs.language == 'ar';

    final textColor = isDark ? const Color(0xFFF5F1E8) : const Color(0xFF2A2118);
    final secondaryTextColor = isDark ? Colors.white.withOpacity(0.82) : const Color(0xFF5C5143);

    return AppMenuShell(
      hideDefaultAppBar: true,
      backgroundColor: AppColors.cinematicBackground,
      body: Scaffold(
        backgroundColor: AppColors.cinematicBackground,
        appBar: AppBar(
          backgroundColor: AppColors.cinematicNav,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => AppMenuShell.of(context)?.openMenu(),
          ),
          title: Row(
            children: [
              Image.asset("assets/icons/ankh.png", width: 24, height: 24),
              const SizedBox(width: 16),
              Text(
                l10n.settings,
                style: AppTextStyles.screenTitle(context).copyWith(fontSize: 20),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Introduction Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cinematicCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
      title: l10n.settings,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? "خصص تجربة المتحف الخاصة بك" : "Customize your museum experience",
              style: AppTextStyles.helper(context),
            ),
            const SizedBox(height: 32),

            // A. Museum Experience
            _SectionHeader(title: isArabic ? "تجربة المتحف" : "Museum Experience"),
            _PremiumCard(
              children: [
                _SettingToggle(
                  title: isArabic ? "اتبع حوروس-بوت تلقائيًا" : "Automatically follow Horus-Bot",
                  subtitle: isArabic ? "يقوم الروبوت بتوجيهك تلقائيًا" : "Robot guides you automatically",
                  value: true,
                  onChanged: (val) {},
                ),
                _Divider(),
                _SettingToggle(
                  title: isArabic ? "إظهار المعروضات القريبة" : "Show nearby exhibits",
                  subtitle: isArabic ? "تنبيهات عند الاقتراب من القطع الأثرية" : "Alerts when near artifacts",
                  value: true,
                  onChanged: (val) {},
                ),
                _Divider(),
                _SettingToggle(
                  title: isArabic ? "شروحات صوتية للمعروضات" : "Exhibit audio explanations",
                  subtitle: isArabic ? "تشغيل الشرح الصوتي تلقائيًا" : "Auto-play audio narration",
                  value: false,
                  onChanged: (val) {},
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.settings, color: AppColors.primaryGold, size: 28),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.comfortableApp,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.adjustSettings,
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 2. MUSEUM EXPERIENCE
              _SectionTitle(title: l10n.museumExperience.toUpperCase()),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cinematicCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.museumExperienceSub,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    _SwitchItem(
                      title: l10n.autoFollow,
                      value: true,
                      onChanged: (v) {},
                    ),
                    _SwitchItem(
                      title: l10n.nearbyAlerts,
                      value: true,
                      onChanged: (v) {},
                    ),
                    _SwitchItem(
                      title: l10n.detailedExplanations,
                      value: true,
                      onChanged: (v) {},
                    ),
                    _SwitchItem(
                      title: l10n.voiceInteraction,
                      value: false,
                      onChanged: (v) {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 3. PERMISSIONS
              _SectionTitle(title: l10n.permissionsCenter.toUpperCase()),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cinematicCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    _PermissionItem(
                      icon: Icons.location_on_outlined,
                      title: l10n.locationService,
                      subtitle: l10n.locationServiceSub,
                      onEnable: () {},
                    ),
                    _Divider(),
                    _PermissionItem(
                      icon: Icons.bluetooth,
                      title: l10n.bluetooth,
                      subtitle: l10n.bluetoothSub,
                      onEnable: () {},
                    ),
                    _Divider(),
                    _PermissionItem(
                      icon: Icons.mic_none,
                      title: l10n.microphone,
                      subtitle: l10n.microphoneSub,
                      onEnable: () {},
                    ),
                    _Divider(),
                    _PermissionItem(
                      icon: Icons.camera_alt_outlined,
                      title: l10n.camera,
                      subtitle: l10n.cameraSub,
                      onEnable: () {},
                    ),
                    _Divider(),
                    _PermissionItem(
                      icon: Icons.notifications_none,
                      title: l10n.notifications,
                      subtitle: l10n.notificationsSub,
                      onEnable: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 4. DISPLAY & TEXT
              _SectionTitle(title: l10n.displayText.toUpperCase()),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cinematicCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SwitchItem(
                      title: l10n.highContrast,
                      value: prefs.isHighContrast,
                      onChanged: (v) => prefs.toggleHighContrast(v),
                    ),
                    _SwitchItem(
                      title: l10n.audioGuide,
                      subtitle: l10n.audioGuideSub,
                      value: false,
                      onChanged: (v) {},
                    ),
                    _SwitchItem(
                      title: l10n.reduceAnimations,
                      subtitle: l10n.reduceAnimationsSub,
                      value: false,
                      onChanged: (v) {},
                    ),
                    _SwitchItem(
                      title: l10n.simpleMode,
                      subtitle: l10n.simpleModeSub,
                      value: false,
                      onChanged: (v) {},
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.appearanceMode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _AppearanceChip(
                          label: l10n.system,
                          icon: Icons.smartphone,
                          selected: prefs.themeMode == 'system',
                          onTap: () => prefs.setThemeMode('system'),
                        ),
                        const SizedBox(width: 8),
                        _AppearanceChip(
                          label: l10n.light,
                          icon: Icons.light_mode_outlined,
                          selected: prefs.themeMode == 'light',
                          onTap: () => prefs.setThemeMode('light'),
                        ),
                        const SizedBox(width: 8),
                        _AppearanceChip(
                          label: l10n.dark,
                          icon: Icons.dark_mode,
                          selected: prefs.themeMode == 'dark',
                          onTap: () => prefs.setThemeMode('dark'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(l10n.textSize, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primaryGold,
                        inactiveTrackColor: Colors.white.withOpacity(0.1),
                        thumbColor: AppColors.primaryGold,
                        overlayColor: AppColors.primaryGold.withOpacity(0.2),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: prefs.fontScale,
                        min: 0.8,
                        max: 1.4,
                        divisions: 4,
                        onChanged: (v) => prefs.setFontScale(v),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (i) => Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle))),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 5. LANGUAGE
              _SectionTitle(title: l10n.language.toUpperCase()),
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
                      child: const Icon(Icons.language, color: AppColors.primaryGold, size: 24),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.appLanguage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(l10n.appLanguageSubtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                        ],
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: prefs.language,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                        dropdownColor: AppColors.cinematicElevated,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        onChanged: (v) => prefs.setLanguage(v!),
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text("English")),
                          DropdownMenuItem(value: 'ar', child: Text("العربية")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 6. ABOUT HORUS-BOT
              _SectionTitle(title: l10n.aboutHorusBot.toUpperCase()),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cinematicCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.appVersion, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(l10n.appTagline, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                    const SizedBox(height: 24),
                    Text(l10n.developedBy.toUpperCase(), style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Text(l10n.organization, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(l10n.department, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                    const SizedBox(height: 24),
                    _AboutNavItem(title: l10n.projectInfo),
                    _AboutNavItem(title: l10n.team),
                    _AboutNavItem(title: l10n.privacyPolicy),
                  ],
                ),
              ),
            // ABOUT HORUS-BOT
            _SectionHeader(title: l10n.aboutHorusBot),
            _StyledCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.version, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 4),
                  Text(l10n.aboutDesc, style: TextStyle(fontSize: 14, color: secondaryTextColor)),
                  const SizedBox(height: 24),
                  Text(l10n.developedBy, style: TextStyle(fontSize: 12, color: secondaryTextColor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(l10n.university, style: TextStyle(fontSize: 14, color: textColor)),
                  Text(l10n.program, style: TextStyle(fontSize: 13, color: secondaryTextColor)),
                  const SizedBox(height: 24),
                  _AboutLink(
                    title: l10n.projectInfo,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.projectInfo),
                  ),
                  _AboutLink(
                    title: l10n.team,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.projectInfo),
                  ),
                  _AboutLink(title: l10n.privacyPolicy),
                ],
              ),
            ),

              const SizedBox(height: 48),
            ],
          ),
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
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5),
      ),
    );
  }
}

class _SwitchItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchItem({required this.title, this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                ],
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primaryGold.withOpacity(0.4),
            activeColor: AppColors.primaryGold,
          ),
        ],
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onEnable;

  const _PermissionItem({required this.icon, required this.title, required this.subtitle, required this.onEnable});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primaryGold, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
        ),
        const SizedBox(width: 16),
        Switch.adaptive(
          value: value,
          activeTrackColor: AppColors.primaryGold,
          inactiveTrackColor: AppColors.neutralDark,
          inactiveThumbColor: Colors.white,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _StyledCard extends StatelessWidget {
  final Widget child;
  const _StyledCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkDivider, width: 1),
      ),
      child: child,
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String status;
  final String actionLabel;
  final bool isArabic;

  const _PermissionRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.status,
    required this.actionLabel,
    required this.isArabic,
  });

  Future<void> _handleAction(BuildContext context) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isArabic ? "إعدادات الأذونات غير متوفرة على الويب" : "Permission settings not available on Web")),
      );
      return;
    }

    // Attempt to open settings or request
    if (title.contains("Location") || title.contains("الموقع")) {
      await Permission.locationWhenInUse.request();
    } else if (title.contains("Camera") || title.contains("الكاميرا")) {
      await Permission.camera.request();
    } else if (title.contains("Microphone") || title.contains("الميكروفون")) {
      await Permission.microphone.request();
    } else {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.darkBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryGold, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsDisabled,
                style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: onEnable,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.darkInk,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: Text(l10n.enable, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AboutLink extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const _AboutLink({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primaryGold),
          ],
        ),
      ),
    );
  }
}

class _AboutNavItem extends StatelessWidget {
  final String title;
  const _AboutNavItem({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
          const Icon(Icons.chevron_right, color: AppColors.primaryGold, size: 20),
        ],
      ),
    );
  }
}

class _AppearanceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _AppearanceChip({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryGold : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppColors.darkInk : Colors.white, size: 22),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.darkInk : Colors.white,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 20, endIndent: 20);
  }
}
