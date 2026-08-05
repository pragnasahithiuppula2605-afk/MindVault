import 'package:flutter/material.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/document.dart';
import '../models/link_item.dart';
import '../models/note.dart';
import '../models/whatsapp_chat.dart';

import 'note_details_screen.dart';
import 'whatsapp_chat_screen.dart';
import '../models/media_item.dart';
import '../models/search_result.dart';
import '../repositories/global_search_repository.dart';
import '../widgets/module_empty_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  final GlobalSearchRepository _repository =
      GlobalSearchRepository();

  List<SearchResult> _results = [];

  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    final results = await _repository.search(query);

    if (!mounted) return;

    setState(() {
      _results = results;
      _loading = false;
    });
  }

  IconData _icon(SearchModule module) {
    switch (module) {
      case SearchModule.note:
        return Icons.note;

      case SearchModule.document:
        return Icons.description;

      case SearchModule.media:
        return Icons.photo_library;

      case SearchModule.whatsapp:
        return Icons.chat;

      case SearchModule.link:
        return Icons.link;
    }
  }

  String _moduleName(SearchModule module) {
    switch (module) {
      case SearchModule.note:
        return "Note";

      case SearchModule.document:
        return "Document";

      case SearchModule.media:
        return "Media";

      case SearchModule.whatsapp:
        return "WhatsApp";

      case SearchModule.link:
        return "Link";
    }
  }
Widget _leadingWidget(SearchResult result) {
  if (result.module == SearchModule.media) {
    final media = result.data as MediaItem;

    if (media.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(media.path),
          width: 58,
          height: 58,
          fit: BoxFit.cover,
        ),
      );
    }

    if (result.thumbnailPath != null &&
        File(result.thumbnailPath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(result.thumbnailPath!),
          width: 58,
          height: 58,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  return Container(
  width: 58,
  height: 58,
  decoration: BoxDecoration(
    color: Theme.of(context)
        .colorScheme
        .primaryContainer,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Icon(
    _icon(result.module),
    size: 28,
    color: Theme.of(context)
        .colorScheme
        .primary,
  ),
);
}

Color _badgeColor(SearchModule module) {
  switch (module) {
    case SearchModule.note:
      return Colors.orange;

    case SearchModule.document:
      return Colors.red;

    case SearchModule.media:
      return Colors.green;

    case SearchModule.whatsapp:
      return Colors.teal;

    case SearchModule.link:
      return Colors.blue;
  }
}
Map<SearchModule, List<SearchResult>> _groupResults() {
  final Map<SearchModule, List<SearchResult>> grouped = {};

  for (final result in _results) {
    grouped.putIfAbsent(result.module, () => []);
    grouped[result.module]!.add(result);
  }

  return grouped;
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Global Search"),
      ),
      body: SafeArea(
  child: Column(
          children: [
          Container(
  padding: const EdgeInsets.fromLTRB(
    16,
    16,
    16,
    12,
  ),
  decoration: BoxDecoration(
    color: Theme.of(context).scaffoldBackgroundColor,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: TextField(
    controller: _controller,
    onChanged: (value) {
      setState(() {});
      _search(value);
    },
    decoration: InputDecoration(
      hintText: "Search everything...",
      hintStyle: TextStyle(
        color: Colors.grey.shade600,
      ),
      prefixIcon: const Icon(Icons.search),
      suffixIcon: _controller.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();

                setState(() {
                  _results.clear();
                });
              },
            )
          : null,
      filled: true,
      fillColor:
          Theme.of(context).colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
    ),
  ),
),  
if (_controller.text.isNotEmpty && !_loading)
  Padding(
    padding: const EdgeInsets.fromLTRB(
      16,
      4,
      16,
      12,
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primaryContainer,
            borderRadius:
                BorderRadius.circular(14),
          ),
          child: Text(
            "${_results.length}",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
          ),
        ),

        const SizedBox(width: 12),

        const Text(
          "Results Found",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  ),

Expanded(
  child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )
                  : _controller.text.isEmpty
                      ? const ModuleEmptyState(
                          icon: Icons.search,
                          title: "Search Your Vault",
                          subtitle:
                              "Search Notes, Documents, Media, WhatsApp and Links.",
                        )
                      : _results.isEmpty
                          ? const ModuleEmptyState(
                              icon: Icons.search_off,
                              title:
                                  "No Results Found",
                              subtitle:
                                  "Try another keyword.",
                            )
                          : Builder(
  builder: (context) {
    final grouped = _groupResults();

    return ListView(
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Padding(
  padding: const EdgeInsets.only(
    top: 20,
    bottom: 10,
  ),
  child: Row(
    children: [
      CircleAvatar(
        radius: 16,
        backgroundColor: _badgeColor(entry.key)
            .withOpacity(.15),
        child: Icon(
          _icon(entry.key),
          color: _badgeColor(entry.key),
          size: 18,
        ),
      ),

      const SizedBox(width: 10),

      Text(
        _moduleName(entry.key).toUpperCase(),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: .5,
        ),
      ),

      const SizedBox(width: 8),

      Expanded(
        child: Divider(
          thickness: 1,
          color: Colors.grey.shade300,
        ),
      ),
    ],
  ),
),

            ...entry.value.map((result) {
              return Card(
  elevation: 3,
  shadowColor: Colors.black12,
  margin: const EdgeInsets.only(
    bottom: 12,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
  ),
  child: InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () async {
  switch (result.module) {
    case SearchModule.note:
      final note = result.data as Note;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NoteDetailsScreen(
            note: note,
          ),
        ),
      );
      break;

    case SearchModule.document:
      final document = result.data as Document;

      final openResult = await OpenFilex.open(
        document.path,
      );

      if (!mounted) return;

      if (openResult.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(openResult.message),
          ),
        );
      }
      break;

    case SearchModule.media:
      final media = result.data as MediaItem;

      if (media.isImage) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(
                title: Text(media.name),
              ),
              body: PhotoView(
                imageProvider: FileImage(
                  File(media.path),
                ),
              ),
            ),
          ),
        );
      } else {
        final openResult = await OpenFilex.open(
          media.path,
        );

        if (!mounted) return;

        if (openResult.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(openResult.message),
            ),
          );
        }
      }
      break;

    case SearchModule.whatsapp:
      final chat = result.data as WhatsappChat;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WhatsappChatScreen(
            chat: chat,
          ),
        ),
      );
      break;

    case SearchModule.link:
      final link = result.data as LinkItem;

      final uri = Uri.parse(link.url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
      break;
  }
},
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [

          _leadingWidget(result),

          const SizedBox(width: 14),

        Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        result.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),

      const SizedBox(height: 4),

      Text(
        result.subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey.shade700,
        ),
      ),

      const SizedBox(height: 10),

      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: _badgeColor(result.module),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          _moduleName(result.module),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    ],
  ),
),  

          const SizedBox(width: 10),

                    Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey.shade500,
          ),
        ],
      ),
    ),
  ),
);
            }),
          ],
        );
      }).toList(),
    );
  },
),
            ),
          ],
        ),
      ),
    );
  }
}