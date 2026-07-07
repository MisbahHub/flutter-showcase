import 'package:flutter/material.dart';
import 'package:quick_note/models/note_model.dart';

class NotesProvider with ChangeNotifier{
  List<NoteModel> notes=[];

  void addNote(NoteModel note){
    notes.add(note);
    notifyListeners();
  }

  void deleteNote(NoteModel note){
    notes.remove(note);
    notifyListeners();
  }

}