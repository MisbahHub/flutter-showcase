import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_note/providers/notes/notes_provider.dart';
import 'package:quick_note/screens/add_note/add_note_screen.dart';
import 'package:quick_note/screens/home/home_screen.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context)=> NotesProvider(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          routes: {
            '/' :(context) => HomeScreen(),
            '/addNote' : (context) => AddNoteScreen()
          }
      )
    );
  }
}
