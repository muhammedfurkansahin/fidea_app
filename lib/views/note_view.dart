import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NoteView extends StatelessWidget {
  final String? noteId;

  const NoteView({super.key, this.noteId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Not Görüntüle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<String>(
          future: fetchNoteContent(noteId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Hata: ${snapshot.error}'));
            }

            final notes = snapshot.data ?? '';
            final formattedNotes = formatNotesForDisplay(notes);

            return SingleChildScrollView(
              child: RichText(
                text: TextSpan(
                  children: formattedNotes,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<String> fetchNoteContent(String? noteId) async {
    if (noteId == null) return '';

    final ref = FirebaseDatabase.instance.ref('notes/$noteId');
    final snapshot = await ref.get();
    final data = snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      return data['NOTE'] as String;
    } else {
      return '';
    }
  }

  List<TextSpan> formatNotesForDisplay(String notes) {
    final lines = notes.split('\n');
    final spans = <TextSpan>[];

    for (var line in lines) {
      if (line.isEmpty) continue;

      if (RegExp(r'^\d+').hasMatch(line)) {
        // Sayı ile başlayan başlıklar
        spans.add(
          TextSpan(
            text: '$line\n\n',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
        );
      } else if (line.startsWith('*')) {
        // * ile başlayan başlıklar
        spans.add(
          TextSpan(
            text: '$line\n\n',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );
      } else {
        // Diğer satırlar
        spans.add(
          TextSpan(
            text: '$line\n\n',
            style: const TextStyle(fontSize: 20), // Varsayılan font boyutu
          ),
        );
      }
    }

    return spans;
  }
}
