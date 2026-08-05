import 'package:flutter/material.dart';

import '../models/note.dart';
import '../repositories/note_repository.dart';

class NoteDetailsScreen extends StatefulWidget {
  final Note? note;

  const NoteDetailsScreen({
    super.key,
    this.note,
  });

  @override
  State<NoteDetailsScreen> createState() =>
      _NoteDetailsScreenState();
}

class _NoteDetailsScreenState
    extends State<NoteDetailsScreen> {
  final NoteRepository repository = NoteRepository();

  late TextEditingController titleController;
  late TextEditingController contentController;

  bool isEditing = false;

  @override
  void initState() {
    super.initState();

    isEditing = widget.note == null;

    titleController = TextEditingController(
      text: widget.note?.title ?? "",
    );

    contentController = TextEditingController(
      text: widget.note?.content ?? "",
    );
  }

  Future<void> saveChanges() async {
    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      return;
    }

    if (widget.note == null) {
      final note = Note(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
      );

      await repository.addNote(note);
    } else {
      final updatedNote = widget.note!.copy(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
      );

      await repository.updateNote(updatedNote);
    }

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.note == null
              ? "New Note"
              : "Note",
        ),
        actions: [
          IconButton(
            icon: Icon(
              isEditing
                  ? Icons.save
                  : Icons.edit,
            ),
            onPressed: () async {
              if (isEditing) {
                await saveChanges();
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              readOnly: !isEditing,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: TextField(
                controller: contentController,
                readOnly: !isEditing,
                expands: true,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: "Content",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}