import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/link_item.dart';
import '../repositories/link_repository.dart';
import '../widgets/module_app_bar.dart';
import '../widgets/module_card.dart';
import '../widgets/module_empty_state.dart';
import '../widgets/module_popup_menu.dart';
import '../widgets/module_snackbar.dart';

class LinksScreen extends StatefulWidget {
  const LinksScreen({
    super.key,
  });

  @override
  State<LinksScreen> createState() =>
      _LinksScreenState();
}

class _LinksScreenState
    extends State<LinksScreen> {

  final LinkRepository repository =
      LinkRepository();

  final TextEditingController searchController =
      TextEditingController();

  List<LinkItem> links = [];
  List<LinkItem> filteredLinks = [];

  bool isSearching = false;

  bool selectionMode = false;

  String currentSort = "Newest";

  Set<int> selectedLinks = {};

  @override
  void initState() {
    super.initState();
    loadLinks();
  }

  Future<void> loadLinks() async {
  final data = await repository.getLinks();

  print("TOTAL LINKS: ${data.length}");

  if (!mounted) return;

  setState(() {
    links = data;
    filteredLinks = data;
  });
}

  void searchLinks(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        filteredLinks = links;
      } else {
        filteredLinks = links.where((link) {
          return link.title
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              link.url
                  .toLowerCase()
                  .contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void sortLinks(String value) {
    currentSort = value;

    switch (value) {
      case "Newest":
        filteredLinks.sort(
          (a, b) =>
              b.id!.compareTo(a.id!),
        );
        break;

      case "Oldest":
        filteredLinks.sort(
          (a, b) =>
              a.id!.compareTo(b.id!),
        );
        break;

      case "A-Z":
        filteredLinks.sort(
          (a, b) => a.title
              .toLowerCase()
              .compareTo(
                b.title.toLowerCase(),
              ),
        );
        break;

      case "Z-A":
        filteredLinks.sort(
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
  Future<void> addLink() async {
  final titleController = TextEditingController();
  final urlController = TextEditingController();

  final result = await showDialog<bool>(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Add Link"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: "URL",
                hintText: "https://example.com",
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text("Save"),
          ),
        ],
      );
    },
  );

  print("RESULT = $result");

if (result != true) return;

  final title = titleController.text.trim();
  final url = urlController.text.trim();
print("TITLE = $title");
print("URL = $url");
  if (title.isEmpty || url.isEmpty) {
    if (!mounted) return;

    ModuleSnackBar.show(
      context,
      "Please fill all fields",
    );
    return;
  }
print("ADDING LINK...");
print("LINK ADDED");
  await repository.addLink(
    LinkItem(
      title: title,
      url: url,
    ),
  );

  await loadLinks();

  if (!mounted) return;

  ModuleSnackBar.show(
    context,
    "Link added successfully",
  );
}

Future<void> renameLink(
    LinkItem link) async {
  final controller =
      TextEditingController(
    text: link.title,
  );

  final result =
      await showDialog<String>(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Rename Link"),
        content: TextField(
          controller: controller,
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

  if (result == null ||
      result.trim().isEmpty) {
    return;
  }

  await repository.updateLink(
    link.copy(
      title: result,
    ),
  );

  await loadLinks();

  if (!mounted) return;

  ModuleSnackBar.show(
    context,
    "Link renamed successfully",
  );
}

Future<void> toggleFavorite(
    LinkItem link) async {
  await repository.toggleFavorite(
    link.id!,
    !link.isFavorite,
  );

  await loadLinks();
}

Future<void> moveToRecycleBin(
    LinkItem link) async {
  await repository.moveToTrash(
    link.id!,
  );

  await loadLinks();

  if (!mounted) return;

  ModuleSnackBar.show(
    context,
    "Link moved to Recycle Bin",
    actionLabel: "UNDO",
    onAction: () async {
      await repository.restore(
        link.id!,
      );

      await loadLinks();
    },
  );
}

Future<void> openLink(
    LinkItem link) async {
  Uri uri = Uri.parse(link.url);

  if (!await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  )) {
    if (!mounted) return;

    ModuleSnackBar.show(
      context,
      "Unable to open link",
    );
  }
}

Future<void> shareLink(
    LinkItem link) async {
  await SharePlus.instance.share(
    ShareParams(
      text: link.url,
    ),
  );
}

Future<void> showLinkInfo(
    LinkItem link) async {
  await showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text(
          "Link Information",
        ),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              link.title,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(link.url),
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
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: ModuleAppBar(
      title: "Links",
      totalItems: links.length,
      selectionMode: selectionMode,
      selectedCount: selectedLinks.length,
      isSearching: isSearching,
      searchController: searchController,
      onSearch: searchLinks,
      onSearchToggle: () {
        setState(() {
          if (isSearching) {
            searchController.clear();
            searchLinks("");
          }

          isSearching = !isSearching;
        });
      },
      onSort: sortLinks,
      onSelectAll: () {
        setState(() {
          if (selectedLinks.length ==
              filteredLinks.length) {
            selectedLinks.clear();
          } else {
            selectedLinks = filteredLinks
                .map((e) => e.id!)
                .toSet();
          }

          selectionMode =
              selectedLinks.isNotEmpty;
        });
      },
      onFavorite: () async {
        for (final id in selectedLinks) {
          final link = links.firstWhere(
            (e) => e.id == id,
          );

          await repository.toggleFavorite(
            id,
            !link.isFavorite,
          );
        }

        await loadLinks();
      },
      onDelete: () async {
        final deletedIds =
            selectedLinks.toList();

        for (final id in deletedIds) {
          await repository.moveToTrash(id);
        }

        setState(() {
          selectedLinks.clear();
          selectionMode = false;
        });

        await loadLinks();

        if (!mounted) return;

        ModuleSnackBar.show(
          context,
          deletedIds.length == 1
              ? "1 link moved to Recycle Bin"
              : "${deletedIds.length} links moved to Recycle Bin",
          actionLabel: "UNDO",
          onAction: () async {
            for (final id in deletedIds) {
              await repository.restore(id);
            }

            await loadLinks();
          },
        );
      },
      onCloseSelection: () {
        setState(() {
          selectionMode = false;
          selectedLinks.clear();
        });
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: addLink,
      child: const Icon(Icons.add),
    ),
    body: RefreshIndicator(
      onRefresh: loadLinks,
      child: filteredLinks.isEmpty
          ? const ModuleEmptyState(
              icon: Icons.link,
              title: "No Links Yet",
              subtitle:
                  "Tap the + button to save your first link.",
            )
          : ListView.builder(
              itemCount: filteredLinks.length,
              itemBuilder: (context, index) {
                final link =
                    filteredLinks[index];
                                    return ModuleCard(
                  thumbnail: const Icon(
                    Icons.link,
                    size: 40,
                    color: Colors.blue,
                  ),

                  title: link.title,

                  subtitle: link.url,

                  isSelected:
                      selectedLinks.contains(
                    link.id,
                  ),

                  selectionMode:
                      selectionMode,

                  isFavorite:
                      link.isFavorite,

                  onTap: () async {
                    if (selectionMode) {
                      setState(() {
                        if (selectedLinks
                            .contains(
                                link.id)) {
                          selectedLinks.remove(
                              link.id);

                          if (selectedLinks
                              .isEmpty) {
                            selectionMode =
                                false;
                          }
                        } else {
                          selectedLinks.add(
                              link.id!);
                        }
                      });

                      return;
                    }

                    await openLink(link);
                  },

                  onLongPress: () {
                    setState(() {
                      selectionMode = true;
                      selectedLinks
                          .add(link.id!);
                    });
                  },

                  onChecked: (_) {
                    setState(() {
                      if (selectedLinks
                          .contains(
                              link.id)) {
                        selectedLinks.remove(
                            link.id);

                        if (selectedLinks
                            .isEmpty) {
                          selectionMode =
                              false;
                        }
                      } else {
                        selectedLinks
                            .add(link.id!);
                      }
                    });
                  },

                  onMenuSelected:
                      (action) async {
                    switch (action) {
                      case ModuleMenuAction
                          .rename:
                        await renameLink(
                            link);
                        break;

                      case ModuleMenuAction
                          .favorite:
                        await toggleFavorite(
                            link);
                        break;

                      case ModuleMenuAction
                          .share:
                        await shareLink(
                            link);
                        break;

                      case ModuleMenuAction
                          .info:
                        await showLinkInfo(
                            link);
                        break;

                      case ModuleMenuAction
                          .delete:
                        await moveToRecycleBin(
                            link);
                        break;

                      case ModuleMenuAction
                          .restore:
                        break;

                      case ModuleMenuAction
                          .deleteForever:
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