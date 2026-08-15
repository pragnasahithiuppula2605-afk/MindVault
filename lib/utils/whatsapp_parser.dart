import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/whatsapp_chat.dart';

class ParsedWhatsappChat {
  final WhatsappChat chat;
  final List<WhatsappMessage> messages;

  ParsedWhatsappChat({
    required this.chat,
    required this.messages,
  });
}

class WhatsappParser {
  static Future<ParsedWhatsappChat> parseZip(
    File zipFile,
  ) async {
    final bytes = await zipFile.readAsBytes();

    final archive = ZipDecoder().decodeBytes(bytes);

    // --------------------------------------------------
    // Create permanent local media directory
    // --------------------------------------------------

    final appDir = await getApplicationDocumentsDirectory();

    final mediaDir = Directory(
      p.join(appDir.path, 'whatsapp_media'),
    );

    if (!mediaDir.existsSync()) {
      mediaDir.createSync(recursive: true);
    }

    // --------------------------------------------------
    // Extract media files
    // --------------------------------------------------

    final Map<String, String> mediaFiles = {};

    ArchiveFile? txtFile;

    for (final file in archive) {
      print('ZIP ENTRY: ${file.name}');

      if (!file.isFile) {
        continue;
      }

      // WhatsApp chat text file
      if (file.name.toLowerCase().endsWith('.txt')) {
        txtFile = file;
        continue;
      }

      // --------------------------------------------------
      // Save every media/document file locally
      // --------------------------------------------------

      final baseName = p.basename(file.name);

      final outFile = File(
        p.join(
          mediaDir.path,
          baseName,
        ),
      );

      try {
        outFile.writeAsBytesSync(
          file.content as List<int>,
          flush: true,
        );

        // Store lowercase filename as lookup key.
        mediaFiles[baseName.trim().toLowerCase()] = outFile.path;

        print('SAVED FILE: $baseName');
        print('LOCAL PATH: ${outFile.path}');
        print('FILE EXISTS: ${outFile.existsSync()}');
      } catch (e) {
        print('ERROR SAVING FILE: $baseName');
        print('ERROR: $e');
      }
    }

    // --------------------------------------------------
    // Make sure chat TXT exists
    // --------------------------------------------------

    if (txtFile == null) {
      throw Exception('No WhatsApp chat found.');
    }

    final content = utf8.decode(
      txtFile.content as List<int>,
    );

    return parseText(
      content,
      zipFile.path,
      mediaFiles,
    );
  }

  // ==================================================
  // Parse WhatsApp TXT
  // ==================================================

  static ParsedWhatsappChat parseText(
    String content,
    String path,
    Map<String, String> mediaFiles,
  ) {
    final lines = const LineSplitter().convert(content);

    final messages = <WhatsappMessage>[];

    // --------------------------------------------------
    // Chat title
    // --------------------------------------------------

    final title = File(path)
        .uri
        .pathSegments
        .last
        .replaceAll('.zip', '')
        .replaceAll('.txt', '');

    final chat = WhatsappChat(
      title: title,
      path: path,
      createdAt: DateTime.now().toIso8601String(),
    );

    // --------------------------------------------------
    // WhatsApp message date/time pattern
    // --------------------------------------------------

    final regex = RegExp(
      r'^(\d{1,2}/\d{1,2}/\d{2}),\s'
      r'(\d{1,2}:\d{2}\s(?:AM|PM))\s-\s',
    );

    WhatsappMessage? current;

    // --------------------------------------------------
    // Parse every line
    // --------------------------------------------------

    for (final line in lines) {
      if (regex.hasMatch(line)) {
        // Save previous message
        if (current != null) {
          messages.add(current);
        }

        final data = line.replaceFirst(regex, '');

        final index = data.indexOf(':');

        // ==================================================
        // SYSTEM MESSAGE
        // ==================================================

        if (index == -1) {
          final message = data.trim();

          final fileName = extractFileName(message);

          final mediaPath = findMediaPath(
            fileName,
            mediaFiles,
          );

          current = WhatsappMessage(
            chatId: 0,
            sender: 'System',
            message: message,
            timestamp: '',
            messageType: detectType(message),
            fileName: fileName,
            mediaPath: mediaPath,
            thumbnailPath: null,
            mimeType: null,
            fileSize: getFileSize(mediaPath),
          );
        }

        // ==================================================
        // NORMAL MESSAGE
        // ==================================================

        else {
          final sender = data.substring(0, index).trim();

          final message = data.substring(index + 1).trim();

          final fileName = extractFileName(message);

          print('CHAT FILE: $fileName');

          final mediaPath = findMediaPath(
            fileName,
            mediaFiles,
          );

          print('CHAT MEDIA PATH: $mediaPath');

          current = WhatsappMessage(
            chatId: 0,
            sender: sender,
            message: message,
            timestamp: '',
            messageType: detectType(message),
            fileName: fileName,
            mediaPath: mediaPath,
            thumbnailPath: null,
            mimeType: detectMimeType(fileName),
            fileSize: getFileSize(mediaPath),
          );
        }
      }

      // --------------------------------------------------
      // Continuation of previous message
      // --------------------------------------------------

      else {
        if (current != null) {
          current = current.copyWith(
            message: '${current.message}\n$line',
          );
        }
      }
    }

    // --------------------------------------------------
    // Save final message
    // --------------------------------------------------

    if (current != null) {
      messages.add(current);
    }

    print('======================================');
    print('WHATSAPP PARSER COMPLETE');
    print('TOTAL MESSAGES: ${messages.length}');
    print('MEDIA FILES EXTRACTED: ${mediaFiles.length}');
    print('======================================');

    return ParsedWhatsappChat(
      chat: chat,
      messages: messages,
    );
  }

