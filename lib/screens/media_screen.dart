import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import '../models/media_item.dart';
import '../repositories/media_repository.dart';
import '../widgets/media_thumbnail.dart';
import '../widgets/module_app_bar.dart';
import '../widgets/module_card.dart';
import '../widgets/module_empty_state.dart';
import '../widgets/module_popup_menu.dart';
import '../widgets/module_snackbar.dart';
import 'package:get_video_thumbnail/get_video_thumbnail.dart';
import 'package:get_video_thumbnail/index.dart';
import 'package:path_provider/path_provider.dart';
import '../repositories/recent_repository.dart';

enum SortOption {
  newest,
  oldest,
  az,
  za,
}

enum MediaFilter {
  all,
  images,
  videos,
}

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() =>
      _MediaScreenState();
}

class _MediaScreenState
    extends State<MediaScreen> {
  final MediaRepository repository =
      MediaRepository();

  final ImagePicker picker =
      ImagePicker();

  final TextEditingController
      searchController =
      TextEditingController();

  List<MediaItem> media = [];
  List<MediaItem> filteredMedia = [];

  bool isSearching = false;
  bool selectionMode = false;

  Set<int> selectedMedia = {};

  SortOption currentSort =
      SortOption.newest;

  MediaFilter currentFilter =
      MediaFilter.all;

  @override
  void initState() {
    super.initState();
    loadMedia();
  }

  Future<void> loadMedia() async {
    media = await repository.getMedia();

    applyFilters();

    if (mounted) {
      setState(() {});
    }
  }

  void applyFilters() {
    filteredMedia =
        media.where((item) {
      if (searchController.text
          .trim()
          .isNotEmpty) {
        if (!item.name
            .toLowerCase()
            .contains(
              searchController.text
                  .toLowerCase(),
            )) {
          return false;
        }
      }

      switch (currentFilter) {
        case MediaFilter.all:
          return true;

        case MediaFilter.images:
          return item.isImage;

        case MediaFilter.videos:
          return item.isVideo;
      }
    }).toList();

    switch (currentSort) {
      case SortOption.newest:
        filteredMedia.sort(
          (a, b) =>
              b.id!.compareTo(a.id!),
        );
        break;

      case SortOption.oldest:
        filteredMedia.sort(
          (a, b) =>
              a.id!.compareTo(b.id!),
        );
        break;

      case SortOption.az:
        filteredMedia.sort(
          (a, b) => a.name
              .toLowerCase()
              .compareTo(
                b.name.toLowerCase(),
              ),
        );
        break;

      case SortOption.za:
        filteredMedia.sort(
          (a, b) => b.name
              .toLowerCase()
              .compareTo(
                a.name.toLowerCase(),
              ),
        );
        break;
    }
  }

  void toggleSelection(
      MediaItem item) {
    setState(() {
      if (selectedMedia
          .contains(item.id)) {
        selectedMedia.remove(
            item.id);
      } else {
        selectedMedia
            .add(item.id!);
      }

      if (selectedMedia
          .isEmpty) {
        selectionMode = false;
      }
    });
  }

  void clearSelection() {
    setState(() {
      selectedMedia.clear();
      selectionMode = false;
    });
  }
  Future<String?> _generateVideoThumbnail(
  String videoPath,
) async {
  try {
    final tempDir = await getTemporaryDirectory();

    final thumbnail = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: tempDir.path,
      imageFormat: ImageFormat.PNG,
      maxWidth: 300,
      maxHeight: 300,
      quality: 90,
    );

    print("Generated Thumbnail: ${thumbnail.path}");
return thumbnail.path;
  } catch (e) {
    print("Thumbnail Generation Error: $e");
    return null;
  }
}
   Future<void> pickImages() async {
  final files = await picker.pickMultiImage();

  if (files.isEmpty) return;

  for (final file in files) {
    await repository.addMedia(
      MediaItem(
        name: file.name,
        path: file.path,
        type: "image",
      ),
    );
  }

  await loadMedia();

  if (!mounted) return;

  ModuleSnackBar.show(
    context,
    files.length == 1
        ? "1 image added successfully"
        : "${files.length} images added successfully",
  );
} 

  Future<void> pickVideos() async {
    final result = await FilePicker.platform.pickFiles(
  allowMultiple: true,
  type: FileType.custom,
  allowedExtensions: ['mp4', 'mov', 'avi', 'mkv'],
);

    if (result == null) return;

    for (final file in result.files) {
      if (file.path == null) continue;

   print("VIDEO PATH: ${file.path}");

String? thumbnail;

try {
  thumbnail = await _generateVideoThumbnail(file.path!);
  print("THUMBNAIL: $thumbnail");
} catch (e) {
  print("Thumbnail Error: $e");
}   
await repository.addMedia(
  MediaItem(
    name: file.name,
    path: file.path!,
    type: "video",
    thumbnail: thumbnail,
  ),
);

print("VIDEO SAVED");
    }

    await loadMedia();

    if (!mounted) return;

    ModuleSnackBar.show(
      context,
      result.files.length == 1
          ? "1 video added successfully"
          : "${result.files.length} videos added successfully",
    );
  }

  Future<void> renameMedia(
    MediaItem item,
  ) async {
    final controller = TextEditingController(
      text: item.name,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Rename Media"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Media Name",
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

    await repository.renameMedia(
      item.id!,
      result,
    );

    await loadMedia();

    if (!mounted) return;

    ModuleSnackBar.show(
      context,
      "Media renamed successfully",
    );
  }

  Future<void> toggleFavorite(
    MediaItem item,
  ) async {
    await repository.toggleFavorite(
      item.id!,
      !item.isFavorite,
    );

    await loadMedia();
  }

  Future<void> moveToTrash(
  MediaItem item,
) async {

  await repository.moveToTrash(
    item.id!,
  );

  await loadMedia();

  if (!mounted) return;

  ModuleSnackBar.show(
    context,
    "Media moved to Recycle Bin",
    actionLabel: "UNDO",
    onAction: () async {
      await repository.restore(
        item.id!,
      );

      await loadMedia();
    },
  );
}

  Future<void> showMediaInfo(
    MediaItem item,
  ) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Media Information"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                "Name: ${item.name}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text("Type: ${item.type}"),
              const SizedBox(height: 10),
              Text("Path:\n${item.path}"),
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
        title: "Media",
        totalItems: media.length,
        selectionMode: selectionMode,
        selectedCount: selectedMedia.length,
        isSearching: isSearching,
        searchController: searchController,

        onSearch: (value) {
          applyFilters();
          setState(() {});
        },

        onSearchToggle: () {
          setState(() {
            isSearching = !isSearching;

            if (!isSearching) {
              searchController.clear();
              applyFilters();
            }
          });
        },

        onSort: (value) {
          switch (value) {
            case "Newest":
              currentSort = SortOption.newest;
              break;

            case "Oldest":
              currentSort = SortOption.oldest;
              break;

            case "A-Z":
              currentSort = SortOption.az;
              break;

            case "Z-A":
              currentSort = SortOption.za;
              break;
          }

          applyFilters();
          setState(() {});
        },

        onSelectAll: () {
          setState(() {
            if (selectedMedia.length ==
                filteredMedia.length) {
              selectedMedia.clear();
            } else {
              selectedMedia = filteredMedia
                  .map((e) => e.id!)
                  .toSet();
            }

            selectionMode =
                selectedMedia.isNotEmpty;
          });
        },

        onFavorite: () async {
          for (final item in filteredMedia) {
            if (selectedMedia.contains(item.id)) {
              await repository.toggleFavorite(
                item.id!,
                !item.isFavorite,
              );
            }
          }

          clearSelection();
          await loadMedia();
        },

        onDelete: () async {
  final List<int> deletedIds =
      selectedMedia.toList();

  for (final id in deletedIds) {
    await repository.moveToTrash(id);
  }

  clearSelection();

  await loadMedia();

  if (!mounted) return;

  ModuleSnackBar.show(
    context,
    deletedIds.length == 1
        ? "1 media item moved to Recycle Bin"
        : "${deletedIds.length} media items moved to Recycle Bin",
    actionLabel: "UNDO",
    onAction: () async {
      for (final id in deletedIds) {
        await repository.restore(id);
      }

      await loadMedia();
    },
  );
},

        onCloseSelection: clearSelection,
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return SafeArea(
                child: Wrap(
                  children: [

                    ListTile(
                      leading: const Icon(
                        Icons.image,
                      ),
                      title:
                          const Text("Add Images"),
                      onTap: () {
                        Navigator.pop(context);
                        pickImages();
                      },
                    ),

                    ListTile(
                      leading: const Icon(
                        Icons.video_library,
                      ),
                      title:
                          const Text("Add Videos"),
                      onTap: () {
                        Navigator.pop(context);
                        pickVideos();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
            body: RefreshIndicator(
        onRefresh: loadMedia,
        child: filteredMedia.isEmpty
            ? const ModuleEmptyState(
                icon: Icons.perm_media,
                title: "No Media Yet",
                subtitle:
                    "Tap + to add images or videos.",
              )
            : ListView.builder(
                itemCount: filteredMedia.length,
                itemBuilder: (context, index) {
                  final item = filteredMedia[index];

                  return ModuleCard(
                    thumbnail: MediaThumbnail(
  item: item,
),

                    title: item.name,

                    subtitle: item.isImage
                        ? "Image"
                        : "Video",

                    isSelected:
                        selectedMedia.contains(item.id),

                    selectionMode: selectionMode,

                    isFavorite: item.isFavorite,

                    onTap: () async {
  if (selectionMode) {
    toggleSelection(item);
    return;
  }

  await RecentRepository().addRecent(
  itemId: item.id!,
  type: 'media',
);

if (item.isImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(item.name),
          ),
          body: PhotoView(
            imageProvider: FileImage(
              File(item.path),
            ),
          ),
        ),
      ),
    );
  } else {
    final result =
        await OpenFilex.open(
      item.path,
    );

                        if (result.type !=
                            ResultType.done) {
                          if (!mounted) return;

                          ModuleSnackBar.show(
                            context,
                            result.message,
                          );
                        }
                      }
                    },

                    onLongPress: () {
                      setState(() {
                        selectionMode = true;
                        selectedMedia.add(
                          item.id!,
                        );
                      });
                    },

                    onChecked: (_) {
                      toggleSelection(item);
                    },

                    onMenuSelected:
                        (action) async {
                      switch (action) {
                        case ModuleMenuAction.rename:
                          await renameMedia(
                            item,
                          );
                          break;

                        case ModuleMenuAction.info:
                          await showMediaInfo(
                            item,
                          );
                          break;

                        case ModuleMenuAction.favorite:
                          await toggleFavorite(
                            item,
                          );
                          break;
                          case ModuleMenuAction.share:
  await SharePlus.instance.share(
    ShareParams(
      files: [
        XFile(item.path),
      ],
    ),
  );
  break;

                        case ModuleMenuAction.delete:
                          await moveToTrash(
                            item,
                          );
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
      ),
    );
  }
}