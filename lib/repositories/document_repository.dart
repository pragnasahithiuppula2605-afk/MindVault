import '../database/database_helper.dart';
import '../models/document.dart';

class DocumentRepository {
  final DatabaseHelper _database = DatabaseHelper.instance;

  Future<List<Document>> getDocuments() async {
    return await _database.getAllDocuments();
  }

  Future<List<Document>> getDeletedDocuments() async {
    return await _database.getDeletedDocuments();
  }

  Future<List<Document>> getFavoriteDocuments() async {
    return await _database.getFavoriteDocuments();
  }

  Future<void> addDocument(Document document) async {
    await _database.insertDocument(document);
  }

  Future<void> toggleFavorite(
    int id,
    bool favorite,
  ) async {
    await _database.toggleDocumentFavorite(
      id,
      favorite,
    );
  }

  Future<void> moveToTrash(int id) async {
    await _database.moveDocumentToTrash(id);
  }

  Future<void> restore(int id) async {
    await _database.restoreDocument(id);
  }
Future<void> updateDocument(
  Document document,
) async {
  await _database.updateDocument(document);
}
  Future<void> deleteForever(int id) async {
    await _database.deleteDocument(id);
  }
  Future<void> deleteExpiredItems() async {
  await _database.deleteExpiredRecycleBinItems();
}
}