import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/whatsapp_chat.dart';
import '../models/document.dart';
import '../models/link_item.dart';
import '../models/media_item.dart';
import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper instance =
      DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB(
      'mindvault.db',
    );

    return _database!;
  }

  Future<Database> _initDB(
    String filePath,
  ) async {
    final dbPath =
        await getDatabasesPath();

    final path = join(
      dbPath,
      filePath,
    );

    return await openDatabase(
  path,
  version: 11,
  onConfigure: (db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  },
  onCreate: _createDB,
  onUpgrade: _onUpgrade,
);
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 4) {
      await db.execute(
        '''
ALTER TABLE notes
ADD COLUMN isFavorite INTEGER DEFAULT 0
''',
      );

      await db.execute(
        '''
ALTER TABLE documents
ADD COLUMN isFavorite INTEGER DEFAULT 0
''',
      );
    }

    if (oldVersion < 5) {
      await db.execute(
        '''
CREATE TABLE media(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL,
path TEXT NOT NULL,
type TEXT NOT NULL,
thumbnail TEXT,
size INTEGER DEFAULT 0,
duration INTEGER DEFAULT 0,
isFavorite INTEGER DEFAULT 0,
isDeleted INTEGER DEFAULT 0,
deletedAt TEXT
)
''',
      );
    }

    if (oldVersion < 6) {
      try {
        await db.execute(
          "ALTER TABLE media ADD COLUMN type TEXT DEFAULT 'image'",
        );
      } catch (_) {}

      try {
        await db.execute(
          "ALTER TABLE media ADD COLUMN thumbnail TEXT",
        );
      } catch (_) {}

      try {
        await db.execute(
          "ALTER TABLE media ADD COLUMN size INTEGER DEFAULT 0",
        );
      } catch (_) {}

      try {
        await db.execute(
          "ALTER TABLE media ADD COLUMN duration INTEGER DEFAULT 0",
        );
      } catch (_) {}
    }

    if (oldVersion < 7) {
      try {
        await db.execute(
          '''
ALTER TABLE documents
ADD COLUMN previewPath TEXT
''',
        );
      } catch (_) {}
    }

    if (oldVersion < 9) {
      await db.execute(
        '''
CREATE TABLE links(
id INTEGER PRIMARY KEY AUTOINCREMENT,
title TEXT NOT NULL,
url TEXT NOT NULL,
isFavorite INTEGER DEFAULT 0,
isDeleted INTEGER DEFAULT 0,
deletedAt TEXT
)
''',
      );
    }
    if (oldVersion < 10) {
  await db.execute('''
CREATE TABLE whatsapp_chats(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  path TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  isFavorite INTEGER DEFAULT 0,
  isDeleted INTEGER DEFAULT 0,
  deletedAt TEXT
)
''');

  await db.execute('''
CREATE TABLE whatsapp_messages(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  chatId INTEGER NOT NULL,
  sender TEXT NOT NULL,
  message TEXT NOT NULL,
  timestamp TEXT,
  FOREIGN KEY(chatId)
    REFERENCES whatsapp_chats(id)
    ON DELETE CASCADE
)
''');
}
if (oldVersion < 11) {
  try {
    await db.execute(
      "ALTER TABLE whatsapp_messages ADD COLUMN messageType TEXT DEFAULT 'text'",
    );
  } catch (_) {}

  try {
    await db.execute(
      "ALTER TABLE whatsapp_messages ADD COLUMN fileName TEXT",
    );
  } catch (_) {}

  try {
    await db.execute(
      "ALTER TABLE whatsapp_messages ADD COLUMN mediaPath TEXT",
    );
  } catch (_) {}

  try {
    await db.execute(
      "ALTER TABLE whatsapp_messages ADD COLUMN thumbnailPath TEXT",
    );
  } catch (_) {}

  try {
    await db.execute(
      "ALTER TABLE whatsapp_messages ADD COLUMN mimeType TEXT",
    );
  } catch (_) {}

  try {
    await db.execute(
      "ALTER TABLE whatsapp_messages ADD COLUMN fileSize INTEGER DEFAULT 0",
    );
  } catch (_) {}
}
  }
  Future<void> _createDB(
  Database db,
  int version,
) async {
  // ---------------- Notes ----------------
  await db.execute(
    '''
CREATE TABLE notes(
id INTEGER PRIMARY KEY AUTOINCREMENT,
title TEXT NOT NULL,
content TEXT NOT NULL,
isFavorite INTEGER DEFAULT 0,
isDeleted INTEGER DEFAULT 0,
deletedAt TEXT
)
''',
  );

  // ---------------- Documents ----------------
  await db.execute(
    '''
CREATE TABLE documents(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL,
path TEXT NOT NULL,
previewPath TEXT,
isFavorite INTEGER DEFAULT 0,
isDeleted INTEGER DEFAULT 0,
deletedAt TEXT
)
''',
  );

  // ---------------- Media ----------------
  await db.execute(
    '''
CREATE TABLE media(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL,
path TEXT NOT NULL,
type TEXT NOT NULL,
thumbnail TEXT,
size INTEGER DEFAULT 0,
duration INTEGER DEFAULT 0,
isFavorite INTEGER DEFAULT 0,
isDeleted INTEGER DEFAULT 0,
deletedAt TEXT
)
''',
  );

  // ---------------- Links ----------------
  await db.execute(
    '''
CREATE TABLE links(
id INTEGER PRIMARY KEY AUTOINCREMENT,
title TEXT NOT NULL,
url TEXT NOT NULL,
isFavorite INTEGER DEFAULT 0,
isDeleted INTEGER DEFAULT 0,
deletedAt TEXT
)
''',
  );
  // ---------------- WhatsApp Chats ----------------

await db.execute('''
CREATE TABLE whatsapp_chats(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  path TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  isFavorite INTEGER DEFAULT 0,
  isDeleted INTEGER DEFAULT 0,
  deletedAt TEXT
)
''');
// ---------------- WhatsApp Messages ----------------

await db.execute('''
CREATE TABLE whatsapp_messages(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  chatId INTEGER NOT NULL,
  sender TEXT NOT NULL,
  message TEXT NOT NULL,
  timestamp TEXT,

  messageType TEXT DEFAULT 'text',

  fileName TEXT,

  mediaPath TEXT,

  thumbnailPath TEXT,

  mimeType TEXT,

  fileSize INTEGER DEFAULT 0,

  FOREIGN KEY(chatId)
    REFERENCES whatsapp_chats(id)
    ON DELETE CASCADE
)
''');
}
// ======================================================
// NOTES
// ======================================================

