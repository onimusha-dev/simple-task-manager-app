import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fuck_your_todos/core/constants/constants.dart';
import 'package:fuck_your_todos/core/services/app_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BackupAndRestoreService {
  Future<String> calculateDbSize() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final dbFile = File(p.join(dir.path, DatabaseConstants.fileName));

      int totalBytes = 0;
      if (await dbFile.exists()) {
        totalBytes += await dbFile.length();
      }

      // Also check WAL and SHM files if they exist
      final walFile = File(p.join(dir.path, DatabaseConstants.walFileName));
      if (await walFile.exists()) {
        totalBytes += await walFile.length();
      }

      final shmFile = File(p.join(dir.path, DatabaseConstants.shmFileName));
      if (await shmFile.exists()) {
        totalBytes += await shmFile.length();
      }

      final mb = totalBytes / (1024 * 1024);

      if (totalBytes == 0) return '0 KB';
      if (mb < 1.0) return '${(totalBytes / 1024).toStringAsFixed(2)} KB';
      return '${mb.toStringAsFixed(2)} MB';
    } catch (e) {
      return 'Error calc';
    }
  }

  Future<String> createBackup() async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final dbFile = File(p.join(appDir.path, DatabaseConstants.fileName));

      if (!await dbFile.exists()) return 'No database found to backup';

      final String? selectedDirectory = await FilePicker.platform
          .getDirectoryPath();
      if (selectedDirectory == null) return 'User canceled';

      final appName = AppConstants.appName.replaceAll(' ', '_');
      final backupFolder = Directory(p.join(selectedDirectory, appName));
      if (!await backupFolder.exists()) {
        await backupFolder.create(recursive: true);
      }

      final dbBackupFile = File(
        p.join(backupFolder.path, DatabaseConstants.fileName),
      );
      await dbFile.copy(dbBackupFile.path);

      final walFile = File(p.join(appDir.path, DatabaseConstants.walFileName));
      if (await walFile.exists()) {
        final walBackupFile = File(
          p.join(backupFolder.path, DatabaseConstants.walFileName),
        );
        await walFile.copy(walBackupFile.path);
      }

      final shmFile = File(p.join(appDir.path, DatabaseConstants.shmFileName));
      if (await shmFile.exists()) {
        final shmBackupFile = File(
          p.join(backupFolder.path, DatabaseConstants.shmFileName),
        );
        await shmFile.copy(shmBackupFile.path);
      }

      final prefsJson = AppPreferences.exportToJson();
      final settingsFile = File(p.join(backupFolder.path, 'settings.json'));
      await settingsFile.writeAsString(prefsJson);

      return 'Backup saved natively to ${backupFolder.path}';
    } catch (e) {
      return 'Failed to save backup: $e';
    }
  }

  Future<String> restoreBackup() async {
    try {
      final String? selectedDirectory = await FilePicker.platform
          .getDirectoryPath();

      // handles backup selection
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
          throw Exception('Invalid backup folder, Database can not be found');
        }

        final appDir = await getApplicationSupportDirectory();
        final dbFile = File(
          p.join(restoredFolder.path, DatabaseConstants.fileName),
        );
        if (await dbFile.exists()) {
          final targetDbFile = File(
            p.join(appDir.path, DatabaseConstants.fileName),
          );
          await dbFile.copy(targetDbFile.path);

          final walFile = File(
            p.join(restoredFolder.path, DatabaseConstants.walFileName),
          );
          final targetWalFile = File(
            p.join(appDir.path, DatabaseConstants.walFileName),
          );
          if (await walFile.exists()) await walFile.copy(targetWalFile.path);
          if (await targetWalFile.exists()) await targetWalFile.delete();

          final shmFile = File(
            p.join(restoredFolder.path, DatabaseConstants.shmFileName),
          );
          final targetShmFile = File(
            p.join(appDir.path, DatabaseConstants.shmFileName),
          );
          if (await shmFile.exists()) await shmFile.copy(targetShmFile.path);
          if (await targetShmFile.exists()) await targetShmFile.delete();
        }

        final settingsFile = File(p.join(restoredFolder.path, 'settings.json'));
        if (await settingsFile.exists()) {
          final jsonStr = await settingsFile.readAsString();
          await AppPreferences.importFromJson(jsonStr);
        }

        await calculateDbSize();

        return 'Folder backup restored successfully. Please restart app to see effects.';
      }
      return 'No backup folder selected';
    } catch (e) {
      return 'Failed to restore backup: $e';
    }
  }
}
