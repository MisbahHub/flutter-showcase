import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_note/models/note_model.dart';
import 'package:quick_note/providers/notes/notes_provider.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {

  TextEditingController title= TextEditingController();
  TextEditingController desc= TextEditingController();
  GlobalKey<FormState> globalKey= GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Note'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: globalKey,
          child: Column(
            children: [
              TextFormField(
                controller: title,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter title';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: desc,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (globalKey.currentState!.validate()) {
                      NoteModel note = NoteModel(
                        title.text,
                        desc.text,
                      );

                      Provider.of<NotesProvider>(
                        context,
                        listen: false,
                      ).addNote(note);

                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save'),
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}
