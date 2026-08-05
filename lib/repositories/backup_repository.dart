import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mindvault/database/database_helper.dart';

class BackupRepository {
  Future<File?> createBackup() async {
    try {
      // Ensure database exists
      await DatabaseHelper.instance.database;

      final databasesPath = await getDatabasesPath();

      final source = File(
        join(databasesPath, 'mindvault.db'),
      );

      if (!await source.exists()) {
        return null;
      }

      final directory =
          await getApplicationDocumentsDirectory();

      final backup = File(
        join(
          directory.path,
          'MindVault_Backup.db',
        ),
      );

      await source.copy(backup.path);

      return backup;
    } catch (e) {
      return null;
    }
  }

  Future<bool> restoreBackup() async {
    try {
      final result =
          await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (result == null) {
        return false;
      }

      final backup =
          File(result.files.single.path!);

      await DatabaseHelper.instance.close();

      final databasesPath =
          await getDatabasesPath();

      final destination = File(
        join(databasesPath, 'mindvault.db'),
      );

      if (await destination.exists()) {
        await destination.delete();
      }

      await backup.copy(destination.path);

      return true;
    } catch (_) {
      return false;
    }
  }
}