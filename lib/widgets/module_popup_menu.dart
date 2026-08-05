import 'package:flutter/material.dart';

enum ModuleMenuAction {
  rename,
  info,
  favorite,
  share,
  restore,
  delete,
  deleteForever,
}

class ModulePopupMenu extends StatelessWidget {
  final bool isFavorite;

  final bool showRename;
  final bool showInfo;
  final bool showFavorite;
  final bool showRestore;
  final bool showDelete;
  final bool showDeleteForever;

  final Function(ModuleMenuAction) onSelected;

  const ModulePopupMenu({
    super.key,
    required this.isFavorite,
    required this.onSelected,
    this.showRename = true,
    this.showInfo = true,
    this.showFavorite = true,
    this.showRestore = false,
    this.showDelete = true,
    this.showDeleteForever = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ModuleMenuAction>(
      tooltip: "More",
      onSelected: onSelected,
      itemBuilder: (context) {
        return [

          if (showRename)
            const PopupMenuItem(
              value: ModuleMenuAction.rename,
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text("Rename"),
              ),
            ),

          if (showInfo)
            const PopupMenuItem(
              value: ModuleMenuAction.info,
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text("Information"),
              ),
            ),

          if (showFavorite)
            PopupMenuItem(
              value: ModuleMenuAction.favorite,
              child: ListTile(
                leading: Icon(
                  isFavorite
                      ? Icons.star
                      : Icons.star_border,
                ),
                title: Text(
                  isFavorite
                      ? "Remove Favorite"
                      : "Add to Favorites",
                ),
              ),
            ),
if (showFavorite)
  const PopupMenuDivider(),

const PopupMenuItem(
  value: ModuleMenuAction.share,
  child: ListTile(
    leading: Icon(Icons.share),
    title: Text("Share"),
  ),
),
          if (showRestore)
            const PopupMenuItem(
              value: ModuleMenuAction.restore,
              child: ListTile(
                leading: Icon(Icons.restore),
                title: Text("Restore"),
              ),
            ),

          if (showDelete)
            const PopupMenuItem(
              value: ModuleMenuAction.delete,
              child: ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                title: Text(
                  "Move to Recycle Bin",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),

          if (showDeleteForever)
            const PopupMenuItem(
              value: ModuleMenuAction.deleteForever,
              child: ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                ),
                title: Text(
                  "Delete Forever",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
        ];
      },
    );
  }
}