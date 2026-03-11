import 'package:flutter/material.dart';
import '../constants/colors.dart';

enum NotificationType {
  tourStart,
  robotArrival,
  quizAvailable,
  tourStatus,
  didYouKnow
}

class NotificationService {
  static void showStructuredNotification({
    required BuildContext context,
    required NotificationType type,
    String? tourId,
    String? exhibitId,
    String? robotLocation,
    String? messageOverride,
    VoidCallback? onTap,
  }) {
    String title = "";
    String body = "";
    IconData icon = Icons.notifications;
    Color iconColor = AppColors.primaryGold;

    switch (type) {
      case NotificationType.tourStart:
        title = "Tour Starting Soon";
        body = messageOverride ?? "Your guided tour with Horus-Bot starts in 5 minutes. Meet the robot at the Main Hall.";
        icon = Icons.timer;
        break;
      case NotificationType.robotArrival:
        title = "Robot Reached Exhibit";
        body = messageOverride ?? "Horus-Bot has arrived at the exhibit. Follow the robot to continue the tour.";
        icon = Icons.location_on;
        break;
      case NotificationType.quizAvailable:
        title = "Quiz Available";
        body = messageOverride ?? "You explored the exhibit! Try a quick quiz.";
        icon = Icons.quiz;
        break;
      case NotificationType.tourStatus:
        title = "Tour Status Update";
        body = messageOverride ?? "Tour status changed.";
        icon = Icons.info_outline;
        break;
      case NotificationType.didYouKnow:
        title = "Did You Know?";
        body = messageOverride ?? "Interesting museum fact available.";
        icon = Icons.lightbulb_outline;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.darkSurface,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.primaryGold.withOpacity(0.2)),
        ),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    body,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        action: onTap != null
            ? SnackBarAction(
                label: "VIEW",
                textColor: AppColors.primaryGold,
                onPressed: onTap,
              )
            : null,
      ),
    );
  }
}
