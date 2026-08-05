import '../database/database_helper.dart';
import '../models/media_item.dart';

class MediaRepository {
  final DatabaseHelper _database = DatabaseHelper.instance;

  Future<List<MediaItem>> getMedia() async {
    return await _database.getAllMedia();
  }

  Future<List<MediaItem>> getImages() async {
    final media = await _database.getAllMedia();

    return media.where((item) => item.isImage).toList();
  }

  Future<List<MediaItem>> getVideos() async {
    final media = await _database.getAllMedia();

    return media.where((item) => item.isVideo).toList();
  }

  Future<List<MediaItem>> getDeletedMedia() async {
    return await _database.getDeletedMedia();
  }

  Future<List<MediaItem>> getFavoriteMedia() async {
    return await _database.getFavoriteMedia();
  }

  Future<void> addMedia(MediaItem media) async {
    await _database.insertMedia(media);
  }

  Future<void> updateMedia(MediaItem media) async {
    await _database.updateMedia(media);
  }

  Future<void> renameMedia(
    int id,
    String newName,
  ) async {
    final media = await getMedia();

    final item = media.firstWhere(
      (element) => element.id == id,
    );

    await updateMedia(
      item.copy(name: newName),
    );
  }

  Future<void> toggleFavorite(
    int id,
    bool favorite,
  ) async {
    await _database.toggleMediaFavorite(
      id,
      favorite,
    );
  }

  Future<void> moveToTrash(int id) async {
    await _database.moveMediaToTrash(id);
  }

  Future<void> restore(int id) async {
    await _database.restoreMedia(id);
  }

  Future<void> deleteForever(int id) async {
    await _database.deleteMedia(id);
  }

  Future<List<MediaItem>> searchMedia(
    String query,
  ) async {
    final media = await getMedia();

    if (query.trim().isEmpty) {
      return media;
    }

    return media.where(
      (item) {
        return item.name
            .toLowerCase()
            .contains(query.toLowerCase());
      },
    ).toList();
  }

  Future<void> deleteExpiredItems() async {
    await _database.deleteExpiredRecycleBinItems();
  }
}