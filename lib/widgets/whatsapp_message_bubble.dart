import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:photo_view/photo_view.dart';

import '../models/whatsapp_chat.dart';

class WhatsappMessageBubble extends StatelessWidget {
  final WhatsappMessage message;
  final bool showSender;

  const WhatsappMessageBubble({
    super.key,
    required this.message,
    this.showSender = true,
  });

  bool get isMe =>
      message.sender.trim().toLowerCase() == "you";

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
  left: isMe ? 70 : 8,
  right: isMe ? 8 : 70,
  top: 2,
  bottom: 2,
),
        padding: const EdgeInsets.symmetric(
  horizontal: 12,
  vertical: 8,
),
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
                  0.72,
        ),
        decoration: BoxDecoration(
  color: isMe
      ? const Color(0xFFE7FFDB)
      : Colors.white,
  borderRadius: BorderRadius.only(
    topLeft: const Radius.circular(18),
    topRight: const Radius.circular(18),
    bottomLeft:
        Radius.circular(isMe ? 18 : 4),
    bottomRight:
        Radius.circular(isMe ? 4 : 18),
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ],
),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (message.messageType) {
      case WhatsappMessageType.text:
        return _textBubble();

      case WhatsappMessageType.image:
        return _imageBubble(context);

      case WhatsappMessageType.video:
        return _videoBubble(context);

      case WhatsappMessageType.pdf:
        return _pdfBubble(context);

      case WhatsappMessageType.document:
        return _documentBubble(context);

      case WhatsappMessageType.audio:
        return _audioBubble(context);

      case WhatsappMessageType.voice:
        return _voiceBubble(context);

      case WhatsappMessageType.link:
        return _linkBubble();

      case WhatsappMessageType.contact:
        return _simpleTile(
          Icons.person,
          message.message,
        );

      case WhatsappMessageType.location:
        return _simpleTile(
          Icons.location_on,
          message.message,
        );

      case WhatsappMessageType.sticker:
        return _simpleTile(
          Icons.emoji_emotions,
          "Sticker",
        );

      case WhatsappMessageType.unknown:
      default:
        return _simpleTile(
          Icons.help_outline,
          message.message,
        );
    }
  }

  Widget _textBubble() {
   return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    if (!isMe && showSender)
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          message.sender,
          style: const TextStyle(
            color: Color(0xFF128C7E),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            message.message,
            style: const TextStyle(
              fontSize: 16,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          message.timestamp ?? '',
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  ],
); 
  }

  Future<void> _openFile(
    BuildContext context,
    String? path,
  ) async {
    if (path == null) return;

    final result = await OpenFilex.open(path);

    if (result.type != ResultType.done) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
        ),
      );
    }
  }
    Widget _imageBubble(BuildContext context) {
  if (message.mediaPath != null &&
      File(message.mediaPath!).existsSync()) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                title: Text(message.fileName ?? "Image"),
              ),
              body: PhotoView(
                imageProvider: FileImage(
                  File(message.mediaPath!),
                ),
              ),
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Image.file(
              File(message.mediaPath!),
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  message.timestamp ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  return _simpleTile(
    Icons.image,
    message.fileName ?? "Image",
  );
}

  Widget _videoBubble(BuildContext context) {
  return InkWell(
    onTap: () => _openFile(
      context,
      message.mediaPath,
    ),
    borderRadius: BorderRadius.circular(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (message.thumbnailPath != null &&
                  File(message.thumbnailPath!).existsSync())
                Image.file(
                  File(message.thumbnailPath!),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              else
                Container(
                  height: 220,
                  width: double.infinity,
                  color: Colors.black12,
                ),

              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 34,
                ),
              ),

              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    message.timestamp ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _pdfBubble(
      BuildContext context) {
    return InkWell(
      onTap: () => _openFile(
        context,
        message.mediaPath,
      ),
      child: _simpleTile(
        Icons.picture_as_pdf,
        message.fileName ?? "PDF",
      ),
    );
  }

  Widget _documentBubble(
      BuildContext context) {
    return InkWell(
      onTap: () => _openFile(
        context,
        message.mediaPath,
      ),
      child: _simpleTile(
        Icons.description,
        message.fileName ??
            "Document",
      ),
    );
  }

  Widget _audioBubble(
      BuildContext context) {
    return InkWell(
      onTap: () => _openFile(
        context,
        message.mediaPath,
      ),
      child: _simpleTile(
        Icons.audiotrack,
        message.fileName ?? "Audio",
      ),
    );
  }

  Widget _voiceBubble(
      BuildContext context) {
    return InkWell(
      onTap: () => _openFile(
        context,
        message.mediaPath,
      ),
      child: _simpleTile(
        Icons.mic,
        message.fileName ??
            "Voice Message",
      ),
    );
  }
    Widget _linkBubble() {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.blue.shade100,
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.link,
          color: Colors.blue,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SelectableText(
            message.message,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 15,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _simpleTile(
  IconData icon,
  String title,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (!isMe && showSender)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            message.sender,
            style: const TextStyle(
              color: Color(0xFF128C7E),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),

      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF128C7E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 6),

      Align(
        alignment: Alignment.bottomRight,
        child: Text(
          message.timestamp ?? '',
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ),
    ],
  );
}
  }