class Note {
  final int? id;
  final String title;
  final String content;

  final bool isFavorite;

  final bool isDeleted;
  final String? deletedAt;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.isFavorite = false,
    this.isDeleted = false,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'isFavorite': isFavorite ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
      'deletedAt': deletedAt,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      isFavorite: map['isFavorite'] == 1,
      isDeleted: map['isDeleted'] == 1,
      deletedAt: map['deletedAt'],
    );
  }

  Note copy({
    int? id,
    String? title,
    String? content,
    bool? isFavorite,
    bool? isDeleted,
    String? deletedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}