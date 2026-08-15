import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../widgets/pdf_thumbnail.dart';
import '../models/document.dart';
import '../repositories/document_repository.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/module_app_bar.dart';
import '../widgets/module_card.dart';
import '../widgets/module_empty_state.dart';
import '../widgets/module_popup_menu.dart';
import '../widgets/module_snackbar.dart';
import '../repositories/recent_repository.dart';
class DocumentsScreen extends StatefulWidget {
  final bool autoPick;

  const DocumentsScreen({
    super.key,
    this.autoPick = false,
  });

  @override
  State<DocumentsScreen> createState() =>
      _DocumentsScreenState();
}

class _DocumentsScreenState
    extends State<DocumentsScreen> {

  final DocumentRepository repository =
      DocumentRepository();

  final TextEditingController searchController =
      TextEditingController();

  List<Document> documents = [];
  List<Document> filteredDocuments = [];

  bool isSearching = false;

  bool selectionMode = false;

  String currentSort = "Newest";

  Set<int> selectedDocuments = {};

  @override
  void initState() {
    super.initState();

    loadDocuments();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (widget.autoPick) {
        pickPDF();
      }
    });
  }

  Future<void> loadDocuments() async {
    final data =
        await repository.getDocuments();

    if (!mounted) return;

    setState(() {
      documents = data;
      filteredDocuments = data;
    });
  }

  void searchDocuments(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        filteredDocuments = documents;
      } else {
        filteredDocuments = documents.where((doc) {
          return doc.name
              .toLowerCase()
              .contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void sortDocuments(String value) {
    currentSort = value;

    switch (value) {
      case "Newest":
        filteredDocuments.sort(
          (a, b) =>
              b.id!.compareTo(a.id!),
        );
        break;

      case "Oldest":
        filteredDocuments.sort(
          (a, b) =>
              a.id!.compareTo(b.id!),
        );
        break;

      case "A-Z":
        filteredDocuments.sort(
          (a, b) => a.name
              .toLowerCase()
              .compareTo(
                b.name.toLowerCase(),
              ),
        );
        break;

      case "Z-A":
        filteredDocuments.sort(
          (a, b) => b.name
              .toLowerCase()
              .compareTo(
                a.name.toLowerCase(),
              ),
        );
        break;
    }

    setState(() {});
  }

  Future<void> pickPDF() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ["pdf"],
    );

    if (result == null) return;

  for (final file in result.files) {
  if (file.path == null) continue;

  await repository.addDocument(
    Document(
      name: file.name,
      path: file.path!,
    ),
  );
}

    await loadDocuments();

    if (!mounted) return;

    ModuleSnackBar.show(
      context,
      result.files.length == 1
          ? "1 document added successfully"
          : "${result.files.length} documents added successfully",
    );
  }

  Future<void> renameDocument(
      Document document) async {

    final controller =
        TextEditingController(
      text: document.name,
    );

    final result =
        await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title:
              const Text("Rename Document"),
          content: TextField(
            controller: controller,
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child:
                  const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  controller.text.trim(),
                );
              },
              child:
                  const Text("Save"),
            ),
          ],
        );
      },
    );

    if (result == null ||
        result.trim().isEmpty) {
      return;
    }

    await repository.updateDocument(
      document.copy(
        name: result,
      ),
    );

    await loadDocuments();

    if (!mounted) return;

    ModuleSnackBar.show(
      context,
      "Document renamed successfully",
    );
  }

  Future<void> toggleFavorite(
      Document document) async {

    await repository.toggleFavorite(
      document.id!,
      !document.isFavorite,
    );

    await loadDocuments();
  }
  Future<void> moveToRecycleBin(
    Document document) async {

  await repository.moveToTrash(
    document.id!,
  );

  await loadDocuments();

  if (!mounted) return;

  ModuleSnackBar.show(
    context,
    "Document moved to Recycle Bin",
    actionLabel: "UNDO",
    onAction: () async {
      await repository.restore(
        document.id!,
      );

      await loadDocuments();
    },
  );
}

  Future<void> showDocumentInfo(
      Document document) async {

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title:
              const Text("Document Information"),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                document.name,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Text(document.path),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child:
                  const Text("Close"),
            ),
          ],
        );
      },
    );
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModuleAppBar(
        title: "Documents",
        totalItems: documents.length,
        selectionMode: selectionMode,
        selectedCount: selectedDocuments.length,
        isSearching: isSearching,
        searchController: searchController,
        onSearch: searchDocuments,
        onSearchToggle: () {
          setState(() {
            if (isSearching) {
              searchController.clear();
              searchDocuments("");
            }

            isSearching = !isSearching;
          });
        },
        onSort: sortDocuments,
        onSelectAll: () {
          setState(() {
            if (selectedDocuments.length ==
                filteredDocuments.length) {
              selectedDocuments.clear();
            } else {
              selectedDocuments = filteredDocuments
                  .map((e) => e.id!)
                  .toSet();
            }

            selectionMode =
                selectedDocuments.isNotEmpty;
          });
        },
        onFavorite: () async {
          for (final id in selectedDocuments) {
            final document = documents.firstWhere(
              (e) => e.id == id,
            );

            await repository.toggleFavorite(
              id,
              !document.isFavorite,
            );
          }

          await loadDocuments();
        },
        onDelete: () async {
  final List<int> deletedIds =
      selectedDocuments.toList();

  for (final id in deletedIds) {
    await repository.moveToTrash(id);
  }

  setState(() {
    selectedDocuments.clear();
    selectionMode = false;
  });

  await loadDocuments();

  if (!mounted) return;

  ModuleSnackBar.show(
    context,
    deletedIds.length == 1
        ? "1 document moved to Recycle Bin"
        : "${deletedIds.length} documents moved to Recycle Bin",
    actionLabel: "UNDO",
    onAction: () async {
      for (final id in deletedIds) {
        await repository.restore(id);
      }

      await loadDocuments();
    },
  );
},
        onCloseSelection: () {
          setState(() {
            selectionMode = false;
            selectedDocuments.clear();
          });
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: pickPDF,
        child: const Icon(Icons.add),
      ),

      body: RefreshIndicator(
        onRefresh: loadDocuments,
        child: filteredDocuments.isEmpty
            ? const ModuleEmptyState(
                icon: Icons.picture_as_pdf,
                title: "No Documents Yet",
                subtitle:
                    "Tap the + button to add PDF documents.",
              )
            : ListView.builder(
                itemCount: filteredDocuments.length,
                itemBuilder: (context, index) {
                  final document =
                      filteredDocuments[index];

                  return ModuleCard(
                    thumbnail: PdfThumbnail(
  path: document.path,
),

                    title: document.name,

                    subtitle: "PDF Document",

                    isSelected:
                        selectedDocuments.contains(
                      document.id,
                    ),

                    selectionMode: selectionMode,

                    isFavorite:
                        document.isFavorite,

                    onTap: () async {
                      if (selectionMode) {
                        setState(() {
                          if (selectedDocuments
                              .contains(
                                  document.id)) {
                            selectedDocuments.remove(
                                document.id);

                            if (selectedDocuments
                                .isEmpty) {
                              selectionMode =
                                  false;
                            }
                          } else {
                            selectedDocuments.add(
                                document.id!);
                          }
                        });

                        return;
                      }

                      await RecentRepository().addRecent(
  itemId: document.id!,
  type: 'document',
);

final result =
    await OpenFilex.open(
  document.path,
);

                      if (result.type !=
                          ResultType.done) {
                        if (!mounted) return;

                        ModuleSnackBar.show(
                          context,
                          result.message,
                        );
                      }
                    },

                    onLongPress: () {
                      setState(() {
                        selectionMode = true;
                        selectedDocuments
                            .add(document.id!);
                      });
                    },

                    onChecked: (_) {
                      setState(() {
                        if (selectedDocuments
                            .contains(
                                document.id)) {
                          selectedDocuments.remove(
                              document.id);

                          if (selectedDocuments
                              .isEmpty) {
                            selectionMode =
                                false;
                          }
                        } else {
                          selectedDocuments.add(
                              document.id!);
                        }
                      });
                    },

                    onMenuSelected:
                        (action) async {
                      switch (action) {
                        case ModuleMenuAction
                            .rename:
                          await renameDocument(
                              document);
                          break;

                        case ModuleMenuAction
                            .info:
                          await showDocumentInfo(
                              document);
                          break;

                        case ModuleMenuAction
                            .favorite:
                          await toggleFavorite(
                              document);
                          break;
                          case ModuleMenuAction.share:
  await SharePlus.instance.share(
    ShareParams(
      files: [
        XFile(document.path),
      ],
    ),
  );
  break;

                        case ModuleMenuAction
                            .delete:
                          await moveToRecycleBin(
                              document);
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