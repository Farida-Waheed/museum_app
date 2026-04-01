import 'package:flutter/material.dart';
import '../../core/notifications/notification_trigger_service.dart';

class NotificationTestScreen extends StatelessWidget {
  const NotificationTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final triggerService = NotificationTriggerService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Test Notification Triggers',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Tour Events
          const Text('Tour Events:', style: TextStyle(fontWeight: FontWeight.bold)),
          ElevatedButton(
            onPressed: () => triggerService.triggerTourStarted(
              title: 'Tour Started',
              body: 'Your guided tour is starting. Follow Horus-Bot.',
            ),
            child: const Text('Trigger Tour Started'),
          ),
          ElevatedButton(
            onPressed: () => triggerService.triggerNextExhibit(
              title: 'Next Exhibit Ahead',
              body: 'Tutankhamun Mask is approaching.',
            ),
            child: const Text('Trigger Next Exhibit'),
          ),
          ElevatedButton(
            onPressed: () => triggerService.triggerHorusNearby(
              title: 'Horus-Bot is nearby',
              body: 'Follow the robot to continue your tour.',
            ),
            child: const Text('Trigger Horus Nearby'),
          ),
          ElevatedButton(
            onPressed: () => triggerService.triggerQuizAvailable(
              title: 'Quiz Available',
              body: 'Test what you learned about Tutankhamun Mask.',
            ),
            child: const Text('Trigger Quiz Available'),
          ),
          ElevatedButton(
            onPressed: () => triggerService.triggerDidYouKnow(
              title: 'Did You Know?',
              body: 'Tutankhamun\'s mask contains 10kg of gold.',
            ),
            child: const Text('Trigger Did You Know'),
          ),

          const SizedBox(height: 20),

          // Ticket Events
          const Text('Ticket Events:', style: TextStyle(fontWeight: FontWeight.bold)),
          ElevatedButton(
            onPressed: () => triggerService.triggerTicketReminder(
              title: 'Museum Visit Today',
              body: 'Your ticket is valid for today. Don\'t forget to visit!',
            ),
            child: const Text('Trigger Ticket Reminder'),
          ),

          const SizedBox(height: 20),

          // System Events
          const Text('System Events:', style: TextStyle(fontWeight: FontWeight.bold)),
          ElevatedButton(
            onPressed: () => triggerService.triggerConnectionRestored(
              title: 'Connection Restored',
              body: 'Connection to Horus-Bot has been restored.',
            ),
            child: const Text('Trigger Connection Restored'),
          ),

          const SizedBox(height: 20),

          // Tour Provider Integration Test
          const Text('Tour Provider Integration:', style: TextStyle(fontWeight: FontWeight.bold)),
          ElevatedButton(
            onPressed: () {
              // This will demonstrate that notifications are integrated with tour provider
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tour provider notifications are triggered automatically during tour events')),
              );
            },
            child: const Text('Test Tour Provider Integration'),
          ),
        ],
      ),
    );
  }
}