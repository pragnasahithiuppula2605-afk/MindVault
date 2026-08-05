class WhatsappChat {
  final int? id;
  final String title;
  final String path;
  final String createdAt;
  final bool isFavorite;
  final bool isDeleted;
  final String? deletedAt;

  const WhatsappChat({
    this.id,
    required this.title,
    required this.path,
    required this.createdAt,
    this.isFavorite = false,
    this.isDeleted = false,
    this.deletedAt,
  });

  WhatsappChat copyWith({
    int? id,
    String? title,
    String? path,
    String? createdAt,
    bool? isFavorite,
    bool? isDeleted,
    String? deletedAt,
  }) {
    return WhatsappChat(
      id: id ?? this.id,
      title: title ?? this.title,
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'path': path,
      'createdAt': createdAt,
      'isFavorite': isFavorite ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
      'deletedAt': deletedAt,
    };
  }

  factory WhatsappChat.fromMap(
    Map<String, dynamic> map,
  ) {
    return WhatsappChat(
      id: map['id'],
      title: map['title'],
      path: map['path'],
      createdAt: map['createdAt'],
      isFavorite: map['isFavorite'] == 1,
      isDeleted: map['isDeleted'] == 1,
      deletedAt: map['deletedAt'],
    );
  }
}
enum WhatsappMessageType {
  text,
  image,
  video,
  audio,
  voice,
  pdf,
  document,
  link,
  location,
  contact,
  sticker,
  unknown,
}

class WhatsappMessage {
  final int? id;
  final int chatId;
  final String sender;
  final String message;
  final String? timestamp;

  final WhatsappMessageType messageType;
  final String? fileName;
  final String? mediaPath;
  final String? thumbnailPath;
  final String? mimeType;
  final int? fileSize;

  const WhatsappMessage({
    this.id,
    required this.chatId,
    required this.sender,
    required this.message,
    this.timestamp,
    this.messageType = WhatsappMessageType.text,
    this.fileName,
    this.mediaPath,
    this.thumbnailPath,
    this.mimeType,
    this.fileSize,
  });

  WhatsappMessage copyWith({
    int? id,
    int? chatId,
    String? sender,
    String? message,
    String? timestamp,
    WhatsappMessageType? messageType,
    String? fileName,
    String? mediaPath,
    String? thumbnailPath,
    String? mimeType,
    int? fileSize,
  }) {
    return WhatsappMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      sender: sender ?? this.sender,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      fileName: fileName ?? this.fileName,
      mediaPath: mediaPath ?? this.mediaPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'sender': sender,
      'message': message,
      'timestamp': timestamp,
      'messageType': messageType.name,
      'fileName': fileName,
      'mediaPath': mediaPath,
      'thumbnailPath': thumbnailPath,
      'mimeType': mimeType,
      'fileSize': fileSize,
    };
  }

  factory WhatsappMessage.fromMap(
    Map<String, dynamic> map,
  ) {
    return WhatsappMessage(
      id: map['id'],
      chatId: map['chatId'],
      sender: map['sender'],
      message: map['message'],
      timestamp: map['timestamp'],
      messageType: WhatsappMessageType.values.firstWhere(
        (e) => e.name == map['messageType'],
        orElse: () => WhatsappMessageType.text,
      ),
      fileName: map['fileName'],
      mediaPath: map['mediaPath'],
      thumbnailPath: map['thumbnailPath'],
      mimeType: map['mimeType'],
      fileSize: map['fileSize'],
    );
  }
}