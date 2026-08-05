import 'package:flutter/material.dart';

class ModuleAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final String? subtitle;

  final int totalItems;

  final bool selectionMode;
  final int selectedCount;

  final bool isSearching;

  final TextEditingController searchController;

  final ValueChanged<String> onSearch;

  final VoidCallback onSearchToggle;

  final VoidCallback onSelectAll;

  final VoidCallback onFavorite;

  final VoidCallback onDelete;

  final VoidCallback onCloseSelection;

  final ValueChanged<String> onSort;

  final bool showFavoriteButton;

  const ModuleAppBar({
    super.key,
    required this.title,
    this.subtitle,
    required this.totalItems,
    required this.selectionMode,
    required this.selectedCount,
    required this.isSearching,
    required this.searchController,
    required this.onSearch,
    required this.onSearchToggle,
    required this.onSelectAll,
    required this.onFavorite,
    required this.onDelete,
    required this.onCloseSelection,
    required this.onSort,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 1,
      centerTitle: false,
      title: selectionMode
          ? Text("$selectedCount Selected")
          : isSearching
              ? TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: "Search...",
                    border: InputBorder.none,
                  ),
                  onChanged: onSearch,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle ?? "$totalItems items",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
      actions: [
        if (!selectionMode) ...[
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
            ),
            tooltip:
                isSearching ? "Close Search" : "Search",
            onPressed: onSearchToggle,
          ),
          PopupMenuButton<String>(
            tooltip: "Sort",
            icon: const Icon(Icons.sort),
            onSelected: onSort,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "Newest",
                child: Text("Newest First"),
              ),
              PopupMenuItem(
                value: "Oldest",
                child: Text("Oldest First"),
              ),
              PopupMenuItem(
                value: "A-Z",
                child: Text("Name (A-Z)"),
              ),
              PopupMenuItem(
                value: "Z-A",
                child: Text("Name (Z-A)"),
              ),
            ],
          ),
        ],
        if (selectionMode) ...[
          IconButton(
            icon: const Icon(Icons.select_all),
            tooltip: "Select All",
            onPressed: onSelectAll,
          ),
          if (showFavoriteButton)
            IconButton(
              icon: const Icon(Icons.star),
              tooltip: "Favorite",
              onPressed: onFavorite,
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: "Delete",
            onPressed: onDelete,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: "Close Selection",
            onPressed: onCloseSelection,
          ),
        ],
      ],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);
}