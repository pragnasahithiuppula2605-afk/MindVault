import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/services.dart';
import '../models/whatsapp_chat.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:just_audio/just_audio.dart';
import '../screens/video_player_screen.dart';
import '../screens/pdf_viewer_screen.dart';

class WhatsappMessageBubble extends StatefulWidget {
  final WhatsappMessage message;
  final bool showSender;

  const WhatsappMessageBubble({
    super.key,
    required this.message,
    this.showSender = true,
  });

  @override
  State<WhatsappMessageBubble> createState() =>
      _WhatsappMessageBubbleState();
}

class _WhatsappMessageBubbleState
    extends State<WhatsappMessageBubble> {
  final AudioPlayer _player = AudioPlayer();

  bool _playing = false;

  @override
  void initState() {
    super.initState();

    _player.playerStateStream.listen((state) async {
      debugPrint(
        "PLAYER: ${state.playing} | ${state.processingState}",
      );

      if (state.processingState == ProcessingState.completed) {
        // Audio has finished.
        if (mounted) {
          setState(() {
            _playing = false;
          });
        }

        // Reset the player to the beginning so it can
        // be played again from the start.
        try {
          await _player.seek(Duration.zero);
          await _player.pause();
        } catch (e) {
          debugPrint("PLAYER RESET ERROR: $e");
        }

        return;
      }

      if (mounted) {
        setState(() {
          _playing = state.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // ==================================================
  // VOICE PLAYBACK
  // ==================================================

  Future<void> _playVoice() async {
    final path = widget.message.mediaPath;

    if (path == null || path.isEmpty) {
      debugPrint("VOICE: mediaPath is null");
      return;
    }

    if (!File(path).existsSync()) {
      debugPrint("VOICE: file does not exist: $path");
      return;
    }

    try {
      if (_playing) {
        await _player.pause();

        if (!mounted) return;

        setState(() {
          _playing = false;
        });

        return;
      }

      // If the previous audio finished, start from the beginning.
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }

      await _player.setFilePath(path);

      if (!mounted) return;

      setState(() {
        _playing = true;
      });

      await _player.play();
    } catch (e) {
      debugPrint("VOICE PLAY ERROR: $e");

      if (!mounted) return;

      setState(() {
        _playing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unable to play audio: $e"),
        ),
      );
    }
  }

  // ==================================================
  // HELPERS
  // ==================================================

  bool get isMe =>
      widget.message.sender.trim().toLowerCase() == "you";

  // ==================================================
  // MESSAGE MENU
  // ==================================================

  void _showMessageMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text("Copy"),
                onTap: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text: widget.message.message,
                    ),
                  );

                  if (context.mounted) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Message copied"),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text("Share"),
                onTap: () async {
                  Navigator.pop(context);

                  await Share.share(
                    widget.message.message,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================================================
  // BUILD
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (widget.message.messageType ==
            WhatsappMessageType.text) {
          _showMessageMenu(context);
        }
      },
      child: Align(
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
                MediaQuery.of(context).size.width * 0.72,
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
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: _buildContent(context),
        ),
      ),
    );
  }

  // ==================================================
  // CONTENT SWITCH
  // ==================================================

  Widget _buildContent(BuildContext context) {
    switch (widget.message.messageType) {
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
        return InkWell(
          onTap: () async {
            await Clipboard.setData(
              ClipboardData(
                text: widget.message.message,
              ),
            );

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Contact copied"),
              ),
            );
          },
          child: _simpleTile(
            Icons.person,
            widget.message.message,
          ),
        );

      case WhatsappMessageType.location:
        return InkWell(
          onTap: () async {
            final url =
                "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.message.message)}";

            await launchUrl(
              Uri.parse(url),
              mode: LaunchMode.externalApplication,
            );
          },
          child: _simpleTile(
            Icons.location_on,
            widget.message.message,
          ),
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
          widget.message.message,
        );
    }
  }

  // ==================================================
  // TEXT
  // ==================================================

  Widget _textBubble() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMe && widget.showSender)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              widget.message.sender,
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
                widget.message.message,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.message.timestamp ?? '',
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

  // ==================================================
  // OPEN FILE
  // ==================================================

  Future<void> _openFile(
    BuildContext context,
    String? path,
  ) async {
    if (path == null || path.isEmpty) {
      return;
    }

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

  // ==================================================
  // IMAGE
  // ==================================================

  Widget _imageBubble(BuildContext context) {
    if (widget.message.mediaPath != null &&
        File(widget.message.mediaPath!).existsSync()) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  title: Text(
                    widget.message.fileName ?? "Image",
                  ),
                ),
                body: PhotoView(
                  imageProvider: FileImage(
                    File(widget.message.mediaPath!),
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
                File(widget.message.mediaPath!),
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
                    widget.message.timestamp ?? '',
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
      widget.message.fileName ?? "Image",
    );
  }

  // ==================================================
  // VIDEO
  // ==================================================

  Widget _videoBubble(BuildContext context) {
    if (widget.message.thumbnailPath != null &&
        File(widget.message.thumbnailPath!).existsSync()) {
      return InkWell(
        onTap: () {
          if (widget.message.mediaPath == null) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(
                path: widget.message.mediaPath!,
                title:
                    widget.message.fileName ?? "Video",
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.file(
                File(widget.message.thumbnailPath!),
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
              Container(
                width: 65,
                height: 65,
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.message.fileName ?? "Video",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        if (widget.message.mediaPath == null) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(
              path: widget.message.mediaPath!,
              title:
                  widget.message.fileName ?? "Video",
            ),
          ),
        );
      },
      child: _simpleTile(
        Icons.videocam,
        widget.message.fileName ?? "Video",
      ),
    );
  }

  // ==================================================
  // VOICE
  // ==================================================

  Widget _voiceBubble(BuildContext context) {
    return InkWell(
      onTap: _playVoice,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              child: Icon(
                _playing
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.message.fileName ??
                    "Voice Message",
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // PDF
  // ==================================================

  Widget _pdfBubble(BuildContext context) {
    return InkWell(
      onTap: () {
        debugPrint("========== PDF ==========");
        debugPrint(
          "File: ${widget.message.fileName}",
        );
        debugPrint(
          "Path: ${widget.message.mediaPath}",
        );

        if (widget.message.mediaPath != null) {
          debugPrint(
            "Exists: ${File(widget.message.mediaPath!).existsSync()}",
          );
        }

        if (widget.message.mediaPath == null) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfViewerScreen(
              path: widget.message.mediaPath!,
              title:
                  widget.message.fileName ?? "PDF",
            ),
          ),
        );
      },
      child: _simpleTile(
        Icons.picture_as_pdf,
        widget.message.fileName ?? "PDF",
      ),
    );
  }

  // ==================================================
  // DOCUMENT
  // ==================================================

  Widget _documentBubble(BuildContext context) {
    return InkWell(
      onTap: () => _openFile(
        context,
        widget.message.mediaPath,
      ),
      child: _simpleTile(
        Icons.description,
        widget.message.fileName ?? "Document",
      ),
    );
  }

  // ==================================================
  // AUDIO
  // ==================================================

  Widget _audioBubble(BuildContext context) {
    return InkWell(
      onTap: () => _openFile(
        context,
        widget.message.mediaPath,
      ),
      child: _simpleTile(
        Icons.audiotrack,
        widget.message.fileName ?? "Audio",
      ),
    );
  }

  // ==================================================
  // LINK
  // ==================================================

  String? _extractUrl(String text) {
    final regex = RegExp(
      r'((?:https?://|www\.)[^\s<>]+)',
      caseSensitive: false,
    );

    final match = regex.firstMatch(text);

    if (match == null) {
      return null;
    }

    var url = match.group(1)!.trim();

    // Remove common punctuation that may be attached
    // to the URL in a WhatsApp message.
    url = url.replaceFirst(
      RegExp(r'[.,!?;:)\]}]+$'),
      '',
    );

    // www.example.com needs a protocol.
    if (url.toLowerCase().startsWith('www.')) {
      url = 'https://$url';
    }

    return url;
  }

  Future<void> _openLink() async {
    final rawMessage = widget.message.message.trim();

    final extractedUrl = _extractUrl(rawMessage);

    if (extractedUrl == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No valid link found"),
        ),
      );

      return;
    }

    final uri = Uri.tryParse(extractedUrl);

    if (uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid link"),
        ),
      );

      return;
    }

    debugPrint("OPENING LINK: $uri");

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unable to open link"),
          ),
        );
      }
    } catch (e) {
      debugPrint("LINK ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unable to open link: $e"),
        ),
      );
    }
  }

  Widget _linkBubble() {
  return InkWell(
    onTap: _openLink,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: double.infinity,
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
            child: Text(
              widget.message.message,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 15,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  // ==================================================
  // SIMPLE TILE
  // ==================================================

  Widget _simpleTile(
    IconData icon,
    String title,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        if (!isMe && widget.showSender)
          Padding(
            padding:
                const EdgeInsets.only(bottom: 6),
            child: Text(
              widget.message.sender,
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
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF128C7E),
                  borderRadius:
                      BorderRadius.circular(10),
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
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w600,
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
            widget.message.timestamp ?? '',
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