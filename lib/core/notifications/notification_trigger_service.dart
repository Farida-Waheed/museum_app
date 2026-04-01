import 'notification_types.dart';
import 'notification_models.dart';
import 'notification_service.dart';
import 'notification_preference_manager.dart';

/// Centralized trigger engine for all notifications.
///
/// This service contains all the logic for WHEN to show which notification,
/// based on app events. It prevents logic from being scattered across widgets.
///
/// Integration points:
/// - Tour events (started, next exhibit, completed)
/// - Location/proximity events
/// - User interaction (quiz, guide)
/// - Time-based reminders
/// - System events (connection, battery)
class NotificationTriggerService {
  static final NotificationTriggerService _instance =
      NotificationTriggerService._internal();

  factory NotificationTriggerService() => _instance;

  NotificationTriggerService._internal();

  final _notificationService = NotificationService();
  final _prefManager = NotificationPreferenceManager();
  int _notificationIdCounter = 1000;

  // Track recent notifications to prevent spam
  final Map<String, DateTime> _lastShownNotifications = {};
  final Duration _spamCooldown = const Duration(minutes: 5);

  /// Initialize trigger service
  Future<void> initialize() async {
    await _prefManager.initialize();
  }

  /// ==================== TOUR FLOW ====================

  /// Trigger: Tour will start in N minutes
  Future<void> triggerTourStartingSoon({
    required String title,
    required String body,
    required DateTime startTime,
    String? tourId,
  }) async {
    if (!_prefManager.isCategoryEnabled(NotificationCategory.tourUpdates)) {
      return;
    }

    final payload = NotificationPayload(
      type: NotificationType.tourStartingSoon,
      targetRoute: '/live_tour',
      tourId: tourId,
    );

    final notification = ScheduledNotification(
      id: _getNextNotificationId(),
      type: NotificationType.tourStartingSoon,
      title: title,
      body: body,
      priority: NotificationPriority.high,
      category: NotificationCategory.tourUpdates,
      scheduledTime: startTime,
      payload: payload,
      deduplicationKey: 'tour_starting_soon_$tourId',
    );

    await _notificationService.scheduleNotification(notification);
  }

  /// Trigger: Tour started
  Future<void> triggerTourStarted({
    required String title,
    required String body,
    String? tourId,
  }) async {
    if (!_prefManager.isCategoryEnabled(NotificationCategory.tourUpdates)) {
      return;
    }

    final payload = NotificationPayload(
      type: NotificationType.tourStarted,
      targetRoute: '/live_tour',
      tourId: tourId,
    );

    final notification = ImmediateNotification(
      id: _getNextNotificationId(),
      type: NotificationType.tourStarted,
      title: title,
      body: body,
      priority: NotificationPriority.high,
      category: NotificationCategory.tourUpdates,
      payload: payload,
    );

    await _notificationService.showNotification(notification);
  }

  /// Trigger: Next exhibit ahead
  Future<void> triggerNextExhibit({
    required String title,
    required String body,
    String? exhibitId,
    String? tourId,
  }) async {
    if (!_prefManager.isCategoryEnabled(NotificationCategory.exhibitReminders)) {
      return;
    }

    // Anti-spam: don't show same exhibit twice quickly
    final spamKey = 'next_exhibit_$exhibitId';
    if (_isSpammed(spamKey)) {
      return;
    }

    final payload = NotificationPayload(
      type: NotificationType.nextExhibit,
      targetRoute: '/live_tour',
      exhibitId: exhibitId,
      tourId: tourId,
    );

    final notification = ImmediateNotification(
      id: _getNextNotificationId(),
      type: NotificationType.nextExhibit,
      title: title,
      body: body,
      priority: NotificationPriority.medium,
      category: NotificationCategory.exhibitReminders,
      payload: payload,
    );

    _recordNotification(spamKey);
    await _notificationService.showNotification(notification);
  }

  /// Trigger: Tour completed
  Future<void> triggerTourCompleted({
    required String title,
    required String body,
    String? tourId,
  }) async {
    if (!_prefManager.isCategoryEnabled(NotificationCategory.tourUpdates)) {
      return;
    }

    final payload = NotificationPayload(
      type: NotificationType.tourCompleted,
      targetRoute: '/summary',
      tourId: tourId,
    );

    final notification = ImmediateNotification(
      id: _getNextNotificationId(),
      type: NotificationType.tourCompleted,
      title: title,
      body: body,
      priority: NotificationPriority.high,
      category: NotificationCategory.tourUpdates,
      payload: payload,
      bigBody: body,
    );

    await _notificationService.showNotification(notification);
  }

