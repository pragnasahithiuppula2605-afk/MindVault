import 'package:flutter/material.dart';

import 'module_popup_menu.dart';

class ModuleCard extends StatelessWidget {
  final Widget thumbnail;
  final String title;
  final String subtitle;

  final bool isSelected;
  final bool selectionMode;
  final bool isFavorite;

  final Color? titleColor;
  final Color? subtitleColor;

  final VoidCallback onTap;
  final VoidCallback onLongPress;

  final ValueChanged<bool?>? onChecked;

  final Function(ModuleMenuAction) onMenuSelected;

  final bool showPopupMenu;
  final bool showCheckbox;

  const ModuleCard({
    super.key,
    required this.thumbnail,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.selectionMode,
    required this.isFavorite,
    required this.onTap,
    required this.onLongPress,
    required this.onChecked,
    required this.onMenuSelected,
    this.titleColor,
    this.subtitleColor,
    this.showPopupMenu = true,
    this.showCheckbox = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (selectionMode && showCheckbox)
                Checkbox(
                  value: isSelected,
                  onChanged: onChecked,
                ),

              SizedBox(
  width: 60,
  height: 60,
  child: Stack(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 60,
          height: 60,
          child: thumbnail,
        ),
      ),

      if (isFavorite)
        Positioned(
          top: 2,
          right: 2,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              color: Colors.amber,
              size: 16,
            ),
          ),
        ),
    ],
  ),
),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor ?? Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              if (showPopupMenu)
                ModulePopupMenu(
                  isFavorite: isFavorite,
                  onSelected: onMenuSelected,
                ),
            ],
          ),
        ),
      ),
    );
  }
}