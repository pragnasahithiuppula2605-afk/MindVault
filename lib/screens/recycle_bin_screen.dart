import 'package:flutter/material.dart';

import '../models/document.dart';
import '../models/media_item.dart';
import '../models/note.dart';
import '../models/link_item.dart';
import '../models/whatsapp_chat.dart';
import '../repositories/document_repository.dart';
import '../repositories/media_repository.dart';
import '../repositories/note_repository.dart';
import '../repositories/link_repository.dart';
import '../repositories/whatsapp_repository.dart';
import 'note_details_screen.dart';
import '../widgets/media_thumbnail.dart';
import '../widgets/module_empty_state.dart';
import '../widgets/module_snackbar.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import 'whatsapp_chat_screen.dart';
import 'package:photo_view/photo_view.dart';
class RecycleBinScreen extends StatefulWidget {
  const RecycleBinScreen({super.key});

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  final NoteRepository _noteRepository = NoteRepository();
  final DocumentRepository _documentRepository = DocumentRepository();
  final MediaRepository _mediaRepository = MediaRepository();
  final LinkRepository _linkRepository = LinkRepository();
final WhatsappRepository _whatsappRepository = WhatsappRepository();

  List<Note> _deletedNotes = [];
  List<Document> _deletedDocuments = [];
  List<MediaItem> _deletedMedia = [];
  List<LinkItem> _deletedLinks = [];
List<WhatsappChat> _deletedChats = [];

  bool _isLoading = true;

  bool _selectionMode = false;

  final Set<int> _selectedNotes = {};
  final Set<int> _selectedDocuments = {};
  final Set<int> _selectedMedia = {};
  final Set<int> _selectedLinks = {};
final Set<int> _selectedChats = {};

  @override
  void initState() {
    super.initState();
    _loadRecycleBin();
  }

  Future<void> _loadRecycleBin() async {
    setState(() {
      _isLoading = true;
    });
await _noteRepository.deleteExpiredItems();
    final notes = await _noteRepository.getDeletedNotes();
    final documents =
        await _documentRepository.getDeletedDocuments();
    final media = await _mediaRepository.getDeletedMedia();
final links = await _linkRepository.getDeletedLinks();
final chats = await _whatsappRepository.getDeletedChats();
print("Deleted Links: ${links.length}");
for (final link in links) {
  print("LINK -> ${link.title}");
}

print("Deleted Chats: ${chats.length}");
for (final chat in chats) {
  print("CHAT -> ${chat.title}");
}
    if (!mounted) return;

    setState(() {
      _deletedNotes = notes;
_deletedDocuments = documents;
_deletedMedia = media;
_deletedLinks = links;
_deletedChats = chats;
_isLoading = false;
    });
  }

  int get _selectedCount =>
    _selectedNotes.length +
    _selectedDocuments.length +
    _selectedMedia.length +
    _selectedLinks.length +
    _selectedChats.length;

  bool get _hasItems =>
    _deletedNotes.isNotEmpty ||
    _deletedDocuments.isNotEmpty ||
    _deletedMedia.isNotEmpty ||
    _deletedLinks.isNotEmpty ||
    _deletedChats.isNotEmpty;

  void _enterSelectionMode() {
    setState(() {
      _selectionMode = true;
    });
  }

  void _exitSelectionMode() {
  setState(() {
    _selectionMode = false;

    _selectedNotes.clear();
    _selectedDocuments.clear();
    _selectedMedia.clear();
    _selectedLinks.clear();
    _selectedChats.clear();
  });
}

  
      void _toggleNote(Note note) {
  if (note.id == null) return;

  setState(() {
    if (_selectedNotes.contains(note.id!)) {
      _selectedNotes.remove(note.id!);
    } else {
      _selectedNotes.add(note.id!);
    }

    if (_selectedCount == 0) {
      _selectionMode = false;
    }
  });
}

void _toggleDocument(Document document) {
  if (document.id == null) return;

  setState(() {
    if (_selectedDocuments.contains(document.id!)) {
      _selectedDocuments.remove(document.id!);
    } else {
      _selectedDocuments.add(document.id!);
    }

    if (_selectedCount == 0) {
      _selectionMode = false;
    }
  });
}

