import 'package:flutter/material.dart';

import '../models/note.dart';
import '../repositories/note_repository.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/module_snackbar.dart';
import '../widgets/module_empty_state.dart';
import '../widgets/module_card.dart';
import '../widgets/module_popup_menu.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/module_app_bar.dart';

import 'note_details_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() =>
      _NotesScreenState();
}

class _NotesScreenState
    extends State<NotesScreen> {
  final NoteRepository repository =
      NoteRepository();

  List<Note> notes = [];
  List<Note> filteredNotes = [];

  final TextEditingController searchController =
      TextEditingController();

  bool isSearching = false;
  String currentSort = "Newest";

  bool selectionMode = false;

  Set<int> selectedNotes = {};

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadNotes() async {
    final data = await repository.getNotes();

    setState(() {
      notes = data;
      filteredNotes = data;
    });
  }

  void searchNotes(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredNotes = notes;
      } else {
        filteredNotes = notes.where((note) {
          return note.title
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              note.content
                  .toLowerCase()
                  .contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void sortNotes(String sortType) {
    setState(() {
      currentSort = sortType;

      switch (sortType) {
        case "Newest":
          filteredNotes.sort(
            (a, b) =>
                b.id!.compareTo(a.id!),
          );
          break;

        case "Oldest":
          filteredNotes.sort(
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
          break;

        case "Z-A":
          filteredNotes.sort(
            (a, b) => b.title
                .toLowerCase()
                .compareTo(
                  a.title.toLowerCase(),
                ),
          );
          break;
      }
    });
  }  Future<void> toggleFavorite(Note note) async {
    await repository.toggleFavorite(
      note.id!,
      !note.isFavorite,
    );

    await loadNotes();
  }

  Future<void> moveToRecycleBin(Note note) async {

  await repository.moveToTrash(
    note.id!,
  );

  await loadNotes();

  if (!mounted) return;

  ModuleSnackBar.show(
    context,
    "Note moved to Recycle Bin",
    actionLabel: "UNDO",
    onAction: () async {
      await repository.restore(
        note.id!,
      );

      await loadNotes();
    },
  );
}

  Future<void> renameNote(Note note) async {
    final controller = TextEditingController(
      text: note.title,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
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

    if (result == null || result.isEmpty) return;

    final updated = note.copy(
      title: result,
    );

    await repository.updateNote(updated);

    await loadNotes();

    if (!mounted) return;

    ModuleSnackBar.show(
  context,
  "Note renamed",
);
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: ModuleAppBar(
  title: "Notes",
  totalItems: notes.length,
  selectionMode: selectionMode,
  selectedCount: selectedNotes.length,
  isSearching: isSearching,
  searchController: searchController,
  onSearch: searchNotes,

  onSearchToggle: () {
    setState(() {
      if (isSearching) {
        searchController.clear();
        searchNotes("");
      }

      isSearching = !isSearching;
    });
  },

  onSort: sortNotes,

  onSelectAll: () {
    final allSelected =
        filteredNotes.every(
      (e) => selectedNotes.contains(e.id),
    );

    setState(() {
      if (allSelected) {
        selectedNotes.clear();
      } else {
        selectedNotes =
            filteredNotes
                .map((e) => e.id!)
                .toSet();
      }
    });
  },

  onFavorite: () async {
    for (final id in selectedNotes) {
      final note = notes.firstWhere(
        (e) => e.id == id,
      );

      await repository.toggleFavorite(
        id,
        !note.isFavorite,
      );
    }

    selectedNotes.clear();
    selectionMode = false;

    await loadNotes();
  },

  onDelete: () async {
  final List<int> deletedIds =
      selectedNotes.toList();

  for (final id in deletedIds) {
    await repository.moveToTrash(id);
  }

  setState(() {
    selectedNotes.clear();
    selectionMode = false;
  });

  await loadNotes();

  if (!mounted) return;

  ModuleSnackBar.show(
    context,
    deletedIds.length == 1
        ? "1 note moved to Recycle Bin"
        : "${deletedIds.length} notes moved to Recycle Bin",
    actionLabel: "UNDO",
    onAction: () async {
      for (final id in deletedIds) {
        await repository.restore(id);
      }

      await loadNotes();
    },
  );
},

  onCloseSelection: () {
    setState(() {
      selectionMode = false;
      selectedNotes.clear();
    });
  },
),        floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final updated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoteDetailsScreen(),
            ),
          );

          if (updated == true) {
            await loadNotes();
          }
        },
        child: const Icon(Icons.add),
      ),

      body: filteredNotes.isEmpty
          ? const ModuleEmptyState(
  icon: Icons.note_alt_outlined,
  title: "No Notes Yet",
  subtitle: "Tap the + button to create a note.",
)
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];

              return ModuleCard(
  thumbnail: const Icon(
    Icons.note,
    color: Colors.orange,
    size: 36,
  ),

  title: note.title,

  subtitle: note.content,

  isSelected: selectedNotes.contains(note.id),

  selectionMode: selectionMode,

  isFavorite: note.isFavorite,

  onTap: () async {
    if (selectionMode) {
      setState(() {
        if (selectedNotes.contains(note.id)) {
          selectedNotes.remove(note.id);

          if (selectedNotes.isEmpty) {
            selectionMode = false;
          }
        } else {
          selectedNotes.add(note.id!);
        }
      });

      return;
    }

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteDetailsScreen(
          note: note,
        ),
      ),
    );

    if (updated == true) {
      await loadNotes();
    }
  },

  onLongPress: () {
    setState(() {
      selectionMode = true;
      selectedNotes.add(note.id!);
    });
  },

  onChecked: (_) {
    setState(() {
      if (selectedNotes.contains(note.id)) {
        selectedNotes.remove(note.id);

        if (selectedNotes.isEmpty) {
          selectionMode = false;
        }
      } else {
        selectedNotes.add(note.id!);
      }
    });
  },

  onMenuSelected: (action) async {
    switch (action) {
      case ModuleMenuAction.rename:
        await renameNote(note);
        break;

      case ModuleMenuAction.info:
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Note Information"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text("Title: ${note.title}"),
                const SizedBox(height: 10),
                Text("Content: ${note.content}"),
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
          ),
        );
        break;

      case ModuleMenuAction.favorite:
        await toggleFavorite(note);
        break;
        case ModuleMenuAction.share:
  await SharePlus.instance.share(
    ShareParams(
      text:
          "${note.title}\n\n${note.content}",
    ),
  );
  break;

      case ModuleMenuAction.delete:
        await moveToRecycleBin(note);
        break;

      case ModuleMenuAction.restore:
        break;

      case ModuleMenuAction.deleteForever:
        break;
    }
  },
);  
              },
            ),
    );
  }
}