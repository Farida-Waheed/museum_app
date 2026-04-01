import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../app/router.dart';
import '../../models/user_preferences.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/dialogs/branded_permission_dialog.dart';

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  Map<Permission, PermissionStatus> _statuses = {};

  @override
  void initState() {
    super.initState();
    _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {
    if (kIsWeb) return;
    final statuses = await [
      Permission.location,
      Permission.notification,
      Permission.camera,
      Permission.microphone,
      Permission.bluetooth,
    ].request();
    if (mounted) {
      setState(() => _statuses = statuses);
    }
  }

  Future<void> _requestPermission(Permission p) async {
    if (kIsWeb) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.webPermissionsNote)),
      );
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    IconData icon = Icons.settings;
    String title = "";
    String desc = "";

    if (p == Permission.location) {
      icon = Icons.location_on_outlined;
      title = l10n.locationPermissionTitle;
      desc = l10n.locationPermissionDesc;
    } else if (p == Permission.notification) {
      icon = Icons.notifications_none_rounded;
      title = l10n.notificationPermissionTitle;
      desc = l10n.notificationPermissionDesc;
    } else if (p == Permission.camera) {
      icon = Icons.camera_alt_outlined;
      title = l10n.cameraPermissionTitle;
      desc = l10n.cameraPermissionDesc;
    } else if (p == Permission.microphone) {
      icon = Icons.mic_none_rounded;
      title = l10n.micPermissionTitle;
      desc = l10n.micPermissionDesc;
    } else if (p == Permission.bluetooth) {
      icon = Icons.bluetooth;
      title = l10n.bluetooth;
      desc = l10n.bluetoothSub;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BrandedPermissionDialog(
        icon: icon,
        title: title,
        description: desc,
        onAllow: () async {
          Navigator.pop(context);
          final status = await p.request();
          if (mounted) {
            setState(() => _statuses[p] = status);
            if (status.isPermanentlyDenied) {
              openAppSettings();
            }
          }
        },
        onDeny: () => Navigator.pop(context),
      ),
    );
  }

  String _getStatusText(Permission p, AppLocalizations l10n) {
    if (kIsWeb) return "Managed by browser";
    final s = _statuses[p];
    if (s == null) return l10n.settingsDisabled;
    if (s.isGranted) return "Enabled";
    if (s.isDenied) return l10n.settingsDisabled;
    if (s.isPermanentlyDenied) return "Permanently Disabled";
    return l10n.settingsDisabled;
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = prefs.language == 'ar';

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
                l10n.settings.toUpperCase(),
                style: AppTextStyles.displayScreenTitle(context).copyWith(fontSize: 20),
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
                            style: AppTextStyles.bodyPrimary(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.adjustSettings,
                            style: AppTextStyles.metadata(context).copyWith(fontSize: 13),
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
                      style: AppTextStyles.metadata(context).copyWith(fontSize: 13),
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
                      status: _getStatusText(Permission.location, l10n),
                      onEnable: () => _requestPermission(Permission.location),
                    ),
                    _Divider(),
                    _PermissionItem(
                      icon: Icons.bluetooth,
                      title: l10n.bluetooth,
                      subtitle: l10n.bluetoothSub,
                      status: _getStatusText(Permission.bluetooth, l10n),
                      onEnable: () => _requestPermission(Permission.bluetooth),
                    ),
                    _Divider(),
                    _PermissionItem(
                      icon: Icons.mic_none,
                      title: l10n.microphone,
                      subtitle: l10n.microphoneSub,
                      status: _getStatusText(Permission.microphone, l10n),
                      onEnable: () => _requestPermission(Permission.microphone),
                    ),
                    _Divider(),
                    _PermissionItem(
                      icon: Icons.camera_alt_outlined,
                      title: l10n.camera,
                      subtitle: l10n.cameraSub,
                      status: _getStatusText(Permission.camera, l10n),
                      onEnable: () => _requestPermission(Permission.camera),
                    ),
                    _Divider(),
                    _PermissionItem(
                      icon: Icons.notifications_none,
                      title: l10n.notifications,
                      subtitle: l10n.notificationsSub,
                      status: _getStatusText(Permission.notification, l10n),
                      onEnable: () => _requestPermission(Permission.notification),
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
                    Text(l10n.appearanceMode, style: AppTextStyles.titleMedium(context).copyWith(fontSize: 16)),
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
                    Text(l10n.textSize, style: AppTextStyles.titleMedium(context).copyWith(fontSize: 16)),
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
                          Text(l10n.appLanguage, style: AppTextStyles.titleMedium(context).copyWith(fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(l10n.appLanguageSubtitle, style: AppTextStyles.metadata(context).copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: prefs.language,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                        dropdownColor: AppColors.cinematicElevated,
                        style: AppTextStyles.bodyPrimary(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        onChanged: (v) => prefs.setLanguage(v!),
                        items: [
                          DropdownMenuItem(value: 'en', child: Text(l10n.englishLanguage)),
                          DropdownMenuItem(value: 'ar', child: Text(l10n.arabicLanguage)),
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
                    Text(l10n.appVersion, style: AppTextStyles.titleLarge(context).copyWith(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(l10n.appTagline, style: AppTextStyles.bodyPrimary(context).copyWith(fontSize: 14)),
                    const SizedBox(height: 24),
                    Text(l10n.developedBy.toUpperCase(), style: AppTextStyles.displaySectionTitle(context).copyWith(fontSize: 11, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Text(l10n.organization, style: AppTextStyles.bodyPrimary(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(l10n.department, style: AppTextStyles.metadata(context).copyWith(fontSize: 13)),
                    const SizedBox(height: 24),
                    _AboutNavItem(
                      title: l10n.projectInfo,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.projectInfo),
                    ),
                    _AboutNavItem(
                      title: l10n.team,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.projectInfo),
                    ),
                    _AboutNavItem(title: l10n.privacyPolicy),
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
        style: AppTextStyles.displaySectionTitle(context).copyWith(fontSize: 12, letterSpacing: 1.5),
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
                Text(title, style: AppTextStyles.bodyPrimary(context).copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: AppTextStyles.metadata(context).copyWith(fontSize: 12)),
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
  final String status;
  final VoidCallback onEnable;

  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onEnable,
  });

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
                    Text(title, style: AppTextStyles.bodyPrimary(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.metadata(context)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                status,
                style: TextStyle(
                  color: status == "Enabled" ? Colors.green : Colors.white38,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: status == "Enabled" ? null : onEnable,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.darkInk,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: Text(l10n.enable, style: AppTextStyles.buttonLabel(context).copyWith(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AboutNavItem extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const _AboutNavItem({required this.title, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.bodyPrimary(context).copyWith(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
            const Icon(Icons.chevron_right, color: AppColors.primaryGold, size: 20),
          ],
        ),
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
