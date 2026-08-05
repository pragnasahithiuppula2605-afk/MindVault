import '../database/database_helper.dart';
import '../models/link_item.dart';

class LinkRepository {
  final DatabaseHelper _database = DatabaseHelper.instance;

  Future<List<LinkItem>> getLinks() async {
    return await _database.getAllLinks();
  }

  Future<List<LinkItem>> getDeletedLinks() async {
    return await _database.getDeletedLinks();
  }

  Future<List<LinkItem>> getFavoriteLinks() async {
    return await _database.getFavoriteLinks();
  }

  Future<void> addLink(LinkItem link) async {
  print("ADDING LINK:");
  print(link.title);
  print(link.url);

  final id = await _database.insertLink(link);

  print("INSERTED ID: $id");
}

  Future<void> updateLink(LinkItem link) async {
    await _database.updateLink(link);
  }

  Future<void> renameLink(
    int id,
    String newTitle,
  ) async {
    final links = await getLinks();

    final item = links.firstWhere(
      (element) => element.id == id,
    );

    await updateLink(
      item.copy(title: newTitle),
    );
  }

  Future<void> toggleFavorite(
    int id,
    bool favorite,
  ) async {
    await _database.toggleLinkFavorite(
      id,
      favorite,
    );
  }

  Future<void> moveToTrash(int id) async {
    await _database.moveLinkToTrash(id);
  }

  Future<void> restore(int id) async {
    await _database.restoreLink(id);
  }

  Future<void> deleteForever(int id) async {
    await _database.deleteLink(id);
  }

  Future<List<LinkItem>> searchLinks(
    String query,
  ) async {
    final links = await getLinks();

    if (query.trim().isEmpty) {
      return links;
    }

    return links.where(
      (item) {
        return item.title
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item.url
                .toLowerCase()
                .contains(query.toLowerCase());
      },
    ).toList();
  }

  Future<void> deleteExpiredItems() async {
    await _database.deleteExpiredRecycleBinItems();
  }
}