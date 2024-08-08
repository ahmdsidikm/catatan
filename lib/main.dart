import 'package:flutter/material.dart';
import 'package:notepad/note_list_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/note_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hncwdmtgkeviymrjalge.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhuY3dkbXRna2V2aXltcmphbGdlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjAwMDAyNDcsImV4cCI6MjAzNTU3NjI0N30.rg_pIRJkjgE5oVrc_A0_A2ujLEkckZ7VkZOGFnPjq5c',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NoteListScreen(),
    );
  }
}