  /// ==================== SMART EXPERIENCE ====================

  /// Trigger: Nearby exhibit detected
  Future<void> triggerNearbyExhibit({
    required String title,
    required String body,
    String? exhibitId,
  }) async {
    if (!_prefManager.isCategoryEnabled(NotificationCategory.exhibitReminders)) {
      return;
    }

    // Anti-spam: don't notify about same exhibit too often
    final spamKey = 'nearby_exhibit_$exhibitId';
    if (_isSpammed(spamKey)) {
      return;
    }

    final payload = NotificationPayload(
      type: NotificationType.nearbyExhibit,
      targetRoute: '/exhibit_details',
      exhibitId: exhibitId,
    );

    final notification = ImmediateNotification(
      id: _getNextNotificationId(),
      type: NotificationType.nearbyExhibit,
      title: title,
      body: body,
      priority: NotificationPriority.medium,
      category: NotificationCategory.exhibitReminders,
      payload: payload,
    );

    _recordNotification(spamKey);
    await _notificationService.showNotification(notification);
  }

  /// Trigger: Horus-Bot guide nearby
  Future<void> triggerHorusNearby({
    required String title,
    required String body,
  }) async {
    if (!_prefManager.isCategoryEnabled(NotificationCategory.tourUpdates)) {
      return;
    }

    final spamKey = 'horus_nearby';
    if (_isSpammed(spamKey)) {
      return;
    }

    final payload = NotificationPayload(
      type: NotificationType.horusNearby,
      targetRoute: '/chat',
    );

    final notification = ImmediateNotification(
      id: _getNextNotificationId(),
      type: NotificationType.horusNearby,
      title: title,
      body: body,
      priority: NotificationPriority.high,
      category: NotificationCategory.tourUpdates,
      payload: payload,
    );

    _recordNotification(spamKey);
    await _notificationService.showNotification(notification);
  }

  /// Trigger: User inactive during tour
  Future<void> triggerUserInactiveDuringTour({
    required String title,
    required String body,
  }) async {
    if (!_prefManager.isCategoryEnabled(NotificationCategory.tourUpdates)) {
      return;
    }

    final spamKey = 'user_inactive';
    if (_isSpammed(spamKey)) {
      return;
    }

    final payload = NotificationPayload(
      type: NotificationType.userInactiveDuringTour,
      targetRoute: '/map',
    );

    final notification = ImmediateNotification(
      id: _getNextNotificationId(),
      type: NotificationType.userInactiveDuringTour,
      title: title,
      body: body,
      priority: NotificationPriority.low,
      category: NotificationCategory.tourUpdates,
      payload: payload,
    );

    _recordNotification(spamKey);
    await _notificationService.showNotification(notification);
  }

  /// ==================== ENGAGEMENT ====================

  /// Trigger: Quiz available
  Future<void> triggerQuizAvailable({
    required String title,
    required String body,
    String? exhibitId,
    String? quizId,
  }) async {
    if (!_prefManager.isCategoryEnabled(NotificationCategory.quizReminders)) {
      return;
    }

    final payload = NotificationPayload(
      type: NotificationType.quizAvailable,
      targetRoute: '/quiz',
      exhibitId: exhibitId,
      quizId: quizId,
    );

    final notification = ImmediateNotification(
      id: _getNextNotificationId(),
      type: NotificationType.quizAvailable,
      title: title,
      body: body,
      priority: NotificationPriority.medium,
      category: NotificationCategory.quizReminders,
      payload: payload,
    );

    await _notificationService.showNotification(notification);
  }

  /// Trigger: Ask the guide reminder
  Future<void> triggerAskGuideReminder({
    required String title,
    required String body,
  }) async {
    if (!_prefManager.isCategoryEnabled(NotificationCategory.guideReminders)) {
      return;
    }

    final spamKey = 'ask_guide_reminder';
    if (_isSpammed(spamKey)) {
      return;
    }

    final payload = NotificationPayload(
      type: NotificationType.askGuideReminder,
      targetRoute: '/chat',
    );

    final notification = ImmediateNotification(
      id: _getNextNotificationId(),
      type: NotificationType.askGuideReminder,
      title: title,
      body: body,
      priority: NotificationPriority.low,
      category: NotificationCategory.guideReminders,
      payload: payload,
    );

    _recordNotification(spamKey);
    await _notificationService.showNotification(notification);
  }

  /// Trigger: Did you know / museum fact
  Future<void> triggerDidYouKnow({
    required String title,
    required String body,
    String? exhibitId,
  }) async {
    if (!_prefManager.isCategoryEnabled(NotificationCategory.museumNews)) {
      return;
    }

    final spamKey = 'did_you_know_$exhibitId';
    if (_isSpammed(spamKey)) {
      return;
    }

    final payload = NotificationPayload(
      type: NotificationType.didYouKnow,
      targetRoute: exhibitId != null ? '/exhibit_details' : '/exhibits',
      exhibitId: exhibitId,
    );

    final notification = ImmediateNotification(
      id: _getNextNotificationId(),
      type: NotificationType.didYouKnow,
      title: title,
      body: body,
      priority: NotificationPriority.low,
      category: NotificationCategory.museumNews,
      payload: payload,
    );

    _recordNotification(spamKey);
    await _notificationService.showNotification(notification);
  }

  /// ==================== PRACTICAL ====================

  /// Trigger: Ticket / visit reminder
  Future<void> triggerTicketReminder({
    required String title,
    required String body,
    DateTime? reminderTime,
  }) async {
    if (!_prefManager.isCategoryEnabled(NotificationCategory.ticketReminders)) {
      return;
    }

    final payload = NotificationPayload(
      type: NotificationType.ticketReminder,
      targetRoute: '/tickets',
    );

    if (reminderTime != null && reminderTime.isAfter(DateTime.now())) {
      final notification = ScheduledNotification(
        id: _getNextNotificationId(),
        type: NotificationType.ticketReminder,
        title: title,
        body: body,
        priority: NotificationPriority.medium,
        category: NotificationCategory.ticketReminders,
        scheduledTime: reminderTime,
        payload: payload,
        deduplicationKey: 'ticket_reminder_${reminderTime.millisecondsSinceEpoch}',
      );

      await _notificationService.scheduleNotification(notification);
    } else {
      final notification = ImmediateNotification(
        id: _getNextNotificationId(),
        type: NotificationType.ticketReminder,
        title: title,
        body: body,
        priority: NotificationPriority.medium,
        category: NotificationCategory.ticketReminders,
        payload: payload,
      );

      await _notificationService.showNotification(notification);
    }
  }

  /// Trigger: Museum closing soon
  Future<void> triggerMuseumClosingSoon({
    required String title,
    required String body,
  }) async {
    if (!_prefManager.isCategoryEnabled(NotificationCategory.systemAlerts)) {
      return;
    }

    final spamKey = 'museum_closing_soon';
    if (_isSpammed(spamKey)) {
      return;
    }

    final payload = NotificationPayload(
      type: NotificationType.museumClosingSoon,
      targetRoute: '/home',
    );

    final notification = ImmediateNotification(
      id: _getNextNotificationId(),
      type: NotificationType.museumClosingSoon,
      title: title,
      body: body,
      priority: NotificationPriority.medium,
      category: NotificationCategory.systemAlerts,
      payload: payload,
    );

    _recordNotification(spamKey);
    await _notificationService.showNotification(notification);
  }

  /// Trigger: Event reminder
  Future<void> triggerEventReminder({
    required String title,
    required String body,
    DateTime? eventTime,
    String? eventId,
  }) async {
    if (!_prefManager.isCategoryEnabled(NotificationCategory.museumNews)) {
      return;
    }

    final payload = NotificationPayload(
      type: NotificationType.eventReminder,
      targetRoute: '/events',
      eventId: eventId,
    );

    if (eventTime != null && eventTime.isAfter(DateTime.now())) {
      final notification = ScheduledNotification(
        id: _getNextNotificationId(),
        type: NotificationType.eventReminder,
        title: title,
        body: body,
        priority: NotificationPriority.medium,
        category: NotificationCategory.museumNews,
        scheduledTime: eventTime,
        payload: payload,
        deduplicationKey: 'event_reminder_$eventId',
      );

      await _notificationService.scheduleNotification(notification);
    } else {
      final notification = ImmediateNotification(
        id: _getNextNotificationId(),
        type: NotificationType.eventReminder,
        title: title,
        body: body,
        priority: NotificationPriority.medium,
        category: NotificationCategory.museumNews,
        payload: payload,
      );

      await _notificationService.showNotification(notification);
    }
  }

  /// ==================== SYSTEM ====================

  /// Trigger: Tour route changed
  Future<void> triggerRouteChanged({
    required String title,
    required String body,
    String? tourId,
  }) async {
    if (!_prefManager.isCategoryEnabled(NotificationCategory.systemAlerts)) {
      return;
    }

    final payload = NotificationPayload(
      type: NotificationType.routeChanged,
      targetRoute: '/live_tour',
      tourId: tourId,
    );

    final notification = ImmediateNotification(
      id: _getNextNotificationId(),
      type: NotificationType.routeChanged,
      title: title,
      body: body,
      priority: NotificationPriority.high,
      category: NotificationCategory.systemAlerts,
      payload: payload,
    );

    await _notificationService.showNotification(notification);
  }

  /// Trigger: Tour delayed
  Future<void> triggerTourDelayed({
    required String title,
    required String body,
    String? tourId,
  }) async {
    if (!_prefManager.isCategoryEnabled(NotificationCategory.systemAlerts)) {
      return;
    }

    final payload = NotificationPayload(
      type: NotificationType.tourDelayed,
      targetRoute: '/live_tour',
      tourId: tourId,
    );

    final notification = ImmediateNotification(
      id: _getNextNotificationId(),
      type: NotificationType.tourDelayed,
      title: title,
      body: body,
      priority: NotificationPriority.high,
      category: NotificationCategory.systemAlerts,
      payload: payload,
    );

    await _notificationService.showNotification(notification);
  }

  /// Trigger: Robot disconnected
  Future<void> triggerRobotDisconnected({
    required String title,
    required String body,
  }) async {
    if (!_prefManager.isCategoryEnabled(NotificationCategory.systemAlerts)) {
      return;
    }

    final spamKey = 'robot_disconnected';
    if (_isSpammed(spamKey)) {
      return;
    }

    final payload = NotificationPayload(
      type: NotificationType.robotDisconnected,
      targetRoute: '/home',
    );

    final notification = ImmediateNotification(
      id: _getNextNotificationId(),
      type: NotificationType.robotDisconnected,
      title: title,
      body: body,
      priority: NotificationPriority.high,
      category: NotificationCategory.systemAlerts,
      payload: payload,
    );

    _recordNotification(spamKey);
    await _notificationService.showNotification(notification);
  }

  /// Trigger: Connection restored
  Future<void> triggerConnectionRestored({
    required String title,
    required String body,
  }) async {
    if (!_prefManager.isCategoryEnabled(NotificationCategory.systemAlerts)) {
      return;
    }

    final payload = NotificationPayload(
      type: NotificationType.connectionRestored,
      targetRoute: '/home',
    );

    final notification = ImmediateNotification(
      id: _getNextNotificationId(),
      type: NotificationType.connectionRestored,
      title: title,
      body: body,
      priority: NotificationPriority.high,
      category: NotificationCategory.systemAlerts,
      payload: payload,
    );

    await _notificationService.showNotification(notification);
  }

  /// ==================== HELPERS ====================

  /// Get next notification ID
  int _getNextNotificationId() {
    return _notificationIdCounter++;
  }

  /// Check if notification type is spammed (cooldown check)
  bool _isSpammed(String key) {
    final lastTime = _lastShownNotifications[key];
    if (lastTime == null) return false;

    final elapsed = DateTime.now().difference(lastTime);
    return elapsed < _spamCooldown;
  }

  /// Record notification as shown
  void _recordNotification(String key) {
    _lastShownNotifications[key] = DateTime.now();
  }

  /// Cancel all scheduled notifications of a type
  Future<void> cancelNotificationsOfType(NotificationType type) async {
    await _notificationService.cancelNotificationsOfType(type);
  }

  /// Clear all tracking for testing
  void clearForTesting() {
    _lastShownNotifications.clear();
    _notificationService.clearTracking();
  }
}
