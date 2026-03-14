import 'package:flutter/material.dart';

enum AppNotificationType {
  tourStart,
  nextExhibit,
  quizAvailable,
  smartTip,
  robotNearby,
}

enum AppNotificationPriority {
  low,
  medium,
  high,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final AppNotificationType type;
  final AppNotificationPriority priority;
  final IconData? icon;
  final VoidCallback? onTap;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    this.icon,
    this.onTap,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNotification &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          message == other.message &&
          type == other.type;

  @override
  int get hashCode => title.hashCode ^ message.hashCode ^ type.hashCode;
}
