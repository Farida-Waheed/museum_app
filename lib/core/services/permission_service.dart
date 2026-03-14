import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/dialogs/branded_permission_dialog.dart';
import '../../models/user_preferences.dart';
import 'package:provider/provider.dart';

class PermissionService {
  static Future<bool> checkAndRequestLocation(BuildContext context, {bool forcePrompt = false}) async {
    if (kIsWeb) return true;

    final status = await Permission.locationWhenInUse.status;
    if (status.isGranted) return true;

    if (forcePrompt && (context.mounted)) {
      return await _showBrandedDialog(
        context,
        icon: Icons.location_on_outlined,
        permission: Permission.locationWhenInUse,
      );
    }
    return false;
  }

  static Future<void> requestInitialPermissions(BuildContext context) async {
    if (kIsWeb) return;

    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    // 1. Notification Permission
    final notifStatus = await Permission.notification.status;
    if (!notifStatus.isGranted && (context.mounted)) {
      await _showBrandedDialog(
        context,
        icon: Icons.notifications_none_rounded,
        permission: Permission.notification,
        title: l10n.notificationPermissionTitle,
        description: l10n.notificationPermissionDesc,
      );
    }

    // 2. Location Permission
    final locStatus = await Permission.locationWhenInUse.status;
    if (!locStatus.isGranted && (context.mounted)) {
      await _showBrandedDialog(
        context,
        icon: Icons.location_on_outlined,
        permission: Permission.locationWhenInUse,
        title: l10n.locationPermissionTitle,
        description: l10n.locationPermissionDesc,
        helperText: l10n.dataReassurance,
      );
    }

    prefs.setHasSeenLocationPrompt(true);
  }

  static Future<bool> _showBrandedDialog(
    BuildContext context, {
    required IconData icon,
    required Permission permission,
    String? title,
    String? description,
    String? helperText,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);

    bool granted = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BrandedPermissionDialog(
        icon: icon,
        title: title ?? l10n.locationPermissionTitle,
        description: description ?? l10n.locationPermissionDesc,
        helperText: helperText,
        isHighContrast: prefs.isHighContrast,
        onAllow: () async {
          Navigator.pop(context);
          final result = await permission.request();
          granted = result.isGranted;
        },
        onDeny: () => Navigator.pop(context),
      ),
    );
    return granted;
  }
}
