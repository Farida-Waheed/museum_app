import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../app/router.dart';
import '../../models/user_preferences.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/dialogs/location_permission_dialog.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? AppColors.darkSurface : const Color(0xFFF7F2E8);
    final textColor = isDark ? const Color(0xFFF5F1E8) : const Color(0xFF2A2118);
    final secondaryTextColor = isDark ? Colors.white.withOpacity(0.82) : const Color(0xFF5C5143);

    return AppMenuShell(
      title: l10n.settings,
      bottomNavigationBar: BottomNav(currentIndex: 4),
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
                _Divider(),
                _SettingToggle(
                  title: isArabic ? "التفاعل الصوتي" : "Voice interaction",
                  subtitle: isArabic ? "التحدث مع حوروس-بوت مباشرة" : "Talk to Horus-Bot directly",
                  value: false,
                  onChanged: (val) {},
                ),
              ],
            ),

            const SizedBox(height: 32),

            // B. Permissions
            _SectionHeader(title: isArabic ? "الأذونات" : "Permissions"),
            _PremiumCard(
              children: [
                _PermissionRow(
                  icon: Icons.location_on_outlined,
                  title: isArabic ? "الموقع" : "Location",
                  subtitle: isArabic ? "يستخدم للملاحة الداخلية" : "Used for indoor navigation",
                  status: isArabic ? "مفعل" : "Enabled",
                  actionLabel: isArabic ? "إدارة" : "Manage",
                  isArabic: isArabic,
                ),
                _Divider(),
                _PermissionRow(
                  icon: Icons.bluetooth_outlined,
                  title: isArabic ? "بلوتوث" : "Bluetooth",
                  subtitle: isArabic ? "للاتصال بالروبوت" : "To connect with the robot",
                  status: isArabic ? "معطل" : "Disabled",
                  actionLabel: isArabic ? "تفعيل" : "Enable",
                  isArabic: isArabic,
                ),
                _Divider(),
                _PermissionRow(
                  icon: Icons.mic_none_outlined,
                  title: isArabic ? "الميكروفون" : "Microphone",
                  subtitle: isArabic ? "للأوامر الصوتية" : "For voice commands",
                  status: isArabic ? "مرفوض" : "Denied",
                  actionLabel: isArabic ? "إعدادات النظام" : "System Settings",
                  isArabic: isArabic,
                ),
                _Divider(),
                _PermissionRow(
                  icon: Icons.camera_alt_outlined,
                  title: isArabic ? "الكاميرا" : "Camera",
                  subtitle: isArabic ? "لمسح التذاكر والواقع المعزز" : "For AR and scanning tickets",
                  status: isArabic ? "مفعل" : "Enabled",
                  actionLabel: isArabic ? "إدارة" : "Manage",
                  isArabic: isArabic,
                ),
                _Divider(),
                _PermissionRow(
                  icon: Icons.notifications_none_outlined,
                  title: isArabic ? "التنبيهات" : "Notifications",
                  status: isArabic ? "مفعل" : "Enabled",
                  actionLabel: isArabic ? "إدارة" : "Manage",
                  isArabic: isArabic,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // C. Accessibility
            _SectionHeader(title: isArabic ? "إمكانية الوصول" : "Accessibility"),
            _PremiumCard(
              children: [
                _SettingToggle(
                  title: l10n.highContrast,
                  subtitle: isArabic ? "زيادة تباين الألوان" : "Increase color contrast",
                  value: prefs.isHighContrast,
                  onChanged: prefs.toggleHighContrast,
                ),
                _Divider(),
                _SettingToggle(
                  title: isArabic ? "تقليل الحركة" : "Reduce motion",
                  subtitle: isArabic ? "تقليل الحركات والانتقالات" : "Minimize animations and transitions",
                  value: false,
                  onChanged: (val) {},
                ),
                _Divider(),
                _SettingToggle(
                  title: isArabic ? "الوضع البسيط" : "Simple mode",
                  subtitle: isArabic ? "واجهة مستخدم مبسطة" : "Simplified user interface",
                  value: false,
                  onChanged: (val) {},
                ),
                _Divider(),
                _SettingToggle(
                  title: isArabic ? "وضع الدليل الصوتي" : "Audio guide mode",
                  subtitle: isArabic ? "تحسين للقارئ الصوتي" : "Optimized for screen readers",
                  value: false,
                  onChanged: (val) {},
                ),
              ],
            ),

            const SizedBox(height: 32),

            // D. Display
            _SectionHeader(title: isArabic ? "العرض" : "Display"),
            _PremiumCard(
              children: [
                _ThemeModeSetting(
                  themeMode: prefs.themeMode,
                  onChanged: prefs.setThemeMode,
                ),
                const SizedBox(height: 24),
                _FontSizeSetting(
                  fontScale: prefs.fontScale,
                  onChanged: prefs.setFontScale,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // E. Language
            _SectionHeader(title: isArabic ? "اللغة" : "Language"),
            _PremiumCard(
              children: [
                _LanguageRow(
                  currentLang: prefs.language,
                  onChanged: (val) => prefs.setLanguage(val!),
                ),
              ],
            ),

            const SizedBox(height: 32),

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
    );
  }
}

// --- Internal Reusable Widgets ---

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, right: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.sectionTitle(context),
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final List<Widget> children;
  const _PremiumCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkDivider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Divider(height: 32, thickness: 1, color: AppColors.darkDivider);
  }
}

class _SettingToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.cardTitle(context)),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTextStyles.helper(context)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Switch.adaptive(
          value: value,
          activeTrackColor: AppColors.primaryGold,
          inactiveTrackColor: AppColors.neutralDark,
          activeColor: Colors.white,
          inactiveThumbColor: Colors.white,
          onChanged: onChanged,
        ),
      ],
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
              Text(title, style: AppTextStyles.cardTitle(context)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppTextStyles.helper(context)),
              ],
              const SizedBox(height: 4),
              Text(
                "${isArabic ? 'الحالة' : 'Status'}: $status",
                style: TextStyle(
                  color: status == "Enabled" || status == "مفعل" ? Colors.green : AppColors.alertRed,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        TextButton(
          onPressed: () => _handleAction(context),
          style: TextButton.styleFrom(
            backgroundColor: AppColors.darkBackground,
            foregroundColor: AppColors.primaryGold,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(actionLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
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

class _ThemeModeSetting extends StatelessWidget {
  final String themeMode;
  final ValueChanged<String> onChanged;

  const _ThemeModeSetting({required this.themeMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.appearanceMode, style: AppTextStyles.cardTitle(context)),
        const SizedBox(height: 16),
        Row(
          children: [
            _ModeChip(label: l10n.system, icon: Icons.phone_android, selected: themeMode == 'system', onTap: () => onChanged('system')),
            const SizedBox(width: 8),
            _ModeChip(label: l10n.light, icon: Icons.light_mode, selected: themeMode == 'light', onTap: () => onChanged('light')),
            const SizedBox(width: 8),
            _ModeChip(label: l10n.dark, icon: Icons.dark_mode, selected: themeMode == 'dark', onTap: () => onChanged('dark')),
          ],
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryGold.withOpacity(0.1) : AppColors.darkBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppColors.primaryGold : AppColors.darkDivider),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppColors.primaryGold : AppColors.neutralMedium, size: 20),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: selected ? AppColors.primaryGold : AppColors.neutralMedium, fontSize: 11, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FontSizeSetting extends StatelessWidget {
  final double fontScale;
  final ValueChanged<double> onChanged;

  const _FontSizeSetting({required this.fontScale, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.textSize, style: AppTextStyles.cardTitle(context)),
            Text("${fontScale.toStringAsFixed(1)}x", style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primaryGold,
            inactiveTrackColor: AppColors.darkDivider,
            thumbColor: Colors.white,
            overlayColor: AppColors.primaryGold.withOpacity(0.2),
          ),
          child: Slider(
            value: fontScale.clamp(0.8, 1.4),
            min: 0.8,
            max: 1.4,
            divisions: 6,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _LanguageRow extends StatelessWidget {
  final String currentLang;
  final ValueChanged<String?> onChanged;

  const _LanguageRow({required this.currentLang, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.language, color: AppColors.primaryGold),
        const SizedBox(width: 16),
        Text(AppLocalizations.of(context)!.appLanguage, style: AppTextStyles.cardTitle(context)),
        const Spacer(),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentLang,
            dropdownColor: AppColors.darkSurface,
            style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
            borderRadius: BorderRadius.circular(12),
            items: const [
              DropdownMenuItem(value: 'en', child: Text("English")),
              DropdownMenuItem(value: 'ar', child: Text("العربية")),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.cardTitle(context).copyWith(fontSize: 14, color: AppColors.neutralMedium)),
        Flexible(child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.end)),
      ],
    );
  }
}
