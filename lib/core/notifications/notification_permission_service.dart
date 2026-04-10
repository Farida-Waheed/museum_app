import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'notification_preference_manager.dart';
import '../../l10n/app_localizations.dart';

/// Handles notification permission requests with proper UX flow.
///
/// Flow:
/// 1. Check if permission was already requested
/// 2. If not, show branded explanation dialog
/// 3. Then request system permission
/// 4. Handle all permission states gracefully
/// 5. Store permission state for future reference
class NotificationPermissionService {
  static final NotificationPermissionService _instance =
      NotificationPermissionService._internal();

  factory NotificationPermissionService() => _instance;

  NotificationPermissionService._internal();

  final _prefManager = NotificationPreferenceManager();
  bool _initialized = false;

  /// Initialize the permission service
  Future<void> initialize() async {
    if (_initialized) return;
    await _prefManager.initialize();
    _initialized = true;
  }

  /// Request notification permission with branded UX
  ///
  /// This shows a friendly explanation first before requesting system permission
  /// Returns true if permission was granted, false otherwise
  Future<bool> requestNotificationPermission(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return false;

    // Check if we already requested this
    if (_prefManager.notificationPermissionPromptShown &&
        _prefManager.notificationPermissionDeclined) {
      // Already declined, do not spam
      return false;
    }

    // Show branded explanation first
    if (!_prefManager.notificationPermissionPromptShown) {
      final shouldContinue = await _showBrandedExplanationDialog(context, l10n);

      if (!shouldContinue) {
        // User dismissed explanation
        await _prefManager.setNotificationPermissionPromptShown(true);
        await _prefManager.setNotificationPermissionDeclined(true);
        return false;
      }

      await _prefManager.setNotificationPermissionPromptShown(true);
    }

    // Request actual permission
    final status = await Permission.notification.request();

    if (status.isDenied) {
      await _prefManager.setNotificationPermissionDeclined(true);
      return false;
    } else if (status.isPermanentlyDenied) {
      // Show option to open settings
      if (context.mounted) {
        _showPermanentlyDeniedDialog(context, l10n);
      }
      return false;
    } else if (status.isGranted) {
      await _prefManager.setNotificationPermissionDeclined(false);
      return true;
    } else if (status.isLimited) {
      // Partial permission
      return true;
    }

    return false;
  }

  /// Check current permission status
  Future<PermissionStatus> checkPermissionStatus() async {
    return Permission.notification.status;
  }

  /// Check if permission is granted
  Future<bool> isPermissionGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Request only if not previously shown/declined
  Future<bool> requestIfAppropriate(BuildContext context) async {
    if (_prefManager.notificationPermissionPromptShown &&
        _prefManager.notificationPermissionDeclined) {
      // Already declined, respect user choice
      return false;
    }

    if (_prefManager.notificationPermissionPromptShown) {
      // Already requested, check current status
      return isPermissionGranted();
    }

    // First time, proceed with full flow
    return requestNotificationPermission(context);
  }

  /// Show branded explanation dialog before system permission
  Future<bool> _showBrandedExplanationDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(l10n.notificationExplanationTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.notificationExplanationBody),
                    const SizedBox(height: 16),
                    _buildExplanationBullet(
                      l10n.notificationExampleTourStarting,
                    ),
                    _buildExplanationBullet(
                      l10n.notificationExampleNextExhibit,
                    ),
                    _buildExplanationBullet(
                      l10n.notificationExampleQuizAvailable,
                    ),
                    _buildExplanationBullet(
                      l10n.notificationExampleTicketReminder,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.notificationExplanationDecline),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.notificationExplanationAllow),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Show dialog when permission is permanently denied
  void _showPermanentlyDeniedDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(l10n.notificationPermissionDeniedTitle),
          content: Text(l10n.notificationPermissionDeniedBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                openAppSettings();
                Navigator.pop(context);
              },
              child: Text(l10n.openSettings),
            ),
          ],
        );
      },
    );
  }

  /// Build a bullet point for explanation dialog
  Widget _buildExplanationBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
