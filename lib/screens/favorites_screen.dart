import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/document.dart';
import '../models/note.dart';
import '../models/media_item.dart';
import '../repositories/media_repository.dart';
import '../repositories/document_repository.dart';
import '../repositories/note_repository.dart';
import '../widgets/media_thumbnail.dart';
import '../widgets/module_app_bar.dart';
import '../widgets/module_card.dart';
import '../widgets/module_empty_state.dart';
import '../widgets/module_popup_menu.dart';
import '../widgets/module_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/link_item.dart';
import '../repositories/link_repository.dart';
import '../models/whatsapp_chat.dart';
import '../repositories/whatsapp_repository.dart';
import 'whatsapp_chat_screen.dart';
import 'note_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() =>
      _FavoritesScreenState();
}

class _FavoritesScreenState
    extends State<FavoritesScreen> {
  final NoteRepository noteRepository =
      NoteRepository();

  final DocumentRepository documentRepository =
      DocumentRepository();
  
  final MediaRepository mediaRepository =
      MediaRepository();
      final LinkRepository linkRepository =
    LinkRepository();
    final WhatsappRepository whatsappRepository =
    WhatsappRepository();

  final TextEditingController searchController =
      TextEditingController();

  List<Note> notes = [];
  List<Document> documents = [];
List<MediaItem> media = [];
List<LinkItem> links = [];
List<WhatsappChat> chats = [];

List<Note> filteredNotes = [];
List<Document> filteredDocuments = [];
List<MediaItem> filteredMedia = [];
List<LinkItem> filteredLinks = [];
List<WhatsappChat> filteredChats = [];

  bool isSearching = false;
  bool selectionMode = false;

String selectedFilter = "All";

String currentSort = "Newest";

  final Set<String> selectedItems = {};

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadFavorites() async {
    final favoriteNotes =
        await noteRepository.getFavoriteNotes();

    final favoriteDocuments =
        await documentRepository
            .getFavoriteDocuments();
    
    final favoriteMedia =
    await mediaRepository.getFavoriteMedia();

final favoriteLinks =
    await linkRepository.getFavoriteLinks();

final favoriteChats =
    await whatsappRepository.getFavoriteChats();

    if (!mounted) return;

    setState(() {
      notes = favoriteNotes;
      documents = favoriteDocuments;
      media = favoriteMedia;
      links = favoriteLinks;
      chats = favoriteChats;
      filteredNotes =
          List.from(favoriteNotes);

      filteredDocuments =
          List.from(favoriteDocuments);
      filteredMedia =
    List.from(favoriteMedia);
    filteredLinks =
    List.from(favoriteLinks);
    filteredChats =
    List.from(favoriteChats);
    });

    sortItems(currentSort);
  }

  void searchItems(String query) {
    if (query.trim().isEmpty) {
  setState(() {
    filteredNotes = List.from(notes);

    filteredDocuments =
        List.from(documents);

    filteredMedia =
        List.from(media);
        filteredLinks =
    List.from(links);
    filteredChats =
    List.from(chats);
  });

  sortItems(currentSort);
  return;
}

    setState(() {
      filteredNotes = notes.where((note) {
        return note.title
                .toLowerCase()
                .contains(
                  query.toLowerCase(),
                ) ||
            note.content
                .toLowerCase()
                .contains(
                  query.toLowerCase(),
                );
      }).toList();

      filteredDocuments =
          documents.where((document) {
        return document.name
            .toLowerCase()
            .contains(
              query.toLowerCase(),
            );
      }).toList();
      filteredMedia =
    media.where((item) {
  return item.name
      .toLowerCase()
      .contains(
        query.toLowerCase(),
      );
}
).toList();
   filteredLinks =
    links.where((item) {
  return item.title
          .toLowerCase()
          .contains(
            query.toLowerCase(),
          ) ||
      item.url
          .toLowerCase()
          .contains(
            query.toLowerCase(),
          );
}).toList();
filteredChats =
    chats.where((chat) {
  return chat.title
      .toLowerCase()
      .contains(query.toLowerCase());
}).toList();
 });

    sortItems(currentSort);
  }

  void sortItems(String value) {
    currentSort = value;

    switch (value) {
      case "Newest":
        filteredNotes.sort(
          (a, b) =>
              b.id!.compareTo(a.id!),
        );

        filteredDocuments.sort(
          (a, b) =>
              b.id!.compareTo(a.id!),
        );
        filteredMedia.sort(
  (a, b) =>
      b.id!.compareTo(a.id!),
);
filteredLinks.sort(
  (a, b) =>
      b.id!.compareTo(a.id!),
);
filteredChats.sort(
  (a, b) =>
      b.id!.compareTo(a.id!),
);
        break;

      case "Oldest":
        filteredNotes.sort(
          (a, b) =>
              a.id!.compareTo(b.id!),
        );

        filteredDocuments.sort(
          (a, b) =>
              a.id!.compareTo(b.id!),
        );
        filteredMedia.sort(
  (a, b) =>
      a.id!.compareTo(b.id!),
);
filteredLinks.sort(
  (a, b) =>
      a.id!.compareTo(b.id!),
);
filteredChats.sort(
  (a, b) =>
      a.id!.compareTo(b.id!),
);
        break;

      case "A-Z":
        filteredNotes.sort(
          (a, b) => a.title
              .toLowerCase()
              .compareTo(
                b.title.toLowerCase(),
              ),
        );

        filteredDocuments.sort(
          (a, b) => a.name
              .toLowerCase()
              .compareTo(
                b.name.toLowerCase(),
              ),
        );
        filteredMedia.sort(
  (a, b) => a.name
      .toLowerCase()
      .compareTo(
        b.name.toLowerCase(),
      ),
);
filteredLinks.sort(
  (a, b) => a.title
      .toLowerCase()
      .compareTo(
        b.title.toLowerCase(),
      ),
);
filteredChats.sort(
  (a, b) => a.title
      .toLowerCase()
      .compareTo(
        b.title.toLowerCase(),
      ),
);
        break;

      case "Z-A":
        filteredNotes.sort(
          (a, b) => b.title
              .toLowerCase()
              .compareTo(
                a.title.toLowerCase(),
              ),
        );

        filteredDocuments.sort(
          (a, b) => b.name
              .toLowerCase()
              .compareTo(
                a.name.toLowerCase(),
              ),
        );
        filteredMedia.sort(
  (a, b) => b.name
      .toLowerCase()
      .compareTo(
        a.name.toLowerCase(),
      ),
);
filteredLinks.sort(
  (a, b) => b.title
      .toLowerCase()
      .compareTo(
        a.title.toLowerCase(),
      ),
);
filteredChats.sort(
  (a, b) => b.title
      .toLowerCase()
      .compareTo(
        a.title.toLowerCase(),
      ),
);
        break;
    }

    setState(() {});
  }

  String noteKey(Note note) =>
      "note_${note.id}";

  String documentKey(
    Document document,
  ) =>
      "document_${document.id}";
      String mediaKey(
        
  MediaItem item,
) =>
    "media_${item.id}";
    String linkKey(
  LinkItem link,
) =>
    "link_${link.id}";
    String chatKey(
  WhatsappChat chat,
) =>
    "chat_${chat.id}";

  bool isSelected(String key) =>
      selectedItems.contains(key);

  void startSelection(String key) {
    setState(() {
      selectionMode = true;
      selectedItems.add(key);
    });
  }

  void toggleSelection(String key) {
    setState(() {
      if (selectedItems.contains(key)) {
        selectedItems.remove(key);
      } else {
        selectedItems.add(key);
      }

      if (selectedItems.isEmpty) {
        selectionMode = false;
      }
    });
  }

  void closeSelection() {
    setState(() {
      selectionMode = false;
      selectedItems.clear();
    });
  }

  void selectAll() {
    setState(() {
      if (selectedItems.length ==
    filteredNotes.length +
    filteredDocuments.length +
    filteredMedia.length +
    filteredLinks.length) {
        selectedItems.clear();
        selectionMode = false;
        return;
      }

      selectedItems.clear();

      for (final note
          in filteredNotes) {
        selectedItems.add(
          noteKey(note),
        );
      }

      for (final document
          in filteredDocuments) {
        selectedItems.add(
          documentKey(document),
        );
      }
      for (final item
    in filteredMedia) {
  selectedItems.add(
    mediaKey(item),
  );
}
for (final link in filteredLinks) {
  selectedItems.add(
    linkKey(link),
  );
}
for (final chat in filteredChats) {
  selectedItems.add(
    chatKey(chat),
  );
}
      selectionMode = true;
    });
  }

  int get totalItems =>
  filteredNotes.length +
filteredDocuments.length +
filteredMedia.length +
filteredLinks.length +
filteredChats.length;  
    Future<void> toggleFavorite(dynamic item) async {
    if (item is Note) {
  await noteRepository.toggleFavorite(
    item.id!,
    !item.isFavorite,
  );
} else if (item is Document) {
  await documentRepository.toggleFavorite(
    item.id!,
    !item.isFavorite,
  );
} else if (item is MediaItem) {
  await mediaRepository.toggleFavorite(
    item.id!,
    !item.isFavorite,
  );
}
else if (item is LinkItem) {
  await linkRepository.toggleFavorite(
    item.id!,
    !item.isFavorite,
  );
} else if (item is WhatsappChat) {
  await whatsappRepository.toggleFavorite(
    item.id!,
    !item.isFavorite,
  );
}
    await loadFavorites();
  }

  Future<void> moveToRecycleBin(dynamic item) async {
    if (item is Note) {
  await noteRepository.moveToTrash(item.id!);
} else if (item is Document) {
  await documentRepository.moveToTrash(item.id!);
} else if (item is MediaItem) {
  await mediaRepository.moveToTrash(item.id!);
} else if (item is LinkItem) {
  await linkRepository.moveToTrash(item.id!);
} else if (item is WhatsappChat) {
  await whatsappRepository.moveToTrash(item.id!);
}

    await loadFavorites();

    if (!mounted) return;

    ModuleSnackBar.show(
      context,
      "Moved to Recycle Bin",
      actionLabel: "UNDO",
      onAction: () async {
        if (item is Note) {
  await noteRepository.restore(item.id!);
} else if (item is Document) {
  await documentRepository.restore(item.id!);
} else if (item is MediaItem) {
  await mediaRepository.restore(item.id!);
} else if (item is LinkItem) {
  await linkRepository.restore(item.id!);
} else if (item is WhatsappChat) {
  await whatsappRepository.restore(item.id!);
}

        await loadFavorites();
      },
    );
  }

  Future<void> renameNote(Note note) async {
    final controller = TextEditingController(
      text: note.title,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Rename Note"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Note title",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  controller.text.trim(),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) {
      return;
    }

    final updated = note.copy(
      title: result,
    );

    await noteRepository.updateNote(updated);

    await loadFavorites();

    if (!mounted) return;

    ModuleSnackBar.show(
      context,
      "Note renamed",
    );
  }

  Future<void> renameDocument(
    Document document,
  ) async {
    final controller = TextEditingController(
      text: document.name,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Rename Document"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Document name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  controller.text.trim(),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) {
      return;
    }

    final updated = document.copy(
      name: result,
    );

    await documentRepository.updateDocument(
      updated,
    );

    await loadFavorites();

    if (!mounted) return;

    ModuleSnackBar.show(
      context,
      "Document renamed",
    );
  }

  Future<void> showNoteInfo(
    Note note,
  ) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            "Note Information",
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text("Title: ${note.title}"),
              const SizedBox(height: 10),
              Text(
                "Content: ${note.content}",
              ),
              const SizedBox(height: 10),
              Text(
                "Favorite: ${note.isFavorite ? "Yes" : "No"}",
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Future<void> showDocumentInfo(
    Document document,
  ) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            "Document Information",
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text("Name: ${document.name}"),
              const SizedBox(height: 10),
              Text("Path: ${document.path}"),
              const SizedBox(height: 10),
              Text(
                "Favorite: ${document.isFavorite ? "Yes" : "No"}",
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }  Future<void> openNote(
    Note note,
  ) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteDetailsScreen(
          note: note,
        ),
      ),
    );

    if (updated == true) {
      await loadFavorites();
    }
  }

  Future<void> openDocument(
    Document document,
  ) async {
    await OpenFilex.open(
      document.path,
    );
  }

  Future<void> shareNote(
    Note note,
  ) async {
    await SharePlus.instance.share(
      ShareParams(
        text:
            "${note.title}\n\n${note.content}",
      ),
    );
  }

  Future<void> shareDocument(
  Document document,
) async {
  await SharePlus.instance.share(
    ShareParams(
      files: [
        XFile(document.path),
      ],
    ),
  );
}

