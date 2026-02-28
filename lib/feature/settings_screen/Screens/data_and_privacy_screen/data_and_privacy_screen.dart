import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/feature/settings_screen/Screens/data_and_privacy_screen/services/backup_and_restore.dart';

class DataAndPrivacyScreen extends ConsumerStatefulWidget {
  const DataAndPrivacyScreen({super.key});

  @override
  ConsumerState<DataAndPrivacyScreen> createState() =>
      _DataAndPrivacyScreenState();
}

class _DataAndPrivacyScreenState extends ConsumerState<DataAndPrivacyScreen> {
  late String dbSize;

  @override
  void initState() {
    super.initState();

    /// HACK: temporory loading ui
    /// Warning: this is is not a good logic and may cause bugs
    dbSize = 'calculating';
    BackupAndRestoreService().calculateDbSize().then(
      (value) => setState(() => dbSize = value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data & Privacy')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(title: 'App Security'),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  'Screenshot privacy',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Allow taking screenshots of the app',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Switch(value: false, onChanged: (value) => ()),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  'Anonymous Error Reporting',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Send anonymous error reports to help improve the app',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Switch(value: false, onChanged: (value) => ()),
              ),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Backup and Restore'),
              _ListViewItem(
                title: 'Create data backup',
                subtitle: 'Export your data to a secure file',
                icon: Icons.save_outlined,
                onTap: () async => BackupAndRestoreService().createBackup(),
              ),
              _ListViewItem(
                title: 'Restore from backup',
                subtitle: 'Import existing backup file',
                icon: Icons.restore_outlined,
                onTap: () async => BackupAndRestoreService().restoreBackup(),
              ),
              _ListViewItem(
                title: 'Periodic backups',
                subtitle: 'Manage automated local backups',
                icon: Icons.arrow_forward_ios_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PeriodicBackupsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              const _SectionHeader(title: 'Storage'),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  'Storage usage',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Total space used by the app data',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: dbSize == 'calculating'
                    ? const CircularProgressIndicator()
                    : Text(dbSize),
                onTap: () {
                  setState(() {
                    dbSize = 'calculating';
                    BackupAndRestoreService().calculateDbSize().then((value) {
                      setState(() => dbSize = value);
                    });
                  });
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// Note: move this page to a file in core
/// useage: this should be used in places
/// where the list item are just btns with icon and text
/// and no other functionality
///
/// we might use this as a template for other settings pages
/// when it happens move this widget to that file too
class _ListViewItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _ListViewItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}

/// Note: move this page to a saparate file
/// when we add more features to it
class PeriodicBackupsScreen extends StatelessWidget {
  const PeriodicBackupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Periodic Backups')),
      body: Center(
        child: Text(
          'More backup settings coming soon...',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