  // ==================================================
  // Find media path
  // ==================================================

  static String? findMediaPath(
    String? fileName,
    Map<String, String> mediaFiles,
  ) {
    if (fileName == null || fileName.trim().isEmpty) {
      print('MEDIA LOOKUP: filename is null/empty');
      return null;
    }

    // Remove accidental path information and whitespace.
    final key = p.basename(fileName).trim().toLowerCase();

    print('--------------------------------------');
    print('MEDIA LOOKUP: $fileName');
    print('MEDIA KEY: $key');

    // --------------------------------------------------
    // 1. Exact match
    // --------------------------------------------------

    final exactPath = mediaFiles[key];

    if (exactPath != null) {
      if (File(exactPath).existsSync()) {
        print('MEDIA PATH FOUND: $exactPath');
        print('MEDIA FILE EXISTS: true');
        print('--------------------------------------');

        return exactPath;
      }

      print('MEDIA PATH FOUND BUT FILE DOES NOT EXIST: $exactPath');
    }

    // --------------------------------------------------
    // 2. Fallback filename comparison
    // --------------------------------------------------

    for (final entry in mediaFiles.entries) {
      final storedName =
          p.basename(entry.key).trim().toLowerCase();

      if (storedName == key) {
        if (File(entry.value).existsSync()) {
          print(
            'MEDIA PATH FOUND BY FALLBACK: ${entry.value}',
          );
          print('MEDIA FILE EXISTS: true');
          print('--------------------------------------');

          return entry.value;
        }
      }
    }

    // --------------------------------------------------
    // 3. Fallback: remove surrounding quotes
    // --------------------------------------------------

    final cleanedKey = key
        .replaceAll('"', '')
        .replaceAll("'", '')
        .trim();

    if (cleanedKey != key) {
      final cleanedPath = mediaFiles[cleanedKey];

      if (cleanedPath != null &&
          File(cleanedPath).existsSync()) {
        print(
          'MEDIA PATH FOUND AFTER CLEANING: $cleanedPath',
        );
        print('--------------------------------------');

        return cleanedPath;
      }
    }

    // --------------------------------------------------
    // Media not found
    // --------------------------------------------------

    print('MEDIA PATH NOT FOUND');
    print(
      'AVAILABLE MEDIA FILES: ${mediaFiles.keys.toList()}',
    );
    print('--------------------------------------');

    return null;
  }

  // ==================================================
  // Detect message type
  // ==================================================

