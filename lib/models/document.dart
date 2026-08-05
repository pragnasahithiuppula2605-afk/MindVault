class Document {
  final int? id;
  final String name;
  final String path;

  final bool isFavorite;
  final bool isDeleted;
  final String? deletedAt;

  Document({
    this.id,
    required this.name,
    required this.path,
    this.isFavorite = false,
    this.isDeleted = false,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'isFavorite': isFavorite ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
      'deletedAt': deletedAt,
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'],
      name: map['name'],
      path: map['path'],
      isFavorite: map['isFavorite'] == 1,
      isDeleted: map['isDeleted'] == 1,
      deletedAt: map['deletedAt'],
    );
  }

  Document copy({
    int? id,
    String? name,
    String? path,
    bool? isFavorite,
    bool? isDeleted,
    String? deletedAt,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}