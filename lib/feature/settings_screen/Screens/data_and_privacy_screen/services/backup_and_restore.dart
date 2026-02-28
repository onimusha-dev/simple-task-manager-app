import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fuck_your_todos/core/constants/constants.dart';
import 'package:fuck_your_todos/core/services/app_preferences.dart';
import 'package:fuck_your_todos/core/services/notification_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BackupAndRestoreService {
  /// NOTE: calculate db size and return it as a string
  /// returns a string
  /// eg: '10 MB' or '500 KB' or 'Error calc' -> for errors
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

  /// NOTE: create backup and send notification on success or failure
  /// this creates a zip file and saves it to the device
  /// returns void
  Future<void> createBackup() async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final dbFile = File(p.join(appDir.path, DatabaseConstants.fileName));

      if (!await dbFile.exists()) {
        throw Exception('No database found to backup');
      }

      final archive = Archive();

      archive.addFile(
        ArchiveFile(
          DatabaseConstants.fileName,
          dbFile.lengthSync(),
          dbFile.readAsBytesSync(),
        ),
      );

      final walFile = File(p.join(appDir.path, DatabaseConstants.walFileName));
      if (await walFile.exists()) {
        archive.addFile(
          ArchiveFile(
            DatabaseConstants.walFileName,
            walFile.lengthSync(),
            walFile.readAsBytesSync(),
          ),
        );
      }

      final shmFile = File(p.join(appDir.path, DatabaseConstants.shmFileName));
      if (await shmFile.exists()) {
        archive.addFile(
          ArchiveFile(
            DatabaseConstants.shmFileName,
            shmFile.lengthSync(),
            shmFile.readAsBytesSync(),
          ),
        );
      }

      final prefsJson = AppPreferences.exportToJson();
      final prefsBytes = utf8.encode(prefsJson);
      archive.addFile(
        ArchiveFile('settings.json', prefsBytes.length, prefsBytes),
      );

      final zipData = ZipEncoder().encode(archive);

      final appName = AppConstants.appName.replaceAll(' ', '_');
      final dateStr = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final fileName = '${appName}_backup_$dateStr.zip';

      final String? selectedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save backup file',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['zip'],
        bytes: Uint8List.fromList(zipData),
      );

      if (selectedPath == null) {
        throw Exception('User canceled');
      }

      // send notification on backup save
      NotificationService().showInstantBackupAndRestoreNotification(
        id: 1,
        title: 'Backup saved',
        body: 'Backup saved as ${p.basename(selectedPath)}',
      );
    } catch (e) {
      // send notification on backup save failure
      NotificationService().showInstantBackupAndRestoreNotification(
        id: 1,
        title: 'Backup save failed',
        body: 'Failed to save backup: $e',
      );
    }
  }

  /// NOTE: restore backup and send notification on success or failure
  /// this imports a zip file and restores the database and settings
  /// returns void
  Future<void> restoreBackup() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      // handles backup selection
      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final bytes = File(filePath).readAsBytesSync();
        final archive = ZipDecoder().decodeBytes(bytes);

        final appDir = await getApplicationSupportDirectory();

        bool hasDb = false;

        for (final file in archive) {
          if (file.isFile) {
            if (file.name == DatabaseConstants.fileName ||
                file.name == 'journal_app_db.sqlite') {
              hasDb = true;
              break;
            }
          }
        }

        if (!hasDb) {
          throw Exception('Invalid backup file. Database not found.');
        }

        for (final file in archive) {
          if (file.isFile) {
            final data = file.content as List<int>;

            String fileName = file.name;
            if (fileName == 'journal_app_db.sqlite') {
              fileName = DatabaseConstants.fileName; // Backward compatibility
            }

            if (fileName == DatabaseConstants.fileName ||
                fileName == DatabaseConstants.walFileName ||
                fileName == DatabaseConstants.shmFileName) {
              File(p.join(appDir.path, fileName))
                ..createSync(recursive: true)
                ..writeAsBytesSync(data);
            } else if (fileName == 'settings.json') {
              final jsonStr = utf8.decode(data);
              await AppPreferences.importFromJson(jsonStr);
            }
          }
        }

        await calculateDbSize();

        // send notification on backup restore
        NotificationService().showInstantBackupAndRestoreNotification(
          id: 1,
          title: 'Backup restored',
          body:
              'Backup restored successfully. Please restart app to see effects.',
        );
      }
    } catch (e) {
      // send notification on backup restore failure
      NotificationService().showInstantBackupAndRestoreNotification(
        id: 1,
        title: 'Backup restore failed',
        body: 'Failed to restore backup: $e',
      );
    }
  }
}
