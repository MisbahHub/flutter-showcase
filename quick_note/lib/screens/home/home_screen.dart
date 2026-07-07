import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_note/models/note_model.dart';
import 'package:quick_note/providers/notes/notes_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Text('My Notes'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, '/addNote');
          },
          icon: Icon(Icons.add),
          label: Text('Add Note'),
        ),
      body: Consumer<NotesProvider>(
        builder: (context,provider,child) {
          return provider.notes.isEmpty? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.note_alt_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 10),
                Text(
                  'No Notes Yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tap + to add a note',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
              : ListView(
            children: [
              for(NoteModel note in provider.notes)
                Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                      note.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(note.desc),
                    trailing: IconButton(
                      onPressed: () {
                        provider.deleteNote(note);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
            ],
          );
        }
      )
    );
  }
}
