import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import '../models/whatsapp_chat.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
final appDir = await getApplicationDocumentsDirectory();

final mediaDir = Directory(
  p.join(appDir.path, 'whatsapp_media'),
);

if (!mediaDir.existsSync()) {
  mediaDir.createSync(recursive: true);
}

final Map<String, String> mediaFiles = {};
    ArchiveFile? txtFile;
    for (final file in archive) {
  print("ZIP ENTRY: ${file.name}");

  if (file.isFile) {
    if (file.name.endsWith('.txt')) {
      txtFile = file;
      continue;
    }

    final outFile = File(
      p.join(
        mediaDir.path,
        p.basename(file.name),
      ),
    );

    outFile.writeAsBytesSync(
      file.content as List<int>,
    );

    final baseName = p.basename(file.name);

mediaFiles[baseName.toLowerCase()] = outFile.path;
print("ZIP ENTRY : ${file.name}");
print("SAVED FILE: $baseName");
print("LOCAL PATH: ${outFile.path}");
  }
}
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

  static ParsedWhatsappChat parseText(
  String content,
  String path,
  Map<String, String> mediaFiles,
) {
    final lines = const LineSplitter().convert(content);

    final messages = <WhatsappMessage>[];

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

    final regex = RegExp(
      r'^(\d{1,2}/\d{1,2}/\d{2}),\s(\d{1,2}:\d{2}\s(?:AM|PM))\s-\s',
    );

    WhatsappMessage? current;

    for (final line in lines) {
      if (regex.hasMatch(line)) {
        if (current != null) {
          messages.add(current);
        }

        final data = line.replaceFirst(regex, '');

        final index = data.indexOf(':');

        if (index == -1) {
          final message = data.trim();

          current = WhatsappMessage(
            chatId: 0,
            sender: 'System',
            message: message,
            timestamp: '',
            messageType: detectType(message),
            fileName: extractFileName(message),
            mediaPath: (() {
  final file = extractFileName(message);

  if (file == null) return null;

  print("CHAT FILE : $file");

  return mediaFiles[file.toLowerCase()];
})(),
            thumbnailPath: null,
            mimeType: null,
            fileSize: null,
          );
        } else {
          final sender = data.substring(0, index).trim();
          final message = data.substring(index + 1).trim();
print(
  "CHAT FILE -> ${extractFileName(message)}",
);
          current = WhatsappMessage(
            chatId: 0,
            sender: sender,
            message: message,
            timestamp: '',
            messageType: detectType(message),
            fileName: extractFileName(message),
            mediaPath: mediaFiles[extractFileName(message) ?? ''],
            thumbnailPath: null,
            mimeType: null,
            fileSize: null,
          );
        }
      } else {
        if (current != null) {
          current = current.copyWith(
            message: "${current.message}\n$line",
          );
        }
      }
    }

    if (current != null) {
      messages.add(current);
    }

    return ParsedWhatsappChat(
      chat: chat,
      messages: messages,
    );
  }

  static WhatsappMessageType detectType(String message) {
    final text = message.toLowerCase();

    if (text.contains('.jpg') ||
        text.contains('.jpeg') ||
        text.contains('.png') ||
        text.contains('.gif') ||
        text.contains('.webp')) {
      return WhatsappMessageType.image;
    }

    if (text.contains('.mp4') ||
        text.contains('.mov') ||
        text.contains('.avi') ||
        text.contains('.mkv') ||
        text.contains('.3gp')) {
      return WhatsappMessageType.video;
    }

    if (text.contains('.opus')) {
      return WhatsappMessageType.voice;
    }

    if (text.contains('.mp3') ||
        text.contains('.wav') ||
        text.contains('.aac') ||
        text.contains('.m4a')) {
      return WhatsappMessageType.audio;
    }

    if (text.contains('.pdf')) {
      return WhatsappMessageType.pdf;
    }

    if (text.contains('.doc') ||
        text.contains('.docx') ||
        text.contains('.xls') ||
        text.contains('.xlsx') ||
        text.contains('.ppt') ||
        text.contains('.pptx')) {
      return WhatsappMessageType.document;
    }

    if (text.contains('.vcf')) {
      return WhatsappMessageType.contact;
    }

    if (text.contains('http://') ||
        text.contains('https://') ||
        text.contains('www.')) {
      return WhatsappMessageType.link;
    }

    return WhatsappMessageType.text;
  }
static String? extractFileName(String message) {
  final regex = RegExp(
    r'([^\n<>:"/\\|?*]+\.[A-Za-z0-9]+)',
    caseSensitive: false,
  );

  final match = regex.firstMatch(message);

  if (match == null) return null;

  final name = match.group(1)?.trim();

  print("EXTRACTED FILE: $name");

  return name;
}
}