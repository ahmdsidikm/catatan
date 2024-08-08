import 'package:uuid/uuid.dart';

class Note {
  String id;
  String title;
  String content;
  DateTime createdAt;

  Note({
    required this.title,
    required this.content,
    DateTime? createdAt,
  })  : id = const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    )..id = json['id'] as String;
  }
}
