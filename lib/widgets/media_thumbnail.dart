import 'dart:io';

import 'package:flutter/material.dart';

import '../models/media_item.dart';

class MediaThumbnail extends StatelessWidget {
  final MediaItem item;

  const MediaThumbnail({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    if (item.isImage) {
      return Image.file(
        File(item.path),
        fit: BoxFit.cover,
      );
    }

    if (item.thumbnail != null &&
    File(item.thumbnail!).existsSync()) {
  return Image.file(
    File(item.thumbnail!),
    fit: BoxFit.cover,
  );
}

return Container(
  color: Colors.black12,
  child: const Center(
    child: Icon(
      Icons.play_circle_fill,
      size: 40,
      color: Colors.red,
    ),
  ),
);
  }
}