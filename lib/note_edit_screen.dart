import 'package:flutter/material.dart';
import 'package:notepad/note.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/note.dart';

class NoteEditScreen extends StatefulWidget {
  final Note note;

  NoteEditScreen({required this.note});

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final supabase = Supabase.instance.client;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  List<String> _contentHistory = [];
  int _historyIndex = -1;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _addToHistory(widget.note.content);
  }

  void _addToHistory(String content) {
    if (_historyIndex < _contentHistory.length - 1) {
      _contentHistory = _contentHistory.sublist(0, _historyIndex + 1);
    }
    _contentHistory.add(content);
    _historyIndex = _contentHistory.length - 1;
  }

  void _undo() {
    if (_historyIndex > 0) {
      _historyIndex--;
      _contentController.text = _contentHistory[_historyIndex];
      setState(() {});
    }
  }

  Future<void> _saveNote() async {
    widget.note.title = _titleController.text;
    widget.note.content = _contentController.text;

    try {
      await supabase.from('notes').upsert(widget.note.toJson());
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan catatan: $error')),
      );
    }
  }

  Future<void> _scanText() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        final inputImage = InputImage.fromFilePath(image.path);
        final textDetector = GoogleMlKit.vision.textRecognizer();
        final RecognizedText recognizedText =
            await textDetector.processImage(inputImage);

        String scannedText = recognizedText.text;
        setState(() {
          _contentController.text += '\n' + scannedText;
          _addToHistory(_contentController.text);
        });

        await textDetector.close();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Izin kamera diperlukan untuk memindai teks')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.undo, color: Colors.black),
            onPressed: _undo,
          ),
          IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.black),
            onPressed: _scanText,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Judul',
                border: InputBorder.none,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: 'Tulis catatan Anda di sini...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  maxLines: null,
                  expands: true,
                  onChanged: (value) {
                    _addToHistory(value);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveNote,
        icon: Icon(Icons.save),
        label: Text('Simpan'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
