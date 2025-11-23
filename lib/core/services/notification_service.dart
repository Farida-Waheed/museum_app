import 'package:flutter/material.dart';

class NotificationService {
  // Simulates sending a local notification
  static void showNotification(BuildContext context, String title, String body) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blue[900],
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.yellow),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(body, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(label: "VIEW", textColor: Colors.white, onPressed: () {}),
      ),
    );
  }
}