import 'package:cloud_firestore/cloud_firestore.dart';

/// Pesan chat Glowy. Sekarang punya `id` + optional `imageBase64`
/// untuk dukung attach foto wajah ke konsultasi (Groq Vision).
class ChatMessage {
  final String id;
  final String text;
  final bool fromUser;
  final DateTime time;
  final String? imageBase64; // raw base64 (tanpa prefix data:)
  final String? imageMime; // mis. 'image/jpeg'

  ChatMessage({
    String? id,
    required this.text,
    required this.fromUser,
    DateTime? time,
    this.imageBase64,
    this.imageMime,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        time = time ?? DateTime.now();

  bool get hasImage => imageBase64 != null && imageBase64!.isNotEmpty;

  Map<String, dynamic> toMap() => {
        'text': text,
        'fromUser': fromUser,
        'createdAt': FieldValue.serverTimestamp(),
        if (imageBase64 != null) 'imageBase64': imageBase64,
        if (imageMime != null) 'imageMime': imageMime,
      };

  static ChatMessage fromMap(String id, Map<String, dynamic> m) {
    DateTime t;
    final raw = m['createdAt'];
    if (raw is Timestamp) {
      t = raw.toDate();
    } else if (raw is DateTime) {
      t = raw;
    } else {
      t = DateTime.now();
    }
    return ChatMessage(
      id: id,
      text: (m['text'] as String?) ?? '',
      fromUser: (m['fromUser'] as bool?) ?? false,
      time: t,
      imageBase64: m['imageBase64'] as String?,
      imageMime: m['imageMime'] as String?,
    );
  }
}
