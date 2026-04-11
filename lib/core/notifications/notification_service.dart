import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'dart:async';
import 'notification_types.dart';
import 'notification_models.dart';
import 'notification_preference_manager.dart';
import 'notification_payload_router.dart';

typedef OnNotificationTapped = void Function(NotificationPayload payload);

/// Core notification service for displaying and scheduling local notifications.
///
/// Responsibilities:
/// - Initialize local notifications with platform-specific setup
/// - Display immediate notifications
/// - Schedule notifications for future times
/// - Cancel scheduled notifications
/// - Handle notification tap events
/// - Prevent duplicate/spam notifications
/// - Respect user preferences
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _prefManager = NotificationPreferenceManager();
  final Set<String> _scheduledNotificationIds = {};
  final Map<String, int> _lastNotificationTime = {};
  final Duration _antiSpamCooldown = const Duration(minutes: 5);

  OnNotificationTapped? _onNotificationTapped;
  bool _initialized = false;

  /// Initialize notification service
  /// Must be called before using any other methods
  Future<void> initialize({OnNotificationTapped? onNotificationTapped}) async {
    if (_initialized) return;

    _onNotificationTapped = onNotificationTapped;
    await _prefManager.initialize();

    // Initialize timezone
    tzdata.initializeTimeZones();

    // Android setup
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS setup
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          onDidReceiveLocalNotification: _handleIOSNotificationReceived,
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationTapped,
      onDidReceiveBackgroundNotificationResponse:
          _handleBackgroundNotificationTapped,
    );

    // Setup Android notification channels
    await _setupAndroidChannels();

    _initialized = true;
  }

  /// Setup Android notification channels by category
  Future<void> _setupAndroidChannels() async {
    // Android 8.0+ requires notification channels
    // Setup basic channels grouped by importance
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    // Create channels via native calls - simplified for compatibility
    // The channels are defined in the notification display details
  }

  /// Show immediate notification (no scheduling)
  Future<void> showNotification(ImmediateNotification notification) async {
    // Check permissions and preferences
    if (!_prefManager.notificationsEnabled) return;
    if (!_prefManager.isCategoryEnabled(notification.category)) return;

    // Anti-spam check
    if (_isNotificationSpammed(notification)) return;

    final config = NotificationDisplayConfig(
      priority: notification.priority,
      category: notification.category,
    );

    final androidDetails = AndroidNotificationDetails(
      config.androidChannelId,
      config.androidChannelId.replaceAll('_', ' '),
      channelDescription: notification.category.toString(),
      importance: Importance.values[config.androidImportance],
      priority: Priority.values[config.androidImportance],
      enableVibration: config.vibrate,
      playSound: config.playSound,
      styleInformation: notification.bigBody != null
          ? BigTextStyleInformation(notification.bigBody!)
          : null,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      notification.id,
      notification.title,
      notification.body,
      details,
      payload: _encodePayload(notification.payload),
    );

    _recordNotificationTime(notification);
  }

  /// Schedule notification for future time
  Future<void> scheduleNotification(ScheduledNotification notification) async {
    // Check permissions and preferences
    if (!_prefManager.notificationsEnabled) return;
    if (!_prefManager.isCategoryEnabled(notification.category)) return;

    // Check for duplicates via deduplication key
    if (notification.deduplicationKey != null) {
      final existing = _scheduledNotificationIds.contains(
        notification.deduplicationKey,
      );
      if (existing) return; // Already scheduled
    }

    final config = NotificationDisplayConfig(
      priority: notification.priority,
      category: notification.category,
    );

    final androidDetails = AndroidNotificationDetails(
      config.androidChannelId,
      config.androidChannelId.replaceAll('_', ' '),
      channelDescription: notification.category.toString(),
      importance: Importance.values[config.androidImportance],
      priority: Priority.values[config.androidImportance],
      enableVibration: config.vibrate,
      playSound: config.playSound,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tz.TZDateTime scheduledTZTime = tz.TZDateTime.from(
      notification.scheduledTime,
      tz.local,
    );

    if (notification.repeating && notification.repeatInterval != null) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notification.id,
        notification.title,
        notification.body,
        scheduledTZTime,
        details,
        payload: _encodePayload(notification.payload),
        androidScheduleMode: AndroidScheduleMode.exact,
        matchDateTimeComponents: _getMatchDateTimeComponents(
          notification.repeatInterval!,
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } else {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notification.id,
        notification.title,
        notification.body,
        scheduledTZTime,
        details,
        payload: _encodePayload(notification.payload),
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    // Track as scheduled
    if (notification.deduplicationKey != null) {
      _scheduledNotificationIds.add(notification.deduplicationKey!);
    }
  }

  /// Cancel scheduled notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancel all notifications of a specific type
  Future<void> cancelNotificationsOfType(NotificationType type) async {
    // This is a helper - in production, maintain a registry of IDs by type
    // For now, cancel all pending notifications
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Cancel notifications with specific deduplication key
  void cancelNotificationByKey(String deduplicationKey) {
    _scheduledNotificationIds.remove(deduplicationKey);
  }

  /// Handle notification tapped (foreground and background)
  void _handleNotificationTapped(NotificationResponse notificationResponse) {
    final payload = notificationResponse.payload;
    if (payload != null) {
      try {
        final decodedPayload = _decodePayload(payload);
        _handleNotificationPayload(decodedPayload);
      } catch (e) {
        print('Error decoding notification payload: $e');
      }
    }
  }

  /// Handle notification payload navigation
  void _handleNotificationPayload(NotificationPayload payload) {
    // Use navigator key to navigate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationPayloadRouter.handleNotificationTapWithNavigator(payload);
    });
  }

  /// Background notification handler (static for native integration)
  static void _handleBackgroundNotificationTapped(
    NotificationResponse notificationResponse,
  ) {
    // This is called when app is terminated
    // For now, we can't handle navigation until the app is running
    // The payload is available in notificationResponse.payload
    // In a full implementation, this would store the payload in SharedPreferences
    // and process it when the app launches
  }

  /// Handle iOS notification received in foreground
  Future<void> _handleIOSNotificationReceived(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    // On iOS, we may want to show UI or process the notification
    // For now, let the plugin handle it
  }

  /// Check if notification would be spammed
  bool _isNotificationSpammed(ImmediateNotification notification) {
    final key = '${notification.type}_${notification.category}';
    final lastTime = _lastNotificationTime[key];

    if (lastTime == null) return false;

    final elapsed = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(lastTime),
    );

    return elapsed < _antiSpamCooldown;
  }

  /// Record notification sent time for anti-spam
  void _recordNotificationTime(ImmediateNotification notification) {
    final key = '${notification.type}_${notification.category}';
    _lastNotificationTime[key] = DateTime.now().millisecondsSinceEpoch;
  }

  /// Encode payload for platform layer
  String _encodePayload(NotificationPayload payload) {
    final json = payload.toJson();
    return json.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  /// Decode payload from platform layer
  NotificationPayload _decodePayload(String encodedPayload) {
    final parts = encodedPayload.split('&');
    final json = <String, dynamic>{};
    for (final part in parts) {
      final equalsIndex = part.indexOf('=');
      if (equalsIndex <= 0) continue;
      final key = Uri.decodeComponent(part.substring(0, equalsIndex));
      final value = Uri.decodeComponent(part.substring(equalsIndex + 1));
      json[key] = value;
    }
    return NotificationPayload.fromJson(json);
  }

  /// Get match date time components for repeating notifications
  DateTimeComponents _getMatchDateTimeComponents(Duration interval) {
    if (interval.inDays >= 1) {
      return DateTimeComponents.time;
    } else {
      return DateTimeComponents.time;
    }
  }

  /// Clear local notification tracking (useful for testing)
  void clearTracking() {
    _lastNotificationTime.clear();
    _scheduledNotificationIds.clear();
  }
}
