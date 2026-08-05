import '../database/database_helper.dart';
import '../models/whatsapp_chat.dart';

class WhatsappRepository {
  final DatabaseHelper _database = DatabaseHelper.instance;

  // ==========================
  // Chats
  // ==========================

  Future<List<WhatsappChat>> getChats() async {
    return await _database.getAllWhatsappChats();
  }

  Future<List<WhatsappChat>> getDeletedChats() async {
    return await _database.getDeletedWhatsappChats();
  }

  Future<List<WhatsappChat>> getFavoriteChats() async {
    return await _database.getFavoriteWhatsappChats();
  }

  Future<int> addChat(
    WhatsappChat chat,
  ) async {
    return await _database.insertWhatsappChat(chat);
  }

  Future<void> updateChat(
    WhatsappChat chat,
  ) async {
    await _database.updateWhatsappChat(chat);
  }

  Future<void> toggleFavorite(
    int id,
    bool favorite,
  ) async {
    await _database.toggleWhatsappFavorite(
      id,
      favorite,
    );
  }

  Future<void> moveToTrash(
    int id,
  ) async {
    await _database.moveWhatsappToTrash(id);
  }

  Future<void> restore(
    int id,
  ) async {
    await _database.restoreWhatsapp(id);
  }

  Future<void> deleteForever(
    int id,
  ) async {
    await _database.deleteWhatsapp(id);
  }

  // ==========================
  // Messages
  // ==========================

  Future<void> addMessages(
    List<WhatsappMessage> messages,
  ) async {
    await _database.insertWhatsappMessages(messages);
  }

  Future<List<WhatsappMessage>> getMessages(
    int chatId,
  ) async {
    return await _database.getWhatsappMessages(chatId);
  }

  Future<List<WhatsappMessage>> getMessagesByType(
    int chatId,
    WhatsappMessageType type,
  ) async {
    final messages = await getMessages(chatId);

    return messages
        .where((message) => message.messageType == type)
        .toList();
  }

  Future<List<WhatsappMessage>> searchMessages(
    int chatId,
    String query,
  ) async {
    final messages = await getMessages(chatId);

    final search = query.toLowerCase().trim();

    return messages.where((message) {
      return message.message.toLowerCase().contains(search) ||
          message.sender.toLowerCase().contains(search) ||
          (message.fileName?.toLowerCase().contains(search) ?? false);
    }).toList();
  }

  // ==========================
  // Cleanup
  // ==========================

  Future<void> deleteExpiredItems() async {
    await _database.deleteExpiredRecycleBinItems();
  }
}