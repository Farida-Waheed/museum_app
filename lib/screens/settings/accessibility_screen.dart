import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../models/user_preferences.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_menu_shell.dart';

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  Map<Permission, PermissionStatus> _permissionStatuses = {};

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final statuses = await [
      Permission.location,
      Permission.bluetooth,
      Permission.microphone,
      Permission.camera,
      Permission.notification,
    ].request(); // request() also checks status if already granted

    if (mounted) {
      setState(() {
        _permissionStatuses = statuses;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? AppColors.darkSurface : const Color(0xFFF7F2E8);
    final borderColor = isDark ? AppColors.primaryGold.withOpacity(0.2) : AppColors.primaryGold.withOpacity(0.15);
    final textColor = isDark ? const Color(0xFFF5F1E8) : const Color(0xFF2A2118);
    final secondaryTextColor = isDark ? Colors.white.withOpacity(0.82) : const Color(0xFF5C5143);

    return AppMenuShell(
      title: l10n.settings,
      bottomNavigationBar: const BottomNav(currentIndex: 4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Context Card
            _StyledCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.settings_outlined, color: AppColors.primaryGold, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.comfortableApp,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.adjustSettings,
                          style: TextStyle(fontSize: 13, color: secondaryTextColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // MUSEUM EXPERIENCE
            _SectionHeader(title: l10n.museumExperience),
            _StyledCard(
              child: Column(
                children: [
                  Text(l10n.museumExperienceDesc, style: TextStyle(fontSize: 13, color: secondaryTextColor)),
                  const SizedBox(height: 16),
                  _SwitchRow(
                    title: l10n.autoFollowRobot,
                    value: prefs.autoFollowRobot,
                    onChanged: prefs.setAutoFollowRobot,
                  ),
                  _SwitchRow(
                    title: l10n.showNearbyExhibits,
                    value: prefs.showNearbyExhibits,
                    onChanged: prefs.setShowNearbyExhibits,
                  ),
                  _SwitchRow(
                    title: l10n.enableExhibitExplanations,
                    value: prefs.enableExhibitExplanations,
                    onChanged: prefs.setEnableExhibitExplanations,
                  ),
                  _SwitchRow(
                    title: l10n.enableVoiceInteraction,
                    value: prefs.enableVoiceInteraction,
                    onChanged: prefs.setEnableVoiceInteraction,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // PERMISSIONS
            _SectionHeader(title: l10n.permissions),
            _StyledCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _PermissionItem(
                    icon: Icons.location_on_outlined,
                    title: l10n.location,
                    description: l10n.locationDesc,
                    status: _permissionStatuses[Permission.location] ?? PermissionStatus.denied,
                    onTap: () => _handlePermission(Permission.location),
                  ),
                  const Divider(height: 1),
                  _PermissionItem(
                    icon: Icons.bluetooth_outlined,
                    title: l10n.bluetooth,
                    description: l10n.bluetoothDesc,
                    status: _permissionStatuses[Permission.bluetooth] ?? PermissionStatus.denied,
                    onTap: () => _handlePermission(Permission.bluetooth),
                  ),
                  const Divider(height: 1),
                  _PermissionItem(
                    icon: Icons.mic_none_outlined,
                    title: l10n.microphone,
                    description: l10n.microphoneDesc,
                    status: _permissionStatuses[Permission.microphone] ?? PermissionStatus.denied,
                    onTap: () => _handlePermission(Permission.microphone),
                  ),
                  const Divider(height: 1),
                  _PermissionItem(
                    icon: Icons.camera_alt_outlined,
                    title: l10n.camera,
                    description: l10n.cameraDesc,
                    status: _permissionStatuses[Permission.camera] ?? PermissionStatus.denied,
                    onTap: () => _handlePermission(Permission.camera),
                  ),
                  const Divider(height: 1),
                  _PermissionItem(
                    icon: Icons.notifications_none_outlined,
                    title: l10n.notifications,
                    description: l10n.notificationsDesc,
                    status: _permissionStatuses[Permission.notification] ?? PermissionStatus.denied,
                    onTap: () => _handlePermission(Permission.notification),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // DISPLAY & TEXT
            _SectionHeader(title: l10n.displayText),
            _StyledCard(
              child: Column(
                children: [
                  _SwitchRow(
                    title: l10n.highContrast,
                    value: prefs.isHighContrast,
                    onChanged: prefs.toggleHighContrast,
                  ),
                  _SwitchRow(
                    title: l10n.audioGuideMode,
                    subtitle: l10n.audioGuideModeDesc,
                    value: prefs.audioGuideMode,
                    onChanged: prefs.setAudioGuideMode,
                  ),
                  _SwitchRow(
                    title: l10n.reduceAnimations,
                    subtitle: l10n.reduceAnimationsDesc,
                    value: prefs.reduceAnimations,
                    onChanged: prefs.setReduceAnimations,
                  ),
                  _SwitchRow(
                    title: l10n.simpleMode,
                    subtitle: l10n.simpleModeDesc,
                    value: prefs.simpleMode,
                    onChanged: prefs.setSimpleMode,
                  ),
                  const SizedBox(height: 24),
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
            ),

            const SizedBox(height: 32),

            // LANGUAGE
            _SectionHeader(title: l10n.language),
            _StyledCard(
              child: Row(
                children: [
                  const Icon(Icons.language_rounded, color: AppColors.primaryGold),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.appLanguage, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                        Text(l10n.appLanguageSubtitle, style: TextStyle(fontSize: 12, color: secondaryTextColor)),
                      ],
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: prefs.language,
                      dropdownColor: cardBgColor,
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text("English")),
                        DropdownMenuItem(value: 'ar', child: Text("العربية")),
                      ],
                      onChanged: (val) {
                        if (val != null) prefs.setLanguage(val);
                      },
                    ),
                  ),
                ],
              ),
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
                  _AboutLink(title: l10n.projectInfo),
                  _AboutLink(title: l10n.team),
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

  Future<void> _handlePermission(Permission permission) async {
    final status = await permission.status;
    if (status.isPermanentlyDenied) {
      openAppSettings();
    } else {
      final newStatus = await permission.request();
      setState(() {
        _permissionStatuses[permission] = newStatus;
      });
    }
  }
}

class _StyledCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _StyledCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF7F2E8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(isDark ? 0.2 : 0.15),
          width: 1,
        ),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: isDark ? AppColors.primaryGold : const Color(0xFFC9A34A),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({required this.title, this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                if (subtitle != null)
                  Text(subtitle!, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.primaryGold,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final PermissionStatus status;
  final VoidCallback onTap;

  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String statusText;
    Color statusColor;
    String buttonText = l10n.enable;

    if (status.isGranted) {
      statusText = l10n.enabled;
      statusColor = Colors.green;
      buttonText = l10n.manage;
    } else if (status.isPermanentlyDenied) {
      statusText = l10n.deniedForever;
      statusColor = AppColors.alertRed;
      buttonText = l10n.openSettings;
    } else {
      statusText = l10n.disabled;
      statusColor = isDark ? Colors.white38 : Colors.black38;
      buttonText = l10n.enable;
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryGold),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    Text(description, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${l10n.settings}: $statusText",
                style: TextStyle(fontSize: 13, color: statusColor, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: status.isGranted ? Colors.transparent : AppColors.primaryGold,
                  foregroundColor: status.isGranted ? AppColors.primaryGold : AppColors.darkInk,
                  elevation: 0,
                  side: status.isGranted ? const BorderSide(color: AppColors.primaryGold) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
  const _AboutLink({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primaryGold),
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildChip({required String value, required IconData icon, required String label}) {
      final bool selected = themeMode == value;
      return Expanded(
        child: InkWell(
          onTap: () => onChanged(value),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryGold : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? AppColors.primaryGold : Colors.transparent),
            ),
            child: Column(
              children: [
                Icon(icon, color: selected ? AppColors.darkInk : (isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 4),
                Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: selected ? AppColors.darkInk : (isDark ? Colors.white : Colors.black))),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.appearanceMode, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            buildChip(value: 'system', icon: Icons.phone_iphone, label: l10n.system),
            const SizedBox(width: 8),
            buildChip(value: 'light', icon: Icons.light_mode, label: l10n.light),
            const SizedBox(width: 8),
            buildChip(value: 'dark', icon: Icons.dark_mode, label: l10n.dark),
          ],
        ),
      ],
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
        Text(l10n.textSize, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        Slider(
          value: fontScale,
          min: 0.8,
          max: 1.4,
          divisions: 6,
          activeColor: AppColors.primaryGold,
          label: "${fontScale.toStringAsFixed(1)}x",
          onChanged: onChanged,
        ),
      ],
    );
  }
}
