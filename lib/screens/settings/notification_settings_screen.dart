import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/notifications/notification_types.dart';
import '../../core/notifications/notification_preference_manager.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_preferences.dart';

/// Notification settings screen for user to control notification preferences.
///
/// Allows users to:
/// - Enable/disable all notifications
/// - Toggle individual notification categories
/// - Check permission status
/// - Open system settings if needed
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _prefManager = NotificationPreferenceManager();
  late Map<NotificationCategory, bool> _categoryStates;
  bool _masterEnabled = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final categoryStates = _prefManager.getAllCategoryStates();
    final masterEnabled = _prefManager.notificationsEnabled;

    setState(() {
      _categoryStates = categoryStates;
      _masterEnabled = masterEnabled;
      _initialized = true;
    });
  }

  Future<void> _setMasterEnabled(bool enabled) async {
    await _prefManager.setNotificationsEnabled(enabled);
    setState(() => _masterEnabled = enabled);
  }

  Future<void> _setCategoryEnabled(
    NotificationCategory category,
    bool enabled,
  ) async {
    await _prefManager.setCategoryEnabled(category, enabled);
    setState(() => _categoryStates[category] = enabled);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic =
        Provider.of<UserPreferencesModel>(context).language == 'ar';

    if (!_initialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.notificationSettings),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationSettings),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.notificationSettingsSubtitle,
                style: AppTextStyles.bodySecondary(context),
              ),
            ),

            // Master toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _masterEnabled
                              ? l10n.enableAllNotifications
                              : l10n.disableAllNotifications,
                          style: AppTextStyles.titleMedium(context),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _masterEnabled,
                    onChanged: _setMasterEnabled,
                    activeColor: AppColors.primaryGold,
                  ),
                ],
              ),
            ),

            const Divider(height: 24),

            // Category toggles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l10n.notificationSettingsSubtitle,
                style: AppTextStyles.titleMedium(context),
              ),
            ),

            _buildCategoryCard(
              context,
              l10n.tourUpdatesCategory,
              l10n.tourUpdatesCategoryDesc,
              NotificationCategory.tourUpdates,
              isArabic,
            ),
            _buildCategoryCard(
              context,
              l10n.exhibitRemindersCategory,
              l10n.exhibitRemindersCategoryDesc,
              NotificationCategory.exhibitReminders,
              isArabic,
            ),
            _buildCategoryCard(
              context,
              l10n.quizRemindersCategory,
              l10n.quizRemindersCategoryDesc,
              NotificationCategory.quizReminders,
              isArabic,
            ),
            _buildCategoryCard(
              context,
              l10n.guideRemindersCategory,
              l10n.guideRemindersCategoryDesc,
              NotificationCategory.guideReminders,
              isArabic,
            ),
            _buildCategoryCard(
              context,
              l10n.museumNewsCategory,
              l10n.museumNewsCategoryDesc,
              NotificationCategory.museumNews,
              isArabic,
            ),
            _buildCategoryCard(
              context,
              l10n.ticketRemindersCategory,
              l10n.ticketRemindersCategoryDesc,
              NotificationCategory.ticketReminders,
              isArabic,
            ),
            _buildCategoryCard(
              context,
              l10n.systemAlertsCategory,
              l10n.systemAlertsCategoryDesc,
              NotificationCategory.systemAlerts,
              isArabic,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String description,
    NotificationCategory category,
    bool isArabic,
  ) {
    final enabled = _categoryStates[category] ?? true;
    final isDisabledByMaster = !_masterEnabled;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium(context).copyWith(
                        color: isDisabledByMaster
                            ? Colors.grey.shade600
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.bodySecondary(context).copyWith(
                        color: isDisabledByMaster
                            ? Colors.grey.shade500
                            : Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isDisabledByMaster ? false : enabled,
                onChanged: isDisabledByMaster
                    ? null
                    : (value) => _setCategoryEnabled(category, value),
                activeColor: AppColors.primaryGold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
