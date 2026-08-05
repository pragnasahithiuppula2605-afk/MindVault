import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';

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

    ArchiveFile? txtFile;

    for (final file in archive) {
      if (file.name.endsWith('.txt')) {
        txtFile = file;
        break;
      }
    }

    if (txtFile == null) {
      throw Exception(
        'No WhatsApp chat found.',
      );
    }

    final content = utf8.decode(
      txtFile.content as List<int>,
    );

    return parseText(
      content,
      zipFile.path,
    );
  }

  static ParsedWhatsappChat parseText(
    String content,
    String path,
  ) {
    final lines = const LineSplitter().convert(
      content,
    );

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

        final data = line.replaceFirst(
          regex,
          '',
        );

        final index = data.indexOf(':');

        if (index == -1) {
          current = WhatsappMessage(
            chatId: 0,
            sender: 'System',
            message: data,
            timestamp: '',
            messageType: WhatsappMessageType.text,
            fileName: null,
            mediaPath: null,
            thumbnailPath: null,
            mimeType: null,
            fileSize: null,
          );
        } else {
          current = WhatsappMessage(
            chatId: 0,
            sender: data.substring(
              0,
              index,
            ),
            message: data
                .substring(index + 1)
                .trim(),
            timestamp: '',
            messageType: WhatsappMessageType.text,
            fileName: null,
            mediaPath: null,
            thumbnailPath: null,
            mimeType: null,
            fileSize: null,
          );
        }
      } else {
        if (current != null) {
          current = current.copyWith(
            message:
                "${current.message}\n$line",
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
}