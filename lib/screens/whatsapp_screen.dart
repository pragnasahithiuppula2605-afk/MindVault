import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/whatsapp_chat.dart';
import '../repositories/whatsapp_repository.dart';
import '../utils/whatsapp_parser.dart';
import '../widgets/module_app_bar.dart';
import '../widgets/module_card.dart';
import '../widgets/module_popup_menu.dart';
import '../widgets/module_snackbar.dart';
import '../widgets/module_empty_state.dart';
import 'whatsapp_chat_screen.dart';

class WhatsAppScreen extends StatefulWidget {
  const WhatsAppScreen({super.key});

  @override
  State<WhatsAppScreen> createState() => _WhatsAppScreenState();
}

class _WhatsAppScreenState extends State<WhatsAppScreen> {
  final WhatsappRepository repository = WhatsappRepository();

  List<WhatsappChat> chats = [];
  List<WhatsappChat> filteredChats = [];

  bool loading = true;

  final TextEditingController searchController =
      TextEditingController();

  bool isSearching = false;

  String currentSort = "Newest";

  bool selectionMode = false;

  Set<int> selectedChats = {};

  @override
  void initState() {
    super.initState();
    loadChats();
  }

  Future<void> loadChats() async {
    final data = await repository.getChats();

    if (!mounted) return;

    setState(() {
      chats = data;
filteredChats = data;
loading = false;
    });
  }
void searchChats(String query) {
  setState(() {
    if (query.isEmpty) {
      filteredChats = chats;
    } else {
      filteredChats = chats.where((chat) {
        return chat.title
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    }
  });
}
void sortChats(String sortType) {
  setState(() {
    currentSort = sortType;

    switch (sortType) {
      case "Newest":
        filteredChats.sort(
          (a, b) => b.id!.compareTo(a.id!),
        );
        break;

      case "Oldest":
        filteredChats.sort(
          (a, b) => a.id!.compareTo(b.id!),
        );
        break;

      case "A-Z":
        filteredChats.sort(
          (a, b) => a.title
              .toLowerCase()
              .compareTo(b.title.toLowerCase()),
        );
        break;

      case "Z-A":
        filteredChats.sort(
          (a, b) => b.title
              .toLowerCase()
              .compareTo(a.title.toLowerCase()),
        );
        break;
    }
  });
}
  Future<void> importChat() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result == null) return;

      final path = result.files.single.path;

      if (path == null) return;

      final parsed = await WhatsappParser.parseZip(
        File(path),
      );

      final chatId = await repository.addChat(
        parsed.chat,
      );

      final messages = parsed.messages
          .map(
            (e) => e.copyWith(
              chatId: chatId,
            ),
          )
          .toList();

      await repository.addMessages(messages);

      await loadChats();
sortChats(currentSort);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Chat imported successfully!",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }
@override
void dispose() {
  searchController.dispose();
  super.dispose();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModuleAppBar(
  title: "WhatsApp",
  totalItems: chats.length,

  selectionMode: selectionMode,
  selectedCount: selectedChats.length,

  isSearching: isSearching,
  searchController: searchController,

  onSearch: searchChats,

  onSearchToggle: () {
    setState(() {
      if (isSearching) {
        searchController.clear();
        searchChats("");
      }

      isSearching = !isSearching;
    });
  },

  onSort: sortChats,

  onSelectAll: () {
    final allSelected = filteredChats.every(
      (e) => selectedChats.contains(e.id),
    );

    setState(() {
      if (allSelected) {
        selectedChats.clear();
      } else {
        selectedChats = filteredChats
            .map((e) => e.id!)
            .toSet();
      }
    });
  },

  onFavorite: () async {
    for (final id in selectedChats) {
      final chat = chats.firstWhere(
        (e) => e.id == id,
      );

      await repository.toggleFavorite(
        id,
        !chat.isFavorite,
      );
    }

    selectedChats.clear();
    selectionMode = false;

    await loadChats();
  },

  onDelete: () async {
    final deletedIds = selectedChats.toList();

    for (final id in deletedIds) {
      await repository.moveToTrash(id);
    }

    setState(() {
      selectedChats.clear();
      selectionMode = false;
    });

    await loadChats();

    if (!mounted) return;

    ModuleSnackBar.show(
      context,
      deletedIds.length == 1
          ? "1 chat moved to Recycle Bin"
          : "${deletedIds.length} chats moved to Recycle Bin",
    );
  },

  onCloseSelection: () {
    setState(() {
      selectionMode = false;
      selectedChats.clear();
    });
  },
),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: importChat,
        icon: const Icon(Icons.upload_file),
        label: const Text("Import Chat"),
      ),
      body: RefreshIndicator(
  onRefresh: loadChats,
  child: loading
      ? const Center(
          child: CircularProgressIndicator(),
        )
      : filteredChats.isEmpty
          ? const ModuleEmptyState(
              icon: Icons.chat,
              title: "No Chats Imported Yet",
              subtitle: "Tap 'Import Chat' to import a WhatsApp chat.",
            )
          : ListView.separated(
              itemCount: filteredChats.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1),
              itemBuilder: (context, index) {
                final chat = filteredChats[index];

                return ModuleCard(
                  thumbnail: const CircleAvatar(
                    child: Icon(Icons.chat),
                  ),
                  title: chat.title,
                  subtitle: chat.createdAt,
                  isSelected: selectedChats.contains(chat.id),
                  selectionMode: selectionMode,
                  isFavorite: chat.isFavorite,

                  onTap: () async {
                    if (selectionMode) {
                      setState(() {
                        if (selectedChats.contains(chat.id)) {
                          selectedChats.remove(chat.id);

                          if (selectedChats.isEmpty) {
                            selectionMode = false;
                          }
                        } else {
                          selectedChats.add(chat.id!);
                        }
                      });
                      return;
                    }

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WhatsappChatScreen(chat: chat),
                      ),
                    );

                    await loadChats();
                  },

                  onLongPress: () {
                    setState(() {
                      selectionMode = true;
                      selectedChats.add(chat.id!);
                    });
                  },

                  onChecked: (_) {
                    setState(() {
                      if (selectedChats.contains(chat.id)) {
                        selectedChats.remove(chat.id);

                        if (selectedChats.isEmpty) {
                          selectionMode = false;
                        }
                      } else {
                        selectedChats.add(chat.id!);
                      }
                    });
                  },

                  onMenuSelected: (action) async {
                    switch (action) {
                      case ModuleMenuAction.favorite:
                        await repository.toggleFavorite(
                          chat.id!,
                          !chat.isFavorite,
                        );
                        await loadChats();
                        break;

                      case ModuleMenuAction.delete:
                        await repository.moveToTrash(chat.id!);

                        await loadChats();

                        if (!mounted) return;

                        ModuleSnackBar.show(
                          context,
                          "Chat moved to Recycle Bin",
                          actionLabel: "UNDO",
                          onAction: () async {
                            await repository.restore(chat.id!);
                            await loadChats();
                          },
                        );
                        break;

                      default:
                        break;
                    }
                  },
                );
              },
            ),
),
    );
  }
}