class RecentDisplayItem {
  final int itemId;
  final String type;

  final String title;
  final String? subtitle;

  final String? thumbnail;

  final DateTime openedAt;

  const RecentDisplayItem({
    required this.itemId,
    required this.type,
    required this.title,
    this.subtitle,
    this.thumbnail,
    required this.openedAt,
  });
}