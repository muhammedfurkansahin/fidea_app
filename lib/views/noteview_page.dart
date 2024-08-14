import 'package:fidea_app/controller/general_controller.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NoteView extends StatelessWidget {
  final GeneralController _controller = GeneralController();
  final String? noteId;
  final int plusCount;
  final int minusCount;

   NoteView({
    super.key,
    this.noteId,
    required this.plusCount,
    required this.minusCount,
  });
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Not Görüntüle'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                '${((plusCount / (plusCount + minusCount)) * 100).toStringAsFixed(1)}% Bitti',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
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
            final formattedNotes = _controller.formatNotesForDisplay(notes);

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
}
