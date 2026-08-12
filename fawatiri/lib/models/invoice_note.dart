import 'package:cloud_firestore/cloud_firestore.dart';

enum NoteTag { general, rejection }

class InvoiceNote {
  final String text;
  final NoteTag tag;
  final DateTime createdAt;

  const InvoiceNote({
    required this.text,
    required this.tag,
    required this.createdAt,
  });

  factory InvoiceNote.fromMap(Map<String, dynamic> m) => InvoiceNote(
    text: m['text'] as String,
    tag: NoteTag.values.byName(m['tag'] as String),
    createdAt: (m['createdAt'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toMap() => {
    'text': text,
    'tag': tag.name,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