  static WhatsappMessageType detectType(
    String message,
  ) {
    final text = message.toLowerCase();

    // --------------------------------------------------
    // Images
    // --------------------------------------------------

    if (text.contains('.jpg') ||
        text.contains('.jpeg') ||
        text.contains('.png') ||
        text.contains('.gif') ||
        text.contains('.webp')) {
      return WhatsappMessageType.image;
    }

    // --------------------------------------------------
    // Videos
    // --------------------------------------------------

    if (text.contains('.mp4') ||
        text.contains('.mov') ||
        text.contains('.avi') ||
        text.contains('.mkv') ||
        text.contains('.3gp')) {
      return WhatsappMessageType.video;
    }

    // --------------------------------------------------
    // WhatsApp voice messages
    // --------------------------------------------------

    if (text.contains('.opus')) {
      return WhatsappMessageType.voice;
    }

    // --------------------------------------------------
    // Audio
    // --------------------------------------------------

    if (text.contains('.mp3') ||
        text.contains('.wav') ||
        text.contains('.aac') ||
        text.contains('.m4a')) {
      return WhatsappMessageType.audio;
    }

    // --------------------------------------------------
    // PDF
    // --------------------------------------------------

    if (text.contains('.pdf')) {
      return WhatsappMessageType.pdf;
    }

    // --------------------------------------------------
    // Documents
    // --------------------------------------------------

    if (text.contains('.doc') ||
        text.contains('.docx') ||
        text.contains('.xls') ||
        text.contains('.xlsx') ||
        text.contains('.ppt') ||
        text.contains('.pptx')) {
      return WhatsappMessageType.document;
    }

    // --------------------------------------------------
    // Contact
    // --------------------------------------------------

    if (text.contains('.vcf')) {
      return WhatsappMessageType.contact;
    }

    // --------------------------------------------------
    // Links
    // --------------------------------------------------

    if (text.contains('http://') ||
        text.contains('https://') ||
        text.contains('www.')) {
      return WhatsappMessageType.link;
    }

    return WhatsappMessageType.text;
  }

  // ==================================================
  // Extract filename from WhatsApp message
  // ==================================================

  static String? extractFileName(
    String message,
  ) {
    final regex = RegExp(
      r'([^\n<>:"/\\|?*]+\.[A-Za-z0-9]+)',
      caseSensitive: false,
    );

    final match = regex.firstMatch(message);

    if (match == null) {
      return null;
    }

    final name = match.group(1)?.trim();

    print('EXTRACTED FILE: $name');

    return name;
  }

  // ==================================================
  // Detect MIME type
  // ==================================================

  static String? detectMimeType(
    String? fileName,
  ) {
    if (fileName == null || fileName.isEmpty) {
      return null;
    }

    final extension =
        p.extension(fileName).toLowerCase();

    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';

      case '.png':
        return 'image/png';

      case '.gif':
        return 'image/gif';

      case '.webp':
        return 'image/webp';

      case '.mp4':
        return 'video/mp4';

      case '.mov':
        return 'video/quicktime';

      case '.avi':
        return 'video/x-msvideo';

      case '.mkv':
        return 'video/x-matroska';

      case '.3gp':
        return 'video/3gpp';

      case '.opus':
        return 'audio/opus';

      case '.mp3':
        return 'audio/mpeg';

      case '.wav':
        return 'audio/wav';

      case '.aac':
        return 'audio/aac';

      case '.m4a':
        return 'audio/mp4';

      case '.pdf':
        return 'application/pdf';

      case '.doc':
        return 'application/msword';

      case '.docx':
        return
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

      case '.xls':
        return 'application/vnd.ms-excel';

      case '.xlsx':
        return
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

      case '.ppt':
        return 'application/vnd.ms-powerpoint';

      case '.pptx':
        return
            'application/vnd.openxmlformats-officedocument.presentationml.presentation';

      case '.vcf':
        return 'text/vcard';

      default:
        return null;
    }
  }

  // ==================================================
  // Get media file size
  // ==================================================

  static int? getFileSize(
    String? mediaPath,
  ) {
    if (mediaPath == null || mediaPath.isEmpty) {
      return null;
    }

    try {
      final file = File(mediaPath);

      if (!file.existsSync()) {
        return null;
      }

      return file.lengthSync();
    } catch (_) {
      return null;
    }
  }
}