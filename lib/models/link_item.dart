class LinkItem {
  final int? id;
  final String title;
  final String url;

  final bool isFavorite;
  final bool isDeleted;
  final String? deletedAt;

  LinkItem({
    this.id,
    required this.title,
    required this.url,
    this.isFavorite = false,
    this.isDeleted = false,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'isFavorite': isFavorite ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
      'deletedAt': deletedAt,
    };
  }

  factory LinkItem.fromMap(Map<String, dynamic> map) {
    return LinkItem(
      id: map['id'],
      title: map['title'],
      url: map['url'],
      isFavorite: map['isFavorite'] == 1,
      isDeleted: map['isDeleted'] == 1,
      deletedAt: map['deletedAt'],
    );
  }

  LinkItem copy({
    int? id,
    String? title,
    String? url,
    bool? isFavorite,
    bool? isDeleted,
    String? deletedAt,
  }) {
    return LinkItem(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}