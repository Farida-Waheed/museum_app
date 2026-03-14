import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/user_preferences.dart';
import '../../app/router.dart';

class PermissionOnboardingScreen extends StatefulWidget {
  const PermissionOnboardingScreen({super.key});

  @override
  State<PermissionOnboardingScreen> createState() => _PermissionOnboardingScreenState();
}

class _PermissionOnboardingScreenState extends State<PermissionOnboardingScreen> {
  Future<void> _requestPermission(Permission p) async {
    await p.request();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.cinematicBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  AppColors.cinematicBackground,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    l10n.permissionsTitle,
                    style: AppTextStyles.heroTitle(context).copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.permissionsSubtitle,
                    style: AppTextStyles.body(context).copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 40),

                  Expanded(
                    child: ListView(
                      children: [
                        _PermissionTile(
                          icon: Icons.location_on_outlined,
                          title: l10n.locationPermissionTitle,
                          description: l10n.locationPermissionDesc,
                          permission: Permission.location,
                          onPressed: () => _requestPermission(Permission.location),
                        ),
                        _PermissionTile(
                          icon: Icons.notifications_none_rounded,
                          title: l10n.notificationPermissionTitle,
                          description: l10n.notificationPermissionDesc,
                          permission: Permission.notification,
                          onPressed: () => _requestPermission(Permission.notification),
                        ),
                        _PermissionTile(
                          icon: Icons.camera_alt_outlined,
                          title: l10n.cameraPermissionTitle,
                          description: l10n.cameraPermissionDesc,
                          permission: Permission.camera,
                          onPressed: () => _requestPermission(Permission.camera),
                        ),
                        _PermissionTile(
                          icon: Icons.mic_none_rounded,
                          title: l10n.micPermissionTitle,
                          description: l10n.micPermissionDesc,
                          permission: Permission.microphone,
                          onPressed: () => _requestPermission(Permission.microphone),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.mainHome);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: AppColors.darkInk,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        l10n.continueBtn,
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Permission permission;
  final VoidCallback onPressed;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.permission,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PermissionStatus>(
      future: permission.status,
      builder: (context, snapshot) {
        final isGranted = snapshot.data?.isGranted ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cinematicCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isGranted ? AppColors.primaryGold.withOpacity(0.5) : Colors.white.withOpacity(0.05),
              width: isGranted ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryGold, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (isGranted)
                const Icon(Icons.check_circle, color: AppColors.primaryGold)
              else
                TextButton(
                  onPressed: onPressed,
                  child: const Text("ENABLE", style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        );
      },
    );
  }
}
