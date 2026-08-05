enum SearchModule {
  note,
  document,
  media,
  whatsapp,
  link,
}

class SearchResult {
  final SearchModule module;

  /// Database ID of the item
  final int? id;

  /// Primary text shown in search
  final String title;

  /// Secondary text shown below the title
  final String subtitle;

  /// Original object (Note, Document, MediaItem, etc.)
  final dynamic data;

  /// Optional icon to display
  final String? thumbnailPath;

  /// Optional extra info
  final String? extra;

  const SearchResult({
    required this.module,
    this.id,
    required this.title,
    required this.subtitle,
    required this.data,
    this.thumbnailPath,
    this.extra,
  });
}