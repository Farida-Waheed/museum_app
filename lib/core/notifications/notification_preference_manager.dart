import 'package:shared_preferences/shared_preferences.dart';
import 'notification_types.dart';

/// Manages user preferences for notifications.
/// Handles category toggles, permission status, and preference persistence.
class NotificationPreferenceManager {
  static final NotificationPreferenceManager _instance =
      NotificationPreferenceManager._internal();

  factory NotificationPreferenceManager() => _instance;

  NotificationPreferenceManager._internal();

  // SharedPreferences keys
  static const String _kNotificationsEnabled = 'notifications_enabled';
  static const String _kNotificationPermissionPromptShown =
      'notification_permission_prompt_shown';
  static const String _kNotificationPermissionDeclined =
      'notification_permission_declined';

  // Category toggles (per-category settings)
  static const String _kCategoryPrefix = 'notification_category_';

  // Default enabled state for each category
  static const Map<NotificationCategory, bool> _defaultCategoryEnabled = {
    NotificationCategory.tourUpdates: true,
    NotificationCategory.exhibitReminders: true,
    NotificationCategory.quizReminders: true,
    NotificationCategory.guideReminders: false,
    NotificationCategory.museumNews: false,
    NotificationCategory.ticketReminders: true,
    NotificationCategory.systemAlerts: true,
  };

  late SharedPreferences _prefs;
  bool _initialized = false;

  /// Initialize the preference manager
  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;

    // Ensure all categories have default values on first run
    for (final category in NotificationCategory.values) {
      if (!_prefs.containsKey(_getCategoryKey(category))) {
        final defaultValue =
            _defaultCategoryEnabled[category] ?? true;
        await setCategoryEnabled(category, defaultValue);
      }
    }

    // Ensure master toggle has a default
    if (!_prefs.containsKey(_kNotificationsEnabled)) {
      await setNotificationsEnabled(true);
    }
  }

  /// Master toggle for all notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_kNotificationsEnabled, enabled);
  }

  bool get notificationsEnabled =>
      _prefs.getBool(_kNotificationsEnabled) ?? true;

  /// Toggle specific notification category
  Future<void> setCategoryEnabled(
    NotificationCategory category,
    bool enabled,
  ) async {
    await _prefs.setBool(_getCategoryKey(category), enabled);
  }

  /// Check if a specific category is enabled
  bool isCategoryEnabled(NotificationCategory category) {
    return _prefs.getBool(_getCategoryKey(category)) ??
        (_defaultCategoryEnabled[category] ?? true);
  }

  /// Get all category states
  Map<NotificationCategory, bool> getAllCategoryStates() {
    final states = <NotificationCategory, bool>{};
    for (final category in NotificationCategory.values) {
      states[category] = isCategoryEnabled(category);
    }
    return states;
  }

  /// Check if notification should be shown based on preferences
  /// Takes into account both master toggle and category toggle
  bool shouldShowNotification(NotificationCategory category) {
    if (!notificationsEnabled) return false;
    return isCategoryEnabled(category);
  }

  /// Permission prompt tracking
  Future<void> setNotificationPermissionPromptShown(bool shown) async {
    await _prefs.setBool(_kNotificationPermissionPromptShown, shown);
  }

  bool get notificationPermissionPromptShown =>
      _prefs.getBool(_kNotificationPermissionPromptShown) ?? false;

  /// Permission declined tracking
  Future<void> setNotificationPermissionDeclined(bool declined) async {
    await _prefs.setBool(_kNotificationPermissionDeclined, declined);
  }

  bool get notificationPermissionDeclined =>
      _prefs.getBool(_kNotificationPermissionDeclined) ?? false;

  /// Get category key for storage
  static String _getCategoryKey(NotificationCategory category) {
    return '$_kCategoryPrefix${category.toString()}';
  }

  /// Reset all preferences to defaults
  Future<void> resetToDefaults() async {
    await setNotificationsEnabled(true);
    await setNotificationPermissionPromptShown(false);
    await setNotificationPermissionDeclined(false);
    for (final category in NotificationCategory.values) {
      final defaultValue =
          _defaultCategoryEnabled[category] ?? true;
      await setCategoryEnabled(category, defaultValue);
    }
  }
}
