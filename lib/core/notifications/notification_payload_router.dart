import 'package:flutter/material.dart';
import '../../app/app.dart';
import '../../app/router.dart';
import 'notification_models.dart';
import 'notification_types.dart';

/// Safely routes app to the correct screen when notification is tapped.
///
/// Handles:
/// - Safe validation of payload data
/// - Mapping notification types to routes
/// - Passing context parameters
/// - Fallback routes if target is unavailable
/// - Avoiding duplicate route pushes
/// - Handling cold starts (app terminated)
class NotificationPayloadRouter {
  static final NotificationPayloadRouter _instance =
      NotificationPayloadRouter._internal();

  factory NotificationPayloadRouter() => _instance;

  NotificationPayloadRouter._internal();

  /// Route to appropriate screen based on notification payload
  ///
  /// Should be called when notification is tapped
  static Future<void> handleNotificationTap(
    BuildContext context,
    NotificationPayload payload,
  ) async {
    try {
      // Validate context
      if (!context.mounted) return;

      // Get route based on notification type
      final route = _getRouteForNotificationType(payload);

      if (route.isEmpty) {
        // Fallback to home
        _navigateSafely(context, AppRoutes.mainHome);
        return;
      }

      // Navigate with parameters if available
      if (payload.routeParams != null && payload.routeParams!.isNotEmpty) {
        _navigateSafelyWithParams(context, route, payload.routeParams!);
      } else {
        _navigateSafely(context, route);
      }
    } catch (e) {
      print('Error handling notification tap: $e');
      // Safe fallback
      if (context.mounted) {
        _navigateSafely(context, AppRoutes.mainHome);
      }
    }
  }

  /// Route to appropriate screen based on notification payload using global navigator
  ///
  /// Should be called when notification is tapped and no BuildContext is available
  static Future<void> handleNotificationTapWithNavigator(
    NotificationPayload payload,
  ) async {
    try {
      // Get the app's navigator key
      final navigatorKey = MuseumApp.navigatorKey;
      final context = navigatorKey.currentContext;

      if (context == null) {
        print('No navigator context available for notification navigation');
        return;
      }

      // Use the existing context-based method
      await handleNotificationTap(context, payload);
    } catch (e) {
      print('Error handling notification tap with navigator: $e');
    }
  }

  /// Get route string for notification type.
  /// If a payload explicitly contains a targetRoute, it takes precedence.
  static String _getRouteForNotificationType(NotificationPayload payload) {
    if (payload.targetRoute != null && payload.targetRoute!.isNotEmpty) {
      return payload.targetRoute!;
    }

    switch (payload.type) {
      // Tour Flow
      case NotificationType.tourStartingSoon:
      case NotificationType.tourStarted:
      case NotificationType.nextExhibit:
      case NotificationType.tourCompleted:
        return AppRoutes.liveTour;

      // Smart Experience
      case NotificationType.nearbyExhibit:
        return payload.exhibitId != null
            ? AppRoutes.exhibitDetails
            : AppRoutes.map;

      case NotificationType.horusNearby:
        return AppRoutes.chat;

      case NotificationType.userInactiveDuringTour:
      case NotificationType.mapHelpReminder:
        return AppRoutes.map;

      // Engagement
      case NotificationType.quizAvailable:
        return AppRoutes.quiz;

      case NotificationType.askGuideReminder:
        return AppRoutes.chat;

      case NotificationType.didYouKnow:
        // Could be exhibit detail if we have context
        if (payload.exhibitId != null) {
          return AppRoutes.exhibitDetails;
        }
        return AppRoutes.exhibits;

      case NotificationType.savedExhibitReminder:
        if (payload.exhibitId != null) {
          return AppRoutes.exhibitDetails;
        }
        return AppRoutes.exhibits;

      // Practical
      case NotificationType.ticketReminder:
        return AppRoutes.tickets;

      case NotificationType.museumClosingSoon:
        return AppRoutes.mainHome;

      case NotificationType.eventReminder:
        return AppRoutes.events;

      case NotificationType.scheduleUpdate:
        return AppRoutes.liveTour;

      // System
      case NotificationType.routeChanged:
      case NotificationType.tourDelayed:
        return AppRoutes.liveTour;

      case NotificationType.robotDisconnected:
      case NotificationType.robotBatteryLow:
      case NotificationType.connectionRestored:
        return AppRoutes.mainHome;

      case NotificationType.notificationPermissionReminder:
        return AppRoutes.accessibility;
    }
  }

  /// Navigate safely to route (checks if already on that route)
  static void _navigateSafely(BuildContext context, String route) {
    if (!context.mounted) return;

    // Get current route
    final navigator = Navigator.of(context);
    final currentRoute = ModalRoute.of(context)?.settings.name;

    // Avoid duplicate navigation
    if (currentRoute == route) return;

    // Pop until home, then navigate
    navigator.pushNamedAndRemoveUntil(route, (route) => route.isFirst);
  }

  /// Navigate with parameters
  static void _navigateSafelyWithParams(
    BuildContext context,
    String route,
    Map<String, String> params,
  ) {
    if (!context.mounted) return;

    final navigator = Navigator.of(context);

    // Build arguments based on route
    dynamic arguments;

    switch (route) {
      case AppRoutes.exhibitDetails:
        arguments = params['exhibitId'];
        break;
      case AppRoutes.quiz:
        arguments = params['quizId'];
        break;
      case AppRoutes.events:
        arguments = params['eventId'];
        break;
      default:
        arguments = params;
    }

    // Navigate
    navigator.pushNamedAndRemoveUntil(
      route,
      (route) => route.isFirst,
      arguments: arguments,
    );
  }

  /// Handle deep link from notification when app is cold started
  ///
  /// Call this from main() or app initialization
  static String? extractDeepLinkRoute(Map<String, dynamic> notificationData) {
    try {
      if (notificationData.isEmpty) return null;

      final typeStr = notificationData['type'] as String? ?? '';
      if (typeStr.isEmpty) return null;

      // Create a minimal payload to determine route
      final payload = NotificationPayload.fromJson(notificationData);
      return _getRouteForNotificationType(payload);
    } catch (e) {
      print('Error extracting deep link: $e');
      return null;
    }
  }
}
