import 'package:flutter/material.dart';

class PdfThumbnail extends StatelessWidget {
  final String path;

  const PdfThumbnail({
    super.key,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.picture_as_pdf,
        color: Colors.red,
        size: 34,
      ),
    );
  }
}