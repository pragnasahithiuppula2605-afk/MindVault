import '../database/database_helper.dart';
import '../models/recent_display_item.dart';
import '../models/recent_history.dart';

class RecentRepository {
  final DatabaseHelper _database = DatabaseHelper.instance;

  Future<void> addRecent({
    required int itemId,
    required String type,
  }) async {
    final db = await _database.database;

    // Remove duplicate
    await db.delete(
      'recent_items',
      where: 'itemId = ? AND type = ?',
      whereArgs: [itemId, type],
    );

    // Insert newest
    await db.insert(
      'recent_items',
      RecentHistory(
        itemId: itemId,
        type: type,
        openedAt: DateTime.now(),
      ).toMap(),
    );

    // Keep latest 100 items
    final rows = await db.query(
      'recent_items',
      orderBy: 'openedAt DESC',
    );

    if (rows.length > 100) {
      for (int i = 100; i < rows.length; i++) {
        await db.delete(
          'recent_items',
          where: 'id = ?',
          whereArgs: [rows[i]['id']],
        );
      }
    }
  }

  Future<List<RecentHistory>> getRecentHistory() async {
    final db = await _database.database;

    final result = await db.query(
      'recent_items',
      orderBy: 'openedAt DESC',
    );

    return result
        .map((e) => RecentHistory.fromMap(e))
        .toList();
  }

  Future<void> clearHistory() async {
    final db = await _database.database;

    await db.delete('recent_items');
  }

  /// Returns display-ready items using DatabaseHelper.getRecentItems()
  Future<List<RecentDisplayItem>> getDisplayItems() async {
    final rows = await _database.getRecentItems();

    return rows.map((row) {
      String title = 'Unknown Item';
      String? thumbnail;

      switch (row['type']) {
        case 'note':
          title = row['noteTitle'] ?? 'Untitled Note';
          break;

        case 'document':
          title = row['documentTitle'] ?? 'Untitled Document';
          break;

        case 'media':
          title = row['mediaTitle'] ?? 'Media';
          thumbnail = row['mediaThumbnail'];
          break;

        case 'link':
          title = row['linkTitle'] ?? 'Link';
          break;

        case 'whatsapp':
          title = row['whatsappTitle'] ?? 'WhatsApp Chat';
          break;
      }

      return RecentDisplayItem(
        itemId: row['itemId'],
        type: row['type'],
        title: title,
        subtitle: null,
        thumbnail: thumbnail,
        openedAt: DateTime.parse(row['openedAt']),
      );
    }).toList();
  }
}