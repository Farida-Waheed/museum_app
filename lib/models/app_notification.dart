import 'package:flutter/material.dart';

enum AppNotificationType {
  // Tour
  tourStart,
  tourStarting, // Added
  nextExhibit, // Added for compatibility
  tourNextExhibit,
  robotNearby, // Added for compatibility
  tourRobotNearby,
  tourDelayed,
  rerouted, // Added
  tourOffRoute,
  tourCompleted,
  // Quiz / Learning
  quizAvailable,
  quizReminder,
  quizSummary,
  achievementUnlocked,
  // Tickets / Events
  ticketBooked,
  eventReminder,
  ticketReminder,
  ticketReady,
  // Exhibit / Features
  featureAR,
  arAvailable, // Added
  featureAudioGuide,
  audioGuideAvailable, // Added
  featureAccessibility,
  accessibilityAvailable, // Added
  featureHighlight,
  smartTip,
  // System
  systemRobotDisconnected,
  robotDisconnected, // Added
  systemRobotBatteryLow,
  robotLowBattery, // Added
  systemConnectionRestored,
  systemSyncing,
  // Visit
  visitSummaryReady,
  tourSummaryReady, // Added
  visitMemories,
  visitContinue,
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
