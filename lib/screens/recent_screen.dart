import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/recent_display_item.dart';
import '../repositories/recent_repository.dart';
import '../database/database_helper.dart';

import 'note_details_screen.dart';
import 'whatsapp_chat_screen.dart';

import '../widgets/module_empty_state.dart';

class RecentScreen extends StatefulWidget {
  const RecentScreen({super.key});

  @override
  State<RecentScreen> createState() =>
      _RecentScreenState();
}

class _RecentScreenState
    extends State<RecentScreen> {
  final RecentRepository repository =
      RecentRepository();

  final DatabaseHelper database =
      DatabaseHelper.instance;

  List<RecentDisplayItem> items = [];

  List<RecentDisplayItem> filteredItems = [];

  bool loading = true;

  bool searchMode = false;

  bool newestFirst = true;

  final TextEditingController searchController =
      TextEditingController();

  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    loadRecentItems();
  }

  Future<void> loadRecentItems() async {
    final data =
        await repository.getDisplayItems();

    if (!mounted) return;

    items = data;
    loading = false;

    applyFilters();
  }

  void applyFilters() {
    filteredItems = List.from(items);

    // SEARCH
    if (searchController.text
        .trim()
        .isNotEmpty) {
      final search = searchController.text
          .toLowerCase();

      filteredItems = filteredItems
          .where((item) {
        return item.title
            .toLowerCase()
            .contains(search);
      }).toList();
    }

    // FILTER
    if (selectedFilter != "All") {
      filteredItems =
          filteredItems.where((item) {
        return item.type ==
            selectedFilter;
      }).toList();
    }

    // SORT
    filteredItems.sort((a, b) {
      if (newestFirst) {
        return b.openedAt.compareTo(
          a.openedAt,
        );
      }

      return a.openedAt.compareTo(
        b.openedAt,
      );
    });

    setState(() {});
  }

  Widget buildFilterChip(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(title),
        selected:
            selectedFilter == value,
        onSelected: (_) {
          selectedFilter = value;
          applyFilters();
        },
      ),
    );
  }
    String formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 30) {
      return "Just now";
    }

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min ago";
    }

    if (difference.inHours < 24) {
      return "${difference.inHours} hr ago";
    }

    if (difference.inDays == 1) {
      return "Yesterday";
    }

    if (difference.inDays < 7) {
      return "${difference.inDays} days ago";
    }

    return DateFormat("dd MMM yyyy")
        .format(date);
  }

  IconData getIcon(String type) {
    switch (type) {
      case "note":
        return Icons.note;

      case "document":
        return Icons.picture_as_pdf;

      case "media":
        return Icons.perm_media;

      case "link":
        return Icons.link;

      case "whatsapp":
        return Icons.chat;

      default:
        return Icons.insert_drive_file;
    }
  }

  Color getIconColor(String type) {
    switch (type) {
      case "note":
        return Colors.orange;

      case "document":
        return Colors.red;

      case "media":
        return Colors.green;

      case "link":
        return Colors.blue;

      case "whatsapp":
        return Colors.teal;

      default:
        return Colors.grey;
    }
  }

  Widget buildThumbnail(
    RecentDisplayItem item,
  ) {
    if (item.type == "media" &&
        item.thumbnail != null &&
        File(item.thumbnail!)
            .existsSync()) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(12),
        child: Image.file(
          File(item.thumbnail!),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: getIconColor(item.type)
            .withOpacity(0.12),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Icon(
        getIcon(item.type),
        color: getIconColor(item.type),
        size: 28,
      ),
    );
  }

  Future<void> openRecentItem(
    RecentDisplayItem item,
  ) async {
    switch (item.type) {
      case "note":
        final notes =
            await database.getAllNotes();

        try {
          final note = notes.firstWhere(
            (e) => e.id == item.itemId,
          );

          if (!mounted) return;

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  NoteDetailsScreen(
                note: note,
              ),
            ),
          );
        } catch (_) {}

        break;

      case "document":
        final docs =
            await database
                .getAllDocuments();

        try {
          final doc = docs.firstWhere(
            (e) => e.id == item.itemId,
          );

          await OpenFilex.open(doc.path);
        } catch (_) {}

        break;

      case "media":
        final media =
            await database.getAllMedia();

        try {
          final mediaItem =
              media.firstWhere(
            (e) => e.id == item.itemId,
          );

          if (mediaItem.isImage) {
            if (!mounted) return;

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(
                    title: Text(
                      mediaItem.name,
                    ),
                  ),
                  body: PhotoView(
                    imageProvider:
                        FileImage(
                      File(
                        mediaItem.path,
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            await OpenFilex.open(
              mediaItem.path,
            );
          }
        } catch (_) {}

        break;

      case "link":
        final links =
            await database.getAllLinks();

        try {
          final link =
              links.firstWhere(
            (e) => e.id == item.itemId,
          );

          await launchUrl(
            Uri.parse(link.url),
            mode: LaunchMode
                .externalApplication,
          );
        } catch (_) {}

        break;

      case "whatsapp":
        final chats =
            await database
                .getAllWhatsappChats();

        try {
          final chat =
              chats.firstWhere(
            (e) => e.id == item.itemId,
          );

          if (!mounted) return;

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  WhatsappChatScreen(
                chat: chat,
              ),
            ),
          );
        } catch (_) {}

        break;
    }
  }
    @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: searchMode
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Search...",
                  border: InputBorder.none,
                ),
                onChanged: (_) => applyFilters(),
              )
            : const Text("Recent"),
        actions: [
          IconButton(
            icon: Icon(
              searchMode
                  ? Icons.close
                  : Icons.search,
            ),
            onPressed: () {
              setState(() {
                if (searchMode) {
                  searchController.clear();
                  searchMode = false;
                  applyFilters();
                } else {
                  searchMode = true;
                }
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case "newest":
                  newestFirst = true;
                  applyFilters();
                  break;

                case "oldest":
                  newestFirst = false;
                  applyFilters();
                  break;

                case "clear":
                  await repository.clearHistory();
                  await loadRecentItems();
                  break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: "newest",
                child: Text("Newest First"),
              ),
              PopupMenuItem(
                value: "oldest",
                child: Text("Oldest First"),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: "clear",
                child: Text("Clear Recent History"),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              children: [
                buildFilterChip(
                  "All",
                  "All",
                ),
                buildFilterChip(
                  "Notes",
                  "note",
                ),
                buildFilterChip(
                  "Documents",
                  "document",
                ),
                buildFilterChip(
                  "Media",
                  "media",
                ),
                buildFilterChip(
                  "Links",
                  "link",
                ),
                buildFilterChip(
                  "WhatsApp",
                  "whatsapp",
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: RefreshIndicator(
              onRefresh: loadRecentItems,
              child: filteredItems.isEmpty
                  ? const ModuleEmptyState(
                      icon: Icons.history,
                      title: "No Recent Items",
                      subtitle:
                          "Items you open will appear here.",
                    )
                  : ListView.builder(
                      itemCount:
                          filteredItems.length,
                      itemBuilder:
                          (context, index) {
                        final item =
                            filteredItems[index];

                        return Card(
                          margin:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading:
                                buildThumbnail(
                              item,
                            ),
                            title: Text(
                              item.title,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                            ),
                            subtitle: Text(
                              formatTime(
                                item.openedAt,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                            ),
                            onTap: () =>
                                openRecentItem(
                              item,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}