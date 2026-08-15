class RecentItem {
  final int id;
  final String title;
  final String type;
  final String? path;
  final DateTime lastOpened;

  RecentItem({
    required this.id,
    required this.title,
    required this.type,
    this.path,
    required this.lastOpened,
  });
}