  void _toggleLink(LinkItem link) {
  if (link.id == null) return;

  setState(() {
    if (_selectedLinks.contains(link.id!)) {
      _selectedLinks.remove(link.id!);
    } else {
      _selectedLinks.add(link.id!);
    }

    if (_selectedCount == 0) {
      _selectionMode = false;
    }
  });
}
void _toggleMedia(MediaItem media) {
  if (media.id == null) return;

  setState(() {
    if (_selectedMedia.contains(media.id!)) {
      _selectedMedia.remove(media.id!);
    } else {
      _selectedMedia.add(media.id!);
    }

    if (_selectedCount == 0) {
      _selectionMode = false;
    }
  });
}
void _toggleChat(WhatsappChat chat) {
  if (chat.id == null) return;

  setState(() {
    if (_selectedChats.contains(chat.id!)) {
      _selectedChats.remove(chat.id!);
    } else {
      _selectedChats.add(chat.id!);
    }

    if (_selectedCount == 0) {
      _selectionMode = false;
    }
  });
}

  Future<void> _restoreSelected() async {
    for (final id in _selectedNotes) {
      await _noteRepository.restore(id);
    }

    for (final id in _selectedDocuments) {
      await _documentRepository.restore(id);
    }

    for (final id in _selectedMedia) {
      await _mediaRepository.restore(id);
    }
    for (final id in _selectedLinks) {
  await _linkRepository.restore(id);
}

for (final id in _selectedChats) {
  await _whatsappRepository.restore(id);
}

    if (!mounted) return;

    ModuleSnackBar.show(
      context,
      _selectedCount == 1
    ? 'Restored successfully'
    : '$_selectedCount items restored',
    );

    _exitSelectionMode();

    await _loadRecycleBin();
  }

  Future<void> _deleteSelectedForever() async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
  _selectedCount == 1
      ? 'Delete item?'
      : 'Delete $_selectedCount items?',
),

content: Text(
  _selectedCount == 1
      ? 'This item will be permanently deleted from MindVault.'
      : 'These items will be permanently deleted from MindVault.',
),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirm) return;

    for (final id in _selectedNotes) {
      await _noteRepository.deleteForever(id);
    }

    for (final id in _selectedDocuments) {
      await _documentRepository.deleteForever(id);
    }

    for (final id in _selectedMedia) {
      await _mediaRepository.deleteForever(id);
    }
    for (final id in _selectedLinks) {
  await _linkRepository.deleteForever(id);
}

for (final id in _selectedChats) {
  await _whatsappRepository.deleteForever(id);
}

    if (!mounted) return;

    ModuleSnackBar.show(
      context,
      'Items deleted permanently',
    );

    _exitSelectionMode();

    await _loadRecycleBin();
  }

Future<void> _showEmptyRecycleBinDialog() async {
  final confirm = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Empty Recycle Bin?'),
            content: const Text(
              'All items in the Recycle Bin will be permanently deleted from MindVault.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Empty Bin'),
              ),
            ],
          );
        },
      ) ??
      false;

  if (!confirm) return;
  for (final note in _deletedNotes) {
  await _noteRepository.deleteForever(note.id!);
}

for (final document in _deletedDocuments) {
  await _documentRepository.deleteForever(document.id!);
}

for (final media in _deletedMedia) {
  await _mediaRepository.deleteForever(media.id!);
}
for (final link in _deletedLinks) {
  if (link.id != null) {
    await _linkRepository.deleteForever(link.id!);
  }
}

for (final chat in _deletedChats) {
  if (chat.id != null) {
    await _whatsappRepository.deleteForever(chat.id!);
  }
}

if (!mounted) return;

ModuleSnackBar.show(
  context,
  'Recycle Bin emptied',
);

await _loadRecycleBin();
}

void _selectAll() {
  setState(() {
    _selectedNotes.clear();
    _selectedDocuments.clear();
    _selectedMedia.clear();
    _selectedLinks.clear();
    _selectedChats.clear();

    for (final note in _deletedNotes) {
      _selectedNotes.add(note.id!);
    }

    for (final document in _deletedDocuments) {
      _selectedDocuments.add(document.id!);
    }

    for (final media in _deletedMedia) {
      _selectedMedia.add(media.id!);
    }

    for (final link in _deletedLinks) {
      if (link.id != null) {
        _selectedLinks.add(link.id!);
      }
    }

    for (final chat in _deletedChats) {
      if (chat.id != null) {
        _selectedChats.add(chat.id!);
      }
    }
  });
}

  void _deselectAll() {
  setState(() {
    _selectedNotes.clear();
    _selectedDocuments.clear();
    _selectedMedia.clear();
    _selectedLinks.clear();
    _selectedChats.clear();
  });
}

  bool _isNoteSelected(Note note) =>
    note.id != null &&
    _selectedNotes.contains(note.id!);

  bool _isDocumentSelected(Document document) =>
    document.id != null &&
    _selectedDocuments.contains(document.id!);

  bool _isMediaSelected(MediaItem media) =>
    media.id != null &&
    _selectedMedia.contains(media.id!);
    bool _isLinkSelected(LinkItem link) =>
    link.id != null &&
    _selectedLinks.contains(link.id!);

