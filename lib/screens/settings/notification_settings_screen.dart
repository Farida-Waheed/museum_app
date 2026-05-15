import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/notifications/notification_preference_manager.dart';
import '../../core/notifications/notification_types.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_preferences.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _prefManager = NotificationPreferenceManager();
  Map<NotificationCategory, bool> _categoryStates = {};
  bool _masterEnabled = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    await _prefManager.initialize();
    if (!mounted) return;
    setState(() {
      _categoryStates = _prefManager.getAllCategoryStates();
      _masterEnabled = _prefManager.notificationsEnabled;
      _initialized = true;
    });
  }

  Future<void> _setMasterEnabled(bool enabled) async {
    await _prefManager.setNotificationsEnabled(enabled);
    if (!mounted) return;
    setState(() => _masterEnabled = enabled);
  }

  Future<void> _setCategoryEnabled(
    NotificationCategory category,
    bool enabled,
  ) async {
    await _prefManager.setCategoryEnabled(category, enabled);
    if (!mounted) return;
    setState(() => _categoryStates[category] = enabled);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prefs = context.watch<UserPreferencesModel>();
    final isArabic = prefs.language == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppMenuShell(
      title: l10n.notificationSettings.toUpperCase(),
      backgroundColor: isDark ? AppColors.cinematicBackground : AppColors.warmSurface,
      bottomNavigationBar: const BottomNav(currentIndex: 4),
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: !_initialized
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              )
            : ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 120),
                children: [
                  _IntroCard(
                    title: l10n.notificationSettings,
                    subtitle: l10n.notificationSettingsSubtitle,
                  ),
                  const SizedBox(height: 20),
                  _MasterToggleCard(
                    title: _masterEnabled
                        ? l10n.enableAllNotifications
                        : l10n.disableAllNotifications,
                    value: _masterEnabled,
                    onChanged: _setMasterEnabled,
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(label: l10n.notificationSettingsSubtitle),
                  const SizedBox(height: 12),
                  _CategoryCard(
                    title: l10n.tourUpdatesCategory,
                    description: l10n.tourUpdatesCategoryDesc,
                    category: NotificationCategory.tourUpdates,
                    enabled: _categoryStates[NotificationCategory.tourUpdates] ??
                        true,
                    disabledByMaster: !_masterEnabled,
                    onChanged: _setCategoryEnabled,
                  ),
                  _CategoryCard(
                    title: l10n.exhibitRemindersCategory,
                    description: l10n.exhibitRemindersCategoryDesc,
                    category: NotificationCategory.exhibitReminders,
                    enabled:
                        _categoryStates[NotificationCategory.exhibitReminders] ??
                            true,
                    disabledByMaster: !_masterEnabled,
                    onChanged: _setCategoryEnabled,
                  ),
                  _CategoryCard(
                    title: l10n.quizRemindersCategory,
                    description: l10n.quizRemindersCategoryDesc,
                    category: NotificationCategory.quizReminders,
                    enabled:
                        _categoryStates[NotificationCategory.quizReminders] ??
                            true,
                    disabledByMaster: !_masterEnabled,
                    onChanged: _setCategoryEnabled,
                  ),
                  _CategoryCard(
                    title: l10n.guideRemindersCategory,
                    description: l10n.guideRemindersCategoryDesc,
                    category: NotificationCategory.guideReminders,
                    enabled:
                        _categoryStates[NotificationCategory.guideReminders] ??
                            false,
                    disabledByMaster: !_masterEnabled,
                    onChanged: _setCategoryEnabled,
                  ),
                  _CategoryCard(
                    title: l10n.museumNewsCategory,
                    description: l10n.museumNewsCategoryDesc,
                    category: NotificationCategory.museumNews,
                    enabled:
                        _categoryStates[NotificationCategory.museumNews] ??
                            false,
                    disabledByMaster: !_masterEnabled,
                    onChanged: _setCategoryEnabled,
                  ),
                  _CategoryCard(
                    title: l10n.ticketRemindersCategory,
                    description: l10n.ticketRemindersCategoryDesc,
                    category: NotificationCategory.ticketReminders,
                    enabled:
                        _categoryStates[NotificationCategory.ticketReminders] ??
                            true,
                    disabledByMaster: !_masterEnabled,
                    onChanged: _setCategoryEnabled,
                  ),
                  _CategoryCard(
                    title: l10n.systemAlertsCategory,
                    description: l10n.systemAlertsCategoryDesc,
                    category: NotificationCategory.systemAlerts,
                    enabled:
                        _categoryStates[NotificationCategory.systemAlerts] ??
                            true,
                    disabledByMaster: !_masterEnabled,
                    onChanged: _setCategoryEnabled,
                  ),
                ],
              ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.premiumGlassCard(radius: 22, highlighted: true),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.primaryGold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium(context)
                      .copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(subtitle, style: AppTextStyles.metadata(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterToggleCard extends StatelessWidget {
  const _MasterToggleCard({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.secondaryGlassCard(radius: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.titleMedium(context)
                  .copyWith(color: Colors.white, fontSize: 16),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryGold,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.displaySectionTitle(context)
          .copyWith(color: AppColors.softGold, fontSize: 12),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.description,
    required this.category,
    required this.enabled,
    required this.disabledByMaster,
    required this.onChanged,
  });

  final String title;
  final String description;
  final NotificationCategory category;
  final bool enabled;
  final bool disabledByMaster;
  final Future<void> Function(NotificationCategory category, bool enabled)
      onChanged;

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    final textColor = disabledByMaster ? AppColors.neutralMedium : Colors.white;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.secondaryGlassCard(radius: 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium(context)
                      .copyWith(color: textColor, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: AppTextStyles.metadata(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: disabledByMaster ? false : enabled,
            onChanged: disabledByMaster
                ? null
                : (value) => onChanged(category, value),
            activeColor: AppColors.primaryGold,
          ),
        ],
      ),
    );
  }
}