Future<void> renameLink(
  LinkItem link,
) async {
  final controller = TextEditingController(
    text: link.title,
  );

  final result = await showDialog<String>(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Rename Link"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Link title",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                controller.text.trim(),
              );
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );

  if (result == null || result.isEmpty) return;

  await linkRepository.updateLink(
    link.copy(title: result),
  );

  await loadFavorites();

  if (!mounted) return;

  ModuleSnackBar.show(
    context,
    "Link renamed",
  );
}

Future<void> showLinkInfo(
  LinkItem link,
) async {
  await showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Link Information"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text("Title: ${link.title}"),
            const SizedBox(height: 10),
            Text("URL: ${link.url}"),
            const SizedBox(height: 10),
            Text(
              "Favorite: ${link.isFavorite ? "Yes" : "No"}",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}

Future<void> shareLink(
  LinkItem link,
) async {
  await SharePlus.instance.share(
    ShareParams(
      text: link.url,
    ),
  );
}

Future<void> openLink(
  LinkItem link,
) async {
  await launchUrl(
    Uri.parse(link.url),
    mode: LaunchMode.externalApplication,
  );
}
 Future<void> handleMenuAction(
  dynamic item,
  ModuleMenuAction action,
) async {
    switch (action) {
      case ModuleMenuAction.rename:
  if (item is Note) {
    await renameNote(item);
  } else if (item is Document) {
    await renameDocument(item);
  } else if (item is LinkItem) {
    await renameLink(item);
  }
  break;

      case ModuleMenuAction.info:
  if (item is Note) {
    await showNoteInfo(item);
  } else if (item is Document) {
    await showDocumentInfo(item);
  } else if (item is LinkItem) {
    await showLinkInfo(item);
  }
  break;

      case ModuleMenuAction.favorite:
        await toggleFavorite(item);
        break;

      case ModuleMenuAction.share:
  if (item is Note) {
    await shareNote(item);
  } else if (item is Document) {
    await shareDocument(item);
  } else if (item is LinkItem) {
    await shareLink(item);
  }
  break;

      case ModuleMenuAction.delete:
        await moveToRecycleBin(item);
        break;

      case ModuleMenuAction.restore:
        break;

      case ModuleMenuAction.deleteForever:
        break;
    }
  }

  Future<void> bulkFavorite() async {
    for (final key in selectedItems) {
      if (key.startsWith("note_")) {
        final id = int.parse(
          key.replaceFirst(
            "note_",
            "",
          ),
        );

        final note = notes.firstWhere(
          (e) => e.id == id,
        );

        await noteRepository.toggleFavorite(
          id,
          !note.isFavorite,
        );
      } else if (key.startsWith("document_")) {
  final id = int.parse(
    key.replaceFirst(
      "document_",
      "",
    ),
  );

  final document =
      documents.firstWhere(
    (e) => e.id == id,
  );

  await documentRepository.toggleFavorite(
    id,
    !document.isFavorite,
  );
} else if (key.startsWith("media_")) {
  final id = int.parse(
    key.replaceFirst(
      "media_",
      "",
    ),
  );

  final item = media.firstWhere(
    (e) => e.id == id,
  );

  await mediaRepository.toggleFavorite(
    id,
    !item.isFavorite,
  );
} else if (key.startsWith("link_")) {
  final id = int.parse(
    key.replaceFirst(
      "link_",
      "",
    ),
  );

  final link = links.firstWhere(
    (e) => e.id == id,
  );

  await linkRepository.toggleFavorite(
    id,
    !link.isFavorite,
  );
} else if (key.startsWith("chat_")) {
  final id = int.parse(
    key.replaceFirst(
      "chat_",
      "",
    ),
  );

  final chat = chats.firstWhere(
    (e) => e.id == id,
  );

  await whatsappRepository.toggleFavorite(
    id,
    !chat.isFavorite,
  );
}
    }

    closeSelection();

    await loadFavorites();
  }

  Future<void> bulkDelete() async {
    final deleted =
        List<String>.from(selectedItems);

    for (final key in deleted) {
      if (key.startsWith("note_")) {
        final id = int.parse(
          key.replaceFirst(
            "note_",
            "",
          ),
        );

        await noteRepository.moveToTrash(
          id,
        );
      } else if (key.startsWith("document_")) {
  final id = int.parse(
    key.replaceFirst(
      "document_",
      "",
    ),
  );

  await documentRepository.moveToTrash(id);

} else if (key.startsWith("media_")) {
  final id = int.parse(
    key.replaceFirst(
      "media_",
      "",
    ),
  );

  await mediaRepository.moveToTrash(id);

} else if (key.startsWith("link_")) {
  final id = int.parse(
    key.replaceFirst(
      "link_",
      "",
    ),
  );

  await linkRepository.moveToTrash(id);

} else if (key.startsWith("chat_")) {
  final id = int.parse(
    key.replaceFirst(
      "chat_",
      "",
    ),
  );

  await whatsappRepository.moveToTrash(id);
}
    }

    closeSelection();

    await loadFavorites();

    if (!mounted) return;

    ModuleSnackBar.show(
      context,
      "Moved to Recycle Bin",
      actionLabel: "UNDO",
      onAction: () async {
        for (final key in deleted) {
          if (key.startsWith("note_")) {
            final id = int.parse(
              key.replaceFirst(
                "note_",
                "",
              ),
            );

            await noteRepository.restore(
              id,
            );
          } else if (key.startsWith("document_")) {
  final id = int.parse(
    key.replaceFirst(
      "document_",
      "",
    ),
  );

  await documentRepository.restore(id);

} else if (key.startsWith("media_")) {
  final id = int.parse(
    key.replaceFirst(
      "media_",
      "",
    ),
  );

  await mediaRepository.restore(id);

} else if (key.startsWith("link_")) {
  final id = int.parse(
    key.replaceFirst(
      "link_",
      "",
    ),
  );

  await linkRepository.restore(id);

} else if (key.startsWith("chat_")) {
  final id = int.parse(
    key.replaceFirst(
      "chat_",
      "",
    ),
  );

  await whatsappRepository.restore(id);
}
        }

        await loadFavorites();
      },
    );
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModuleAppBar(
        title: "Favorites",
        totalItems: totalItems,
        selectionMode: selectionMode,
        selectedCount: selectedItems.length,
        isSearching: isSearching,
        searchController: searchController,
        onSearch: searchItems,

        onSearchToggle: () {
          setState(() {
            if (isSearching) {
              searchController.clear();
              searchItems("");
            }

            isSearching = !isSearching;
          });
        },

        onSort: sortItems,

        onSelectAll: selectAll,

        onFavorite: bulkFavorite,

        onDelete: bulkDelete,

        onCloseSelection: closeSelection,
      ),

      body: totalItems == 0
          ? const ModuleEmptyState(
              icon: Icons.favorite_border,
              title: "No Favorites Yet",
              subtitle:
                  "Favorite notes or documents to see them here.",
            )
          : Column(
    children: [
      SizedBox(
  height: 46,
  child: ListView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    children: [
      "All",
      "Notes",
      "Documents",
      "Media",
      "WhatsApp",
      "Links",
    ].map((filter) {
      final isSelected = selectedFilter == filter;

      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: ChoiceChip(
          label: Text(filter),
          selected: isSelected,
          showCheckmark: false,
          selectedColor: Colors.amber,
          backgroundColor: Colors.grey.shade200,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          onSelected: (_) {
            setState(() {
              selectedFilter = filter;
            });
          },
        ),
      );
    }).toList(),
  ),
),

      const SizedBox(height: 12),

      Expanded(
        child: ListView(
              padding: const EdgeInsets.all(12),
              children: [                
                if ((selectedFilter == "All" ||
        selectedFilter == "Notes") &&
    filteredNotes.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: Text(
  "Notes (${filteredNotes.length})",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  ...filteredNotes.map(
                    (note) {
                      final key = noteKey(note);

                      return ModuleCard(
                        thumbnail: const Icon(
                          Icons.note,
                          color: Colors.orange,
                          size: 36,
                        ),

                        title: note.title,

                        subtitle: note.content,

                        isSelected:
                            isSelected(key),

                        selectionMode:
                            selectionMode,

                        isFavorite:
                            note.isFavorite,

                        onTap: () async {
                          if (selectionMode) {
                            toggleSelection(
                              key,
                            );
                            return;
                          }

                          await openNote(
                            note,
                          );
                        },

                        onLongPress: () {
                          startSelection(
                            key,
                          );
                        },

                        onChecked: (_) {
                          toggleSelection(
                            key,
                          );
                        },

                        onMenuSelected:
                            (action) async {
                          await handleMenuAction(
                            note,
                            action,
                          );
                        },
                      );
                    },
                  ),
                ],                
                if ((selectedFilter == "All" ||
        selectedFilter == "Documents") &&
    filteredDocuments.isNotEmpty) ...[
                  const SizedBox(height: 32),

                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: Text(
  "Documents (${filteredDocuments.length})",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  ...filteredDocuments.map(
                    (document) {
                      final key =
                          documentKey(document);

                      return ModuleCard(
                        thumbnail: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                          size: 36,
                        ),

                        title: document.name,

                        subtitle: File(document.path).uri.pathSegments.last,

                        isSelected:
                            isSelected(key),

                        selectionMode:
                            selectionMode,

                        isFavorite:
                            document.isFavorite,

                        onTap: () async {
                          if (selectionMode) {
                            toggleSelection(
                              key,
                            );
                            return;
                          }

                          await openDocument(
                            document,
                          );
                        },

                        onLongPress: () {
                          startSelection(
                            key,
                          );
                        },

                        onChecked: (_) {
                          toggleSelection(
                            key,
                          );
                        },

                        onMenuSelected:
                            (action) async {
                          await handleMenuAction(
                            document,
                            action,
                          );
                        },
                      );
                    },
                  ),              
                  ],
                  if ((selectedFilter == "All" ||
        selectedFilter == "Media") &&
    filteredMedia.isNotEmpty) ...[
  const SizedBox(height: 32),
  Padding(
    padding: EdgeInsets.only(bottom: 12),
    child: Text(
  "Media (${filteredMedia.length})",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  ...filteredMedia.map((item) {
    final key = mediaKey(item);
    return ModuleCard(
      thumbnail: MediaThumbnail(
  item: item,
),
      title: item.name,
      subtitle: File(item.path).uri.pathSegments.last,
      isSelected: isSelected(key),
      selectionMode: selectionMode,
      isFavorite: item.isFavorite,
      onTap: () async {
        if (selectionMode) {
          toggleSelection(key);
          return;
        }
        await OpenFilex.open(item.path);
      },
      onLongPress: () {
        startSelection(key);
      },
      onChecked: (_) {
        toggleSelection(key);
      },
      onMenuSelected: (action) async {
  await handleMenuAction(
    item,
    action,
  );
},
    );
  }),
],
if ((selectedFilter == "All" ||
        selectedFilter == "Links") &&
    filteredLinks.isNotEmpty) ...[
  const SizedBox(height: 32),
  Padding(
    padding: EdgeInsets.only(bottom: 12),
    child: Text(
  "Links (${filteredLinks.length})",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  ...filteredLinks.map((link) {
    final key = linkKey(link);
    return ModuleCard(
      thumbnail: const Icon(
        Icons.link,
        color: Colors.blue,
        size: 36,
      ),
      title: link.title,
      subtitle: link.url,
      isSelected: isSelected(key),
      selectionMode: selectionMode,
      isFavorite: link.isFavorite,
      onTap: () async {
        if (selectionMode) {
          toggleSelection(key);
          return;
        }
        await openLink(link);
      },
      onLongPress: () {
        startSelection(key);
      },
      onChecked: (_) {
        toggleSelection(key);
      },
      onMenuSelected: (action) async {
        await handleMenuAction(
          link,
          action,
        );
      },
    );
  }),
],
if ((selectedFilter == "All" ||
        selectedFilter == "WhatsApp") &&
    filteredChats.isNotEmpty) ...[
  const SizedBox(height: 32),
  Padding(
    padding: EdgeInsets.only(bottom: 12),
    child: Text(
  "WhatsApp (${filteredChats.length})",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),

  ...filteredChats.map((chat) {
    final key = chatKey(chat);

    return ModuleCard(
      thumbnail: const Icon(
        Icons.chat,
        color: Colors.green,
        size: 36,
      ),

      title: chat.title,
      subtitle: "WhatsApp Chat",

      isSelected: isSelected(key),
      selectionMode: selectionMode,
      isFavorite: chat.isFavorite,

      onTap: () async {
        if (selectionMode) {
          toggleSelection(key);
          return;
        }

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WhatsappChatScreen(
              chat: chat,
            ),
          ),
        );

        await loadFavorites();
      },

      onLongPress: () {
        startSelection(key);
      },

      onChecked: (_) {
        toggleSelection(key);
      },

      onMenuSelected: (action) async {
        await handleMenuAction(
          chat,
          action,
        );
      },
    );
  }),
],

                  ],
        ),
      ),
    ],
),
    );
  }
}