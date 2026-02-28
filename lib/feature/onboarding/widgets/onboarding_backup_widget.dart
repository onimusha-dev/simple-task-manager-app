import 'package:flutter/material.dart';
import 'package:fuck_your_todos/feature/settings_screen/Screens/data_and_privacy_screen/services/backup_and_restore.dart';

class OnboardingBackupWidget extends StatelessWidget {
  const OnboardingBackupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 150,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 48),
          Text(
            'Your Data is Secure',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Keep your data safe with native local backups and easy restores. You hold the keys.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          FilledButton.icon(
            onPressed: () async {
              await BackupAndRestoreService().restoreBackup();
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text('Import local backup'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login coming soon...')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                  ),
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Signup coming soon...')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                  ),
                  child: const Text('Signup'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
