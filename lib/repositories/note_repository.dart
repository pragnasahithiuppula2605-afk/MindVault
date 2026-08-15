import '../database/database_helper.dart';
import '../models/note.dart';

class NoteRepository {
  final DatabaseHelper _database = DatabaseHelper.instance;

  Future<List<Note>> getNotes() async {
    return await _database.getAllNotes();
  }

  Future<List<Note>> getDeletedNotes() async {
    return await _database.getDeletedNotes();
  }

  Future<List<Note>> getFavoriteNotes() async {
    return await _database.getFavoriteNotes();
  }

  Future<void> addNote(Note note) async {
    await _database.insertNote(note);
  }

  Future<void> updateNote(Note note) async {
    await _database.updateNote(note);
  }

  Future<void> updateLastOpened(int id) async {
    await _database.updateNoteLastOpened(id);
  }

  Future<void> toggleFavorite(
    int id,
    bool favorite,
  ) async {
    await _database.toggleNoteFavorite(
      id,
      favorite,
    );
  }

  Future<void> moveToTrash(int id) async {
    await _database.moveNoteToTrash(id);
  }

  Future<void> restore(int id) async {
    await _database.restoreNote(id);
  }

  Future<void> deleteForever(int id) async {
    await _database.deleteNote(id);
  }

  // ==========================
  // Search
  // ==========================

  Future<List<Note>> searchNotes(
    String query,
  ) async {
    final notes = await getNotes();

    if (query.trim().isEmpty) {
      return notes;
    }

    final search = query.toLowerCase();

    return notes.where((note) {
      return note.title.toLowerCase().contains(search) ||
          note.content.toLowerCase().contains(search);
    }).toList();
  }

  // ==========================
  // Cleanup
  // ==========================

  Future<void> deleteExpiredItems() async {
    await _database.deleteExpiredRecycleBinItems();
  }
}