bool _isChatSelected(WhatsappChat chat) =>
    chat.id != null &&
    _selectedChats.contains(chat.id!);

  @override
  Widget build(BuildContext context) {
        return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: _selectionMode
            ? Text(
                '$_selectedCount Selected',
              )
            : const Text(
                'Recycle Bin',
              ),
        leading: _selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
              )
            : null,
        actions: _selectionMode
            ? [
                IconButton(
  tooltip: _selectedCount ==
(_deletedNotes.length +
 _deletedDocuments.length +
 _deletedMedia.length +
 _deletedLinks.length +
 _deletedChats.length)
      ? 'Deselect All'
      : 'Select All',
  icon: Icon(
    _selectedCount ==
            (_deletedNotes.length +
                _deletedDocuments.length +
                _deletedMedia.length)
        ? Icons.deselect
        : Icons.select_all,
  ),
  onPressed: () {
    if (_selectedCount ==
        (_deletedNotes.length +
            _deletedDocuments.length +
            _deletedMedia.length)) {
      _deselectAll();
    } else {
      _selectAll();
    }
  },
),
                IconButton(
                  tooltip: 'Restore',
                  icon: const Icon(Icons.restore),
                  onPressed: _selectedCount == 0
                      ? null
                      : _restoreSelected,
                ),
                IconButton(
                  tooltip: 'Delete Forever',
                  icon: const Icon(Icons.delete_forever),
                  onPressed: _selectedCount == 0
                      ? null
                      : _deleteSelectedForever,
                ),
              ]
            : [
    PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'empty') {
          _showEmptyRecycleBinDialog();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'empty',
          child: Text('Empty Recycle Bin'),
        ),
      ],
    ),
  ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : !_hasItems
              ? const ModuleEmptyState(
                  icon: Icons.delete_outline,
                  title: 'Recycle Bin is Empty',
                  subtitle:
                      'Deleted notes, documents and media will appear here.',
                )
              : RefreshIndicator(
                  onRefresh: _loadRecycleBin,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [

                      if (_deletedNotes.isNotEmpty) ...[
                        const Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        ..._deletedNotes.map(
                          (note) => Card(
                            margin: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            child: ListTile(
                              onLongPress: () {
                                if (!_selectionMode) {
                                  _enterSelectionMode();
                                }
                                _toggleNote(note);
                              },
                              onTap: () async {
  if (_selectionMode) {
    _toggleNote(note);
    return;
  }

  final updated = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => NoteDetailsScreen(
        note: note,
      ),
    ),
  );

  if (updated == true) {
    await _loadRecycleBin();
  }
},
                              leading: _selectionMode
                                  ? Checkbox(
                                      value: _isNoteSelected(
                                        note,
                                      ),
                                      onChanged: (_) =>
                                          _toggleNote(
                                        note,
                                      ),
                                    )
                                  : const Icon(
    Icons.note,
    color: Colors.orange,
    size: 36,
  ),
                              title: Text(
                                note.title.isEmpty
                                    ? 'Untitled Note'
                                    : note.title,
                              ),
                              subtitle: Text(
  note.content,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
),

trailing: !_selectionMode
    ? PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'restore') {
            await _noteRepository.restore(note.id!);

            if (!mounted) return;

            ModuleSnackBar.show(
              context,
              'Note restored',
            );

            await _loadRecycleBin();
          }

          if (value == 'delete') {
            final confirm =
                await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete Forever'),
                        content: const Text(
                          'This note will be permanently deleted.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ) ??
                    false;

            if (!confirm) return;

            await _noteRepository.deleteForever(
              note.id!,
            );

            if (!mounted) return;

            ModuleSnackBar.show(
              context,
              'Note deleted permanently',
            );

            await _loadRecycleBin();
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: 'restore',
            child: Text('Restore'),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Text('Delete Forever'),
          ),
        ],
      )
    : null,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],

                      if (_deletedDocuments.isNotEmpty) ...[
                        const Text(
                          'Documents',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        ..._deletedDocuments.map(
                          (document) => Card(
                            margin: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            child: ListTile(
                              onLongPress: () {
                                if (!_selectionMode) {
                                  _enterSelectionMode();
                                }
                                _toggleDocument(
                                  document,
                                );
                              },
                              onTap: () async {
  if (_selectionMode) {
    _toggleDocument(document);
    return;
  }

  final result = await OpenFilex.open(
    document.path,
  );

  if (result.type != ResultType.done) {
    if (!mounted) return;

    ModuleSnackBar.show(
      context,
      result.message,
    );
  }
},
                              leading: _selectionMode
                                  ? Checkbox(
                                      value:
                                          _isDocumentSelected(
                                        document,
                                      ),
                                      onChanged: (_) =>
                                          _toggleDocument(
                                        document,
                                      ),
                                    )
                                  : const Icon(
    Icons.picture_as_pdf,
    color: Colors.red,
    size: 36,
  ),
                              title: Text(
                                document.name,
                              ),
                              subtitle: Text(
  document.path,
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
),

trailing: !_selectionMode
    ? PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'restore') {
            await _documentRepository.restore(
              document.id!,
            );

            if (!mounted) return;

            ModuleSnackBar.show(
              context,
              'Document restored',
            );

            await _loadRecycleBin();
          }

          if (value == 'delete') {
            final confirm =
                await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete Forever'),
                        content: const Text(
                          'This document will be permanently deleted.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ) ??
                    false;

            if (!confirm) return;

            await _documentRepository
                .deleteForever(document.id!);

            if (!mounted) return;

            ModuleSnackBar.show(
              context,
              'Document deleted permanently',
            );

            await _loadRecycleBin();
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: 'restore',
            child: Text('Restore'),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Text('Delete Forever'),
          ),
        ],
      )
    : null,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                                            if (_deletedMedia.isNotEmpty) ...[
                        const Text(
                          'Media',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        ..._deletedMedia.map(
                          (media) => Card(
                            margin: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child: ListTile(
                              onLongPress: () {
                                if (!_selectionMode) {
                                  _enterSelectionMode();
                                }
                                _toggleMedia(media);
                              },
                              onTap: () async {
  if (_selectionMode) {
    _toggleMedia(media);
    return;
  }

  if (media.isImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(media.name),
          ),
          body: PhotoView(
            imageProvider: FileImage(
              File(media.path),
            ),
          ),
        ),
      ),
    );
  } else {
    final result = await OpenFilex.open(
      media.path,
    );

    if (result.type != ResultType.done) {
      if (!mounted) return;

      ModuleSnackBar.show(
        context,
        result.message,
      );
    }
  }
},
                              leading: _selectionMode
                                  ? Checkbox(
                                      value:
                                          _isMediaSelected(
                                        media,
                                      ),
                                      onChanged: (_) =>
                                          _toggleMedia(
                                        media,
                                      ),
                                    )
                                  : SizedBox(
                                      width: 56,
                                      height: 56,
                                      child:
                                          MediaThumbnail(
                                        item: media,
                                      ),
                                    ),
                              title: Text(
                                media.name,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  Text(
                                    media.type
                                        .toUpperCase(),
                                  ),
                                  if (media.deletedAt !=
                                      null)
                                    Text(
                                      'Deleted: ${media.deletedAt}',
                                      style:
                                          const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: !_selectionMode
                                  ? PopupMenuButton<
                                      String>(
                                      onSelected:
                                          (value) async {
                                        if (value ==
                                            'restore') {
                                          await _mediaRepository
                                              .restore(
                                            media.id!,
                                          );

                                          if (!mounted) {
                                            return;
                                          }

                                          ModuleSnackBar
                                              .show(
                                            context,
                                            'Media restored',
                                          );

                                          await _loadRecycleBin();
                                        }
                                        

                                        if (value ==
                                            'delete') {
                                          final confirm =
                                              await showDialog<
                                                  bool>(
                                                    context:
                                                        context,
                                                    builder:
                                                        (
                                                          context,
                                                        ) {
                                                          return AlertDialog(
                                                            title:
                                                                const Text(
                                                              'Delete Forever',
                                                            ),
                                                            content:
                                                                const Text(
                                                              'This media will be deleted permanently.',
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed:
                                                                    () {
                                                                  Navigator.pop(
                                                                    context,
                                                                    false,
                                                                  );
                                                                },
                                                                child:
                                                                    const Text(
                                                                  'Cancel',
                                                                ),
                                                              ),
                                                              FilledButton(
                                                                onPressed:
                                                                    () {
                                                                  Navigator.pop(
                                                                    context,
                                                                    true,
                                                                  );
                                                                },
                                                                child:
                                                                    const Text(
                                                                  'Delete',
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                  ) ??
                                                  false;

                                          if (!confirm) {
                                            return;
                                          }

                                          await _mediaRepository
                                              .deleteForever(
                                            media.id!,
                                          );

                                          if (!mounted) {
                                            return;
                                          }

                                          ModuleSnackBar
                                              .show(
                                            context,
                                            'Media deleted permanently',
                                          );

                                          await _loadRecycleBin();
                                        }
                                      },
                                      itemBuilder:
                                          (context) => [
                                        const PopupMenuItem(
                                          value:
                                              'restore',
                                          child: Text(
                                            'Restore',
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value:
                                              'delete',
                                          child: Text(
                                            'Delete Forever',
                                          ),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
if (_deletedLinks.isNotEmpty) ...[
  const Text(
    'Links',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  const SizedBox(height: 12),

  ..._deletedLinks.map(
    (link) => Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onLongPress: () {
          if (!_selectionMode) {
            _enterSelectionMode();
          }
          _toggleLink(link);
        },
        onTap: () async {
  if (_selectionMode) {
    _toggleLink(link);
    return;
  }

  final uri = Uri.parse(link.url);

  if (!await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  )) {
    if (!mounted) return;

    ModuleSnackBar.show(
      context,
      'Unable to open link',
    );
  }
},
        leading: _selectionMode
            ? Checkbox(
                value: _isLinkSelected(link),
                onChanged: (_) => _toggleLink(link),
              )
            : const Icon(
    Icons.link,
    color: Colors.blue,
    size: 36,
  ),
        title: Text(
          link.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          link.url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: !_selectionMode
            ? PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'restore') {
                    await _linkRepository.restore(link.id!);

                    if (!mounted) return;

                    ModuleSnackBar.show(
                      context,
                      'Link restored',
                    );

                    await _loadRecycleBin();
                  }

                  if (value == 'delete') {
                    await _linkRepository.deleteForever(link.id!);

                    if (!mounted) return;

                    ModuleSnackBar.show(
                      context,
                      'Link deleted permanently',
                    );

                    await _loadRecycleBin();
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'restore',
                    child: Text('Restore'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete Forever'),
                  ),
                ],
              )
            : null,
      ),
    ),
  ),

  const SizedBox(height: 24),
],
if (_deletedChats.isNotEmpty) ...[
  const Text(
    'WhatsApp',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  const SizedBox(height: 12),

  ..._deletedChats.map(
    (chat) => Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onLongPress: () {
          if (!_selectionMode) {
            _enterSelectionMode();
          }
          _toggleChat(chat);
        },
        onTap: () async {
  if (_selectionMode) {
    _toggleChat(chat);
    return;
  }

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => WhatsappChatScreen(
        chat: chat,
      ),
    ),
  );

  if (!mounted) return;

  await _loadRecycleBin();
},
        leading: _selectionMode
            ? Checkbox(
                value: _isChatSelected(chat),
                onChanged: (_) => _toggleChat(chat),
              )
            : const Icon(
    Icons.chat,
    color: Colors.green,
    size: 36,
  ),
        title: Text(
          chat.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          chat.path,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: !_selectionMode
            ? PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'restore') {
                    await _whatsappRepository.restore(chat.id!);

                    if (!mounted) return;

                    ModuleSnackBar.show(
                      context,
                      'Chat restored',
                    );

                    await _loadRecycleBin();
                  }

                  if (value == 'delete') {
                    await _whatsappRepository.deleteForever(chat.id!);

                    if (!mounted) return;

                    ModuleSnackBar.show(
                      context,
                      'Chat deleted permanently',
                    );

                    await _loadRecycleBin();
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'restore',
                    child: Text('Restore'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete Forever'),
                  ),
                ],
              )
            : null,
      ),
    ),
  ),

  const SizedBox(height: 24),
],
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }
}