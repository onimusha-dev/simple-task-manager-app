import 'package:flutter/material.dart';
import 'package:fuck_your_todos/core/services/notification_service.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Screen')),
      body: Column(
        children: [
          const Text('Test Screen'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await NotificationService().showTestNotification();
            },
            child: const Text('Send Scheduled Notification Placeholder'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await NotificationService()
                  .showInstantBackupAndRestoreNotification(
                    id: 1,
                    title: 'Hello! I am an instant notification',
                    body: 'This notification showed up immediately on tap.',
                  );
            },
            child: const Text('Send Instant Demo Notification'),
          ),
        ],
      ),
    );
  }
}
