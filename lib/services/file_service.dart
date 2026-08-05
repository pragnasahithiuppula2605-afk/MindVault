import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  static Future<String> saveDocument(File sourceFile) async {
    final appDir = await getApplicationDocumentsDirectory();

    final documentsFolder = Directory(
      join(appDir.path, "MindVault", "Documents"),
    );

    if (!await documentsFolder.exists()) {
      await documentsFolder.create(recursive: true);
    }

    final fileName = basename(sourceFile.path);

    final newPath = join(
      documentsFolder.path,
      fileName,
    );

    final newFile = await sourceFile.copy(newPath);

    return newFile.path;
  }

  static Future<bool> deleteDocument(String path) async {
    final file = File(path);

    if (await file.exists()) {
      await file.delete();
      return true;
    }

    return false;
  }

  static Future<bool> exists(String path) async {
    return File(path).exists();
  }
}