Future<int> insertNote(Note note) async {
  final db = await database;

  return await db.insert(
    'notes',
    note.toMap(),
  );
}

Future<List<Note>> getAllNotes() async {
  final db = await database;

  final result = await db.query(
    'notes',
    where: 'isDeleted = ?',
    whereArgs: [0],
    orderBy: 'id DESC',
  );

  return result
      .map((e) => Note.fromMap(e))
      .toList();
}

Future<List<Note>> getDeletedNotes() async {
  final db = await database;

  final result = await db.query(
    'notes',
    where: 'isDeleted = ?',
    whereArgs: [1],
    orderBy: 'deletedAt DESC',
  );

  return result
      .map((e) => Note.fromMap(e))
      .toList();
}

Future<List<Note>> getFavoriteNotes() async {
  final db = await database;

  final result = await db.query(
    'notes',
    where: 'isFavorite = ? AND isDeleted = ?',
    whereArgs: [1, 0],
    orderBy: 'id DESC',
  );

  return result
      .map((e) => Note.fromMap(e))
      .toList();
}

Future<int> updateNote(Note note) async {
  final db = await database;

  return await db.update(
    'notes',
    note.toMap(),
    where: 'id = ?',
    whereArgs: [note.id],
  );
}

Future<void> toggleNoteFavorite(
  int id,
  bool favorite,
) async {
  final db = await database;

  await db.update(
    'notes',
    {
      'isFavorite': favorite ? 1 : 0,
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> moveNoteToTrash(
  int id,
) async {
  final db = await database;

  await db.update(
    'notes',
    {
      'isDeleted': 1,
      'deletedAt':
          DateTime.now().toIso8601String(),
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> restoreNote(
  int id,
) async {
  final db = await database;

  await db.update(
    'notes',
    {
      'isDeleted': 0,
      'deletedAt': null,
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> deleteNote(
  int id,
) async {
  final db = await database;

  await db.delete(
    'notes',
    where: 'id = ?',
    whereArgs: [id],
  );
}
// ======================================================
// DOCUMENTS
// ======================================================

Future<int> insertDocument(
  Document document,
) async {
  final db = await database;

  return await db.insert(
    'documents',
    document.toMap(),
  );
}

Future<List<Document>> getAllDocuments() async {
  final db = await database;

  final result = await db.query(
    'documents',
    where: 'isDeleted = ?',
    whereArgs: [0],
    orderBy: 'id DESC',
  );

  return result
      .map((e) => Document.fromMap(e))
      .toList();
}

Future<List<Document>> getDeletedDocuments() async {
  final db = await database;

  final result = await db.query(
    'documents',
    where: 'isDeleted = ?',
    whereArgs: [1],
    orderBy: 'deletedAt DESC',
  );

  return result
      .map((e) => Document.fromMap(e))
      .toList();
}

Future<List<Document>> getFavoriteDocuments() async {
  final db = await database;

  final result = await db.query(
    'documents',
    where: 'isFavorite = ? AND isDeleted = ?',
    whereArgs: [1, 0],
    orderBy: 'id DESC',
  );

  return result
      .map((e) => Document.fromMap(e))
      .toList();
}

Future<int> updateDocument(
  Document document,
) async {
  final db = await database;

  return await db.update(
    'documents',
    document.toMap(),
    where: 'id = ?',
    whereArgs: [document.id],
  );
}

Future<void> toggleDocumentFavorite(
  int id,
  bool favorite,
) async {
  final db = await database;

  await db.update(
    'documents',
    {
      'isFavorite': favorite ? 1 : 0,
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> moveDocumentToTrash(
  int id,
) async {
  final db = await database;

  await db.update(
    'documents',
    {
      'isDeleted': 1,
      'deletedAt': DateTime.now().toIso8601String(),
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> restoreDocument(
  int id,
) async {
  final db = await database;

  await db.update(
    'documents',
    {
      'isDeleted': 0,
      'deletedAt': null,
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> deleteDocument(
  int id,
) async {
  final db = await database;

  await db.delete(
    'documents',
    where: 'id = ?',
    whereArgs: [id],
  );
}
// ======================================================
// MEDIA
// ======================================================

Future<int> insertMedia(
  MediaItem media,
) async {
  final db = await database;

  return await db.insert(
    'media',
    media.toMap(),
  );
}

Future<List<MediaItem>> getAllMedia() async {
  final db = await database;

  final result = await db.query(
    'media',
    where: 'isDeleted = ?',
    whereArgs: [0],
    orderBy: 'id DESC',
  );

  return result
      .map((e) => MediaItem.fromMap(e))
      .toList();
}

Future<List<MediaItem>> getDeletedMedia() async {
  final db = await database;

  final result = await db.query(
    'media',
    where: 'isDeleted = ?',
    whereArgs: [1],
    orderBy: 'deletedAt DESC',
  );

  return result
      .map((e) => MediaItem.fromMap(e))
      .toList();
}

Future<List<MediaItem>> getFavoriteMedia() async {
  final db = await database;

  final result = await db.query(
    'media',
    where: 'isFavorite = ? AND isDeleted = ?',
    whereArgs: [1, 0],
    orderBy: 'id DESC',
  );

  return result
      .map((e) => MediaItem.fromMap(e))
      .toList();
}

Future<int> updateMedia(
  MediaItem media,
) async {
  final db = await database;

  return await db.update(
    'media',
    media.toMap(),
    where: 'id = ?',
    whereArgs: [media.id],
  );
}

Future<void> toggleMediaFavorite(
  int id,
  bool favorite,
) async {
  final db = await database;

  await db.update(
    'media',
    {
      'isFavorite': favorite ? 1 : 0,
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> moveMediaToTrash(
  int id,
) async {
  final db = await database;

  await db.update(
    'media',
    {
      'isDeleted': 1,
      'deletedAt': DateTime.now().toIso8601String(),
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> restoreMedia(
  int id,
) async {
  final db = await database;

  await db.update(
    'media',
    {
      'isDeleted': 0,
      'deletedAt': null,
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> deleteMedia(
  int id,
) async {
  final db = await database;

  await db.delete(
    'media',
    where: 'id = ?',
    whereArgs: [id],
  );
}
// ======================================================
// LINKS
// ======================================================

Future<int> insertLink(
  LinkItem link,
) async {
  final db = await database;

  return await db.insert(
    'links',
    link.toMap(),
  );
}

Future<List<LinkItem>> getAllLinks() async {
  final db = await database;

  final result = await db.query(
    'links',
    where: 'isDeleted = ?',
    whereArgs: [0],
    orderBy: 'id DESC',
  );

  return result
      .map((e) => LinkItem.fromMap(e))
      .toList();
}

Future<List<LinkItem>> getDeletedLinks() async {
  final db = await database;

  final result = await db.query(
    'links',
    where: 'isDeleted = ?',
    whereArgs: [1],
    orderBy: 'deletedAt DESC',
  );

  return result
      .map((e) => LinkItem.fromMap(e))
      .toList();
}

Future<List<LinkItem>> getFavoriteLinks() async {
  final db = await database;

  final result = await db.query(
    'links',
    where: 'isFavorite = ? AND isDeleted = ?',
    whereArgs: [1, 0],
    orderBy: 'id DESC',
  );

  return result
      .map((e) => LinkItem.fromMap(e))
      .toList();
}

Future<int> updateLink(
  LinkItem link,
) async {
  final db = await database;

  return await db.update(
    'links',
    link.toMap(),
    where: 'id = ?',
    whereArgs: [link.id],
  );
}

Future<void> toggleLinkFavorite(
  int id,
  bool favorite,
) async {
  final db = await database;

  await db.update(
    'links',
    {
      'isFavorite': favorite ? 1 : 0,
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> moveLinkToTrash(
  int id,
) async {
  final db = await database;

  await db.update(
    'links',
    {
      'isDeleted': 1,
      'deletedAt': DateTime.now().toIso8601String(),
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> restoreLink(
  int id,
) async {
  final db = await database;

  await db.update(
    'links',
    {
      'isDeleted': 0,
      'deletedAt': null,
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> deleteLink(
  int id,
) async {
  final db = await database;

  await db.delete(
    'links',
    where: 'id = ?',
    whereArgs: [id],
  );
}
// ======================================================
// WHATSAPP CHATS
// ======================================================

Future<int> insertWhatsappChat(
  WhatsappChat chat,
) async {
  final db = await database;

  return await db.insert(
    'whatsapp_chats',
    chat.toMap(),
  );
}

Future<List<WhatsappChat>> getAllWhatsappChats() async {
  final db = await database;

  final result = await db.query(
    'whatsapp_chats',
    where: 'isDeleted = ?',
    whereArgs: [0],
    orderBy: 'id DESC',
  );

  return result
      .map((e) => WhatsappChat.fromMap(e))
      .toList();
}

Future<List<WhatsappChat>> getDeletedWhatsappChats() async {
  final db = await database;

  final result = await db.query(
    'whatsapp_chats',
    where: 'isDeleted = ?',
    whereArgs: [1],
    orderBy: 'deletedAt DESC',
  );

  return result
      .map((e) => WhatsappChat.fromMap(e))
      .toList();
}

Future<List<WhatsappChat>> getFavoriteWhatsappChats() async {
  final db = await database;

  final result = await db.query(
    'whatsapp_chats',
    where: 'isFavorite = ? AND isDeleted = ?',
    whereArgs: [1, 0],
    orderBy: 'id DESC',
  );

  return result
      .map((e) => WhatsappChat.fromMap(e))
      .toList();
}

Future<int> updateWhatsappChat(
  WhatsappChat chat,
) async {
  final db = await database;

  return await db.update(
    'whatsapp_chats',
    chat.toMap(),
    where: 'id = ?',
    whereArgs: [chat.id],
  );
}

Future<void> toggleWhatsappFavorite(
  int id,
  bool favorite,
) async {
  final db = await database;

  await db.update(
    'whatsapp_chats',
    {
      'isFavorite': favorite ? 1 : 0,
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> moveWhatsappToTrash(
  int id,
) async {
  final db = await database;

  await db.update(
    'whatsapp_chats',
    {
      'isDeleted': 1,
      'deletedAt': DateTime.now().toIso8601String(),
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> restoreWhatsapp(
  int id,
) async {
  final db = await database;

  await db.update(
    'whatsapp_chats',
    {
      'isDeleted': 0,
      'deletedAt': null,
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> deleteWhatsapp(
  int id,
) async {
  final db = await database;

  await db.delete(
    'whatsapp_chats',
    where: 'id = ?',
    whereArgs: [id],
  );
}

// ======================================================
// WHATSAPP MESSAGES
// ======================================================

Future<void> insertWhatsappMessages(
  List<WhatsappMessage> messages,
) async {
  final db = await database;

  final batch = db.batch();

  for (final message in messages) {
    batch.insert(
      'whatsapp_messages',
      message.toMap(),
    );
  }

  await batch.commit(
    noResult: true,
  );
}

Future<List<WhatsappMessage>> getWhatsappMessages(
  int chatId,
) async {
  final db = await database;

  final result = await db.query(
    'whatsapp_messages',
    where: 'chatId = ?',
    whereArgs: [chatId],
    orderBy: 'id ASC',
  );

  return result
      .map((e) => WhatsappMessage.fromMap(e))
      .toList();
}
// ======================================================
// RECYCLE BIN CLEANUP
// ======================================================

Future<void> deleteExpiredRecycleBinItems() async {
  final db = await database;

  final cutoffDate = DateTime.now()
      .subtract(const Duration(days: 10))
      .toIso8601String();

  await db.delete(
    'notes',
    where: 'isDeleted = ? AND deletedAt IS NOT NULL AND deletedAt < ?',
    whereArgs: [1, cutoffDate],
  );

  await db.delete(
    'documents',
    where: 'isDeleted = ? AND deletedAt IS NOT NULL AND deletedAt < ?',
    whereArgs: [1, cutoffDate],
  );

  await db.delete(
    'media',
    where: 'isDeleted = ? AND deletedAt IS NOT NULL AND deletedAt < ?',
    whereArgs: [1, cutoffDate],
  );

  await db.delete(
    'links',
    where: 'isDeleted = ? AND deletedAt IS NOT NULL AND deletedAt < ?',
    whereArgs: [1, cutoffDate],
  );
await db.delete(
  'whatsapp_chats',
  where:
      'isDeleted = ? AND deletedAt IS NOT NULL AND deletedAt < ?',
  whereArgs: [1, cutoffDate],
);
}
// ======================================================
// CLOSE DATABASE
// ======================================================

Future<void> close() async {
  final db = await database;
  await db.close();

}
Future<void> deleteDatabaseFile() async {
  await close();

  final dbPath = await getDatabasesPath();

  final path = join(
    dbPath,
    'mindvault.db',
  );

  await databaseFactory.deleteDatabase(path);

  _database = null;
}
}