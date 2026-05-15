import 'dart:convert';
import 'notification_types.dart';

/// Payload data for deep-linking and context when notification is tapped.
class NotificationPayload {
  final NotificationType type;
  final String? targetRoute;
  final Map<String, String>? routeParams;
  final String? exhibitId;
  final String? tourId;
  final String? eventId;
  final String? quizId;
  final Map<String, dynamic>? customData;

  NotificationPayload({
    required this.type,
    this.targetRoute,
    this.routeParams,
    this.exhibitId,
    this.tourId,
    this.eventId,
    this.quizId,
    this.customData,
  });

  /// Encode payload to JSON string for platform layer
  Map<String, String> toJson() {
    return {
      'type': type.toString(),
      'targetRoute': targetRoute ?? '',
      'exhibitId': exhibitId ?? '',
      'tourId': tourId ?? '',
      'eventId': eventId ?? '',
      'quizId': quizId ?? '',
      if (routeParams != null) 'routeParams': jsonEncode(routeParams),
    };
  }

  /// Decode from platform notification data
  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? '';
    NotificationType type = NotificationType.tourStartingSoon;

    try {
      final typeEnum = typeStr.replaceFirst('NotificationType.', '');
      type = NotificationType.values.firstWhere(
        (e) => e.toString().endsWith(typeEnum),
        orElse: () => NotificationType.tourStartingSoon,
      );
    } catch (_) {}

    Map<String, String>? routeParams;
    final routeParamsRaw = json['routeParams'] as String?;
    if (routeParamsRaw != null && routeParamsRaw.isNotEmpty) {
      try {
        final parsed = jsonDecode(routeParamsRaw) as Map<String, dynamic>;
        routeParams = parsed.map(
          (key, value) => MapEntry(key, value.toString()),
        );
      } catch (_) {
        routeParams = null;
      }
    }

    return NotificationPayload(
      type: type,
      targetRoute: json['targetRoute'] as String?,
      routeParams: routeParams,
      exhibitId: json['exhibitId'] as String?,
      tourId: json['tourId'] as String?,
      eventId: json['eventId'] as String?,
      quizId: json['quizId'] as String?,
      customData: json,
    );
  }

  @override
  String toString() => 'NotificationPayload(type: $type, route: $targetRoute)';
}

/// Scheduled notification config
class ScheduledNotification {
  final int id;
  final NotificationType type;
  final String title;
  final String body;
  final NotificationPriority priority;
  final NotificationCategory category;
  final DateTime scheduledTime;
  final NotificationPayload payload;
  final bool repeating;
  final Duration? repeatInterval;
  final String? deduplicationKey;

  ScheduledNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.priority,
    required this.category,
    required this.scheduledTime,
    required this.payload,
    this.repeating = false,
    this.repeatInterval,
    this.deduplicationKey,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduledNotification &&
          runtimeType == other.runtimeType &&
          deduplicationKey != null &&
          deduplicationKey == other.deduplicationKey;

  @override
  int get hashCode => deduplicationKey?.hashCode ?? super.hashCode;
}

/// Immediate notification (no scheduling)
class ImmediateNotification {
  final int id;
  final NotificationType type;
  final String title;
  final String body;
  final NotificationPriority priority;
  final NotificationCategory category;
  final NotificationPayload payload;
  final String? bigBody;
  final String? summary;

  ImmediateNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.priority,
    required this.category,
    required this.payload,
    this.bigBody,
    this.summary,
  });
}

/// Notification display config (supports future customization per Android channel)
class NotificationDisplayConfig {
  final NotificationPriority priority;
  final NotificationCategory category;
  final bool vibrate;
  final bool playSound;
  final String? soundFile;
  final bool enableLED;
  final String? ledColor;

  NotificationDisplayConfig({
    required this.priority,
    required this.category,
    this.vibrate = true,
    this.playSound = true,
    this.soundFile,
    this.enableLED = true,
    this.ledColor,
  });

  /// Get Android importance level from priority
  int get androidImportance {
    switch (priority) {
      case NotificationPriority.high:
        return 4; // IMPORTANCE_HIGH
      case NotificationPriority.medium:
        return 3; // IMPORTANCE_DEFAULT
      case NotificationPriority.low:
        return 2; // IMPORTANCE_LOW
    }
  }

  /// Get channel ID for Android (organizes by category)
  String get androidChannelId {
    switch (category) {
      case NotificationCategory.tourUpdates:
        return 'tour_updates_channel';
      case NotificationCategory.exhibitReminders:
        return 'exhibit_reminders_channel';
      case NotificationCategory.quizReminders:
        return 'quiz_reminders_channel';
      case NotificationCategory.guideReminders:
        return 'guide_reminders_channel';
      case NotificationCategory.museumNews:
        return 'museum_news_channel';
      case NotificationCategory.ticketReminders:
        return 'ticket_reminders_channel';
      case NotificationCategory.systemAlerts:
        return 'system_alerts_channel';
    }
  }
}
