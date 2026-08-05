class MediaItem {
  final int? id;
  final String name;
  final String path;

  /// image or video
  final String type;

  /// video thumbnail (null for images)
  final String? thumbnail;

  /// file size in bytes
  final int size;

  /// duration in seconds (0 for images)
  final int duration;

  final bool isFavorite;
  final bool isDeleted;
  final String? deletedAt;

  MediaItem({
    this.id,
    required this.name,
    required this.path,
    required this.type,
    this.thumbnail,
    this.size = 0,
    this.duration = 0,
    this.isFavorite = false,
    this.isDeleted = false,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'type': type,
      'thumbnail': thumbnail,
      'size': size,
      'duration': duration,
      'isFavorite': isFavorite ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
      'deletedAt': deletedAt,
    };
  }

  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
      id: map['id'],
      name: map['name'],
      path: map['path'],
      type: map['type'] ?? 'image',
      thumbnail: map['thumbnail'],
      size: map['size'] ?? 0,
      duration: map['duration'] ?? 0,
      isFavorite: map['isFavorite'] == 1,
      isDeleted: map['isDeleted'] == 1,
      deletedAt: map['deletedAt'],
    );
  }

  MediaItem copy({
    int? id,
    String? name,
    String? path,
    String? type,
    String? thumbnail,
    int? size,
    int? duration,
    bool? isFavorite,
    bool? isDeleted,
    String? deletedAt,
  }) {
    return MediaItem(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      type: type ?? this.type,
      thumbnail: thumbnail ?? this.thumbnail,
      size: size ?? this.size,
      duration: duration ?? this.duration,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  bool get isImage => type == "image";

  bool get isVideo => type == "video";
}