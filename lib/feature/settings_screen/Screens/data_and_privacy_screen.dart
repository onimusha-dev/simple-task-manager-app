import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:fuck_your_todos/core/services/app_preferences.dart';
import 'package:fuck_your_todos/core/constants/constants.dart';
import 'package:fuck_your_todos/core/widgets/pin_screen.dart';

class DataAndPrivacyScreen extends ConsumerStatefulWidget {
  const DataAndPrivacyScreen({super.key});

  @override
  ConsumerState<DataAndPrivacyScreen> createState() =>
      _DataAndPrivacyScreenState();
}

class _DataAndPrivacyScreenState extends ConsumerState<DataAndPrivacyScreen> {
  bool _protectApp = false;
  bool _allowScreenshots = true;
  String _protectionType = 'biometrics';
  String _dbSize = '0 MB';

  @override
  void initState() {
    super.initState();
    _protectApp =
        AppPreferences.getBool(AppPreferences.keyAppProtectionEnabled) ?? false;
    _protectionType =
        AppPreferences.getString(AppPreferences.keyAppProtectionType) ??
        'biometrics';
    _calculateDbSize();
  }

  Future<void> _calculateDbSize() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final dbFile = File(p.join(dir.path, 'journal_app_db.sqlite'));

      int totalBytes = 0;
      if (await dbFile.exists()) {
        totalBytes += await dbFile.length();
      }

      // Also check WAL and SHM files if they exist
      final walFile = File(p.join(dir.path, 'journal_app_db.sqlite-wal'));
      if (await walFile.exists()) {
        totalBytes += await walFile.length();
      }

      final shmFile = File(p.join(dir.path, 'journal_app_db.sqlite-shm'));
      if (await shmFile.exists()) {
        totalBytes += await shmFile.length();
      }

      final mb = totalBytes / (1024 * 1024);
      setState(() {
        if (totalBytes == 0) {
          _dbSize = '0 KB';
        } else if (mb < 1.0) {
          _dbSize = '${(totalBytes / 1024).toStringAsFixed(2)} KB';
        } else {
          _dbSize = '${mb.toStringAsFixed(2)} MB';
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _dbSize = 'Error calc';
        });
      }
    }
  }

  Future<void> _backup() async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final dbFile = File(p.join(appDir.path, 'journal_app_db.sqlite'));

      if (!await dbFile.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No database found to backup')),
          );
        }
        return;
      }

      final String? selectedDirectory = await FilePicker.platform
          .getDirectoryPath();
      if (selectedDirectory == null) {
        return; // User canceled
      }

      final appName = AppConstants.appName.replaceAll(' ', '_');
      final backupFolder = Directory(p.join(selectedDirectory, appName));
      if (!await backupFolder.exists()) {
        await backupFolder.create(recursive: true);
      }

      final dbBackupFile = File(p.join(backupFolder.path, 'db.sqlite'));
      await dbFile.copy(dbBackupFile.path);

      final walFile = File(p.join(appDir.path, 'journal_app_db.sqlite-wal'));
      if (await walFile.exists()) {
        final walBackupFile = File(p.join(backupFolder.path, 'db.sqlite-wal'));
        await walFile.copy(walBackupFile.path);
      }

      final shmFile = File(p.join(appDir.path, 'journal_app_db.sqlite-shm'));
      if (await shmFile.exists()) {
        final shmBackupFile = File(p.join(backupFolder.path, 'db.sqlite-shm'));
        await shmFile.copy(shmBackupFile.path);
      }

      final prefsJson = AppPreferences.exportToJson();
      final settingsFile = File(p.join(backupFolder.path, '.settings.json'));
      await settingsFile.writeAsString(prefsJson);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup saved natively to ${backupFolder.path}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save backup: $e')));
      }
    }
  }

  Future<void> _restore() async {
    try {
      final String? selectedDirectory = await FilePicker.platform
          .getDirectoryPath();

      if (selectedDirectory != null) {
        Directory extractDir = Directory(selectedDirectory);

        Directory? restoredFolder;
        final allEntities = extractDir.listSync(recursive: true);

        for (final entity in allEntities) {
          if (entity is File) {
            final basename = p.basename(entity.path);
            if (basename == 'db.sqlite' ||
                basename == 'journal_app_db.sqlite') {
              restoredFolder = entity.parent;
              if (basename == 'journal_app_db.sqlite') {
                await entity.rename(p.join(restoredFolder.path, 'db.sqlite'));
              }
              break;
            }
          }
        }

        if (restoredFolder == null) {
          throw Exception("Invalid backup folder: Database cannot be found");
        }

        final appDir = await getApplicationSupportDirectory();
        final dbFile = File(p.join(restoredFolder.path, 'db.sqlite'));
        if (await dbFile.exists()) {
          final targetDbFile = File(
            p.join(appDir.path, 'journal_app_db.sqlite'),
          );
          await dbFile.copy(targetDbFile.path);

          final walFile = File(p.join(restoredFolder.path, 'db.sqlite-wal'));
          final targetWalFile = File(
            p.join(appDir.path, 'journal_app_db.sqlite-wal'),
          );
          if (await walFile.exists()) {
            await walFile.copy(targetWalFile.path);
          } else if (await targetWalFile.exists()) {
            await targetWalFile.delete();
          }

          final shmFile = File(p.join(restoredFolder.path, 'db.sqlite-shm'));
          final targetShmFile = File(
            p.join(appDir.path, 'journal_app_db.sqlite-shm'),
          );
          if (await shmFile.exists()) {
            await shmFile.copy(targetShmFile.path);
          } else if (await targetShmFile.exists()) {
            await targetShmFile.delete();
          }
        }

        final settingsFile = File(
          p.join(restoredFolder.path, '.settings.json'),
        );
        if (await settingsFile.exists()) {
          final jsonStr = await settingsFile.readAsString();
          await AppPreferences.importFromJson(jsonStr);
        }

        await _calculateDbSize();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Folder backup restored successfully. Please restart app to see effects.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to restore backup: $e')));
      }
    }
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
                  'Protect app',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Ask for password when starting the app',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Switch(
                  value: _protectApp,
                  onChanged: (value) async {
                    if (value && _protectionType == 'pin') {
                      await AppPreferences.setBool(
                        AppPreferences.keyAppProtectionEnabled,
                        value,
                      );
                      setState(() {
                        _protectApp = value;
                      });
                      return;
                    }
                    setState(() {
                      _protectApp = value;
                    });
                    await AppPreferences.setBool(
                      AppPreferences.keyAppProtectionEnabled,
                      value,
                    );
                  },
                ),
              ),
              if (_protectApp)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(
                    'Authentication Method',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    _protectionType == 'pin'
                        ? 'App PIN'
                        : 'Device Authentication',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: DropdownButton<String>(
                    value: _protectionType,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'biometrics',
                        child: Text('Device Default'),
                      ),
                      DropdownMenuItem(value: 'pin', child: Text('App PIN')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        if (val == 'pin') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PinScreen(
                                isSettingPin: true,
                                onSuccess: () async {
                                  Navigator.pop(context);
                                  await AppPreferences.setString(
                                    AppPreferences.keyAppProtectionType,
                                    val,
                                  );
                                  setState(() {
                                    _protectionType = val;
                                  });
                                },
                                onCancel: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        } else {
                          AppPreferences.setString(
                            AppPreferences.keyAppProtectionType,
                            val,
                          );
                          setState(() {
                            _protectionType = val;
                          });
                        }
                      }
                    },
                  ),
                ),
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
                trailing: Switch(
                  value: _allowScreenshots,
                  onChanged: (value) {
                    setState(() {
                      _allowScreenshots = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Backup and Restore'),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  'Create data backup',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Export your data to a secure file',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Icon(
                  Icons.save_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onTap: _backup,
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  'Restore from backup',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Import existing backup file',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Icon(
                  Icons.restore_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onTap: _restore,
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  'Periodic backups',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Manage automated local backups',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
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
              const SizedBox(height: 8),
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
                trailing: Text(
                  _dbSize,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
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
