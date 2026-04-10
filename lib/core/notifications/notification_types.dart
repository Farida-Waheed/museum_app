// Comprehensive notification type system for the museum app.
// This enum defines all possible notification types, organized by category.

enum NotificationType {
  // ============ TOUR FLOW ============
  /// Tour will start in N minutes
  tourStartingSoon,

  /// Tour has started
  tourStarted,

  /// Next exhibit in route
  nextExhibit,

  /// Tour completed successfully
  tourCompleted,

  // ============ SMART EXPERIENCE ============
  /// User has entered proximity of an exhibit (geo or QR based)
  nearbyExhibit,

  /// Horus-Bot (guide) is available nearby
  horusNearby,

  /// User has been idle during active tour
  userInactiveDuringTour,

  /// Map help / guidance reminder
  mapHelpReminder,

  // ============ ENGAGEMENT ============
  /// Quiz available for completed exhibit
  quizAvailable,

  /// Reminder to ask the guide a question
  askGuideReminder,

  /// Interesting fact / did-you-know
  didYouKnow,

  /// Reminder for previously saved exhibit
  savedExhibitReminder,

  // ============ PRACTICAL ============
  /// Ticket / visit reminder (e.g., "Your visit is today")
  ticketReminder,

  /// Museum closing soon
  museumClosingSoon,

  /// Event starting soon or reminder
  eventReminder,

  /// Schedule/route changed
  scheduleUpdate,

  // ============ SYSTEM ============
  /// Tour route changed
  routeChanged,

  /// Tour delayed
  tourDelayed,

  /// Robot/guide disconnected
  robotDisconnected,

  /// Robot battery low (if applicable)
  robotBatteryLow,

  /// Connection restored after disconnection
  connectionRestored,

  /// Permission prompt follow-up or reminder
  notificationPermissionReminder,
}

enum NotificationPriority {
  /// Passive engagement, can be batched or delayed
  low,

  /// Important but not urgent
  medium,

  /// Requires immediate attention
  high,
}

enum NotificationCategory {
  tourUpdates,
  exhibitReminders,
  quizReminders,
  guideReminders,
  museumNews,
  ticketReminders,
  systemAlerts,
}
