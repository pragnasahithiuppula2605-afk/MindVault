import '../models/search_result.dart';
import 'document_repository.dart';
import 'link_repository.dart';
import 'media_repository.dart';
import 'note_repository.dart';
import 'whatsapp_repository.dart';

class GlobalSearchRepository {
  final NoteRepository _noteRepository = NoteRepository();
  final DocumentRepository _documentRepository =
      DocumentRepository();
  final MediaRepository _mediaRepository =
      MediaRepository();
  final LinkRepository _linkRepository =
      LinkRepository();
  final WhatsappRepository _whatsappRepository =
      WhatsappRepository();

  Future<List<SearchResult>> search(
    String query,
  ) async {
    final List<SearchResult> results = [];

    final search = query.trim().toLowerCase();

    if (search.isEmpty) {
      return results;
    }

    // ==========================
    // Notes
    // ==========================

    final notes =
        await _noteRepository.searchNotes(search);

    results.addAll(
      notes.map(
        (note) => SearchResult(
          module: SearchModule.note,
          id: note.id,
          title: note.title,
          subtitle: note.content,
          data: note,
        ),
      ),
    );

    // ==========================
    // Documents
    // ==========================

    final documents =
        await _documentRepository.getDocuments();

    results.addAll(
      documents
          .where(
            (doc) => doc.name
                .toLowerCase()
                .contains(search),
          )
          .map(
            (doc) => SearchResult(
              module: SearchModule.document,
              id: doc.id,
              title: doc.name,
              subtitle: "Document",
              data: doc,
            ),
          ),
    );

    // ==========================
    // Media
    // ==========================

    final media =
        await _mediaRepository.searchMedia(search);

    results.addAll(
      media.map(
        (item) => SearchResult(
          module: SearchModule.media,
          id: item.id,
          title: item.name,
          subtitle:
              item.isImage ? "Image" : "Video",
          thumbnailPath: item.thumbnail,
          extra: item.type,
          data: item,
        ),
      ),
    );

    // ==========================
    // Links
    // ==========================

    final links =
        await _linkRepository.searchLinks(search);

    results.addAll(
      links.map(
        (link) => SearchResult(
          module: SearchModule.link,
          id: link.id,
          title: link.title,
          subtitle: link.url,
          data: link,
        ),
      ),
    );

    // ==========================
    // WhatsApp
    // ==========================

    final chats =
        await _whatsappRepository.getChats();

    for (final chat in chats) {
      final messages =
          await _whatsappRepository.searchMessages(
        chat.id!,
        search,
      );

      for (final message in messages) {
        results.add(
          SearchResult(
            module: SearchModule.whatsapp,
            id: message.id,
            title: message.sender,
            subtitle: message.message,
            data: message,
          ),
        );
      }
    }

    return results;
  }
}