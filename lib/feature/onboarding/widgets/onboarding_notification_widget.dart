import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';

class OnboardingNotificationWidget extends StatelessWidget {
  const OnboardingNotificationWidget({super.key, bool isActive = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_active_rounded,
            size: 120,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            'Stay Informed',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Allow notifications to receive timely reminders directly to your device.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          FilledButton.icon(
            onPressed: () {
              AppSettings.openAppSettings(type: AppSettingsType.notification);
            },
            icon: const Icon(Icons.settings_rounded),
            label: const Text('Configure Notifications'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
