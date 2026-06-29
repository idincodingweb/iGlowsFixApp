import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';

/// Manager session konsultasi Glowy.
///
/// Struktur Firestore:
///   users/{uid}/consultations/{sessionId}
///     - title, lastMessage, createdAt, updatedAt, msgCount
///   users/{uid}/consultations/{sessionId}/messages/{msgId}
///     - text, fromUser, createdAt, imageBase64?, imageMime?
///
/// Semua method fail-safe: jika offline/tanpa login, kembalikan
/// nilai kosong tanpa throw.
class ConsultationService {
  ConsultationService._();
  static final ConsultationService instance = ConsultationService._();

  bool get _ready =>
      Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null;

  CollectionReference<Map<String, dynamic>>? get _sessions {
    if (!_ready) return null;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('consultations');
  }

  /// Stream list session, terbaru duluan.
  Stream<List<ConsultationSession>> streamSessions({int limit = 30}) {
    final c = _sessions;
    if (c == null) return const Stream<List<ConsultationSession>>.empty();
    return c
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ConsultationSession.fromMap(d.id, d.data()))
            .toList());
  }

  /// Stream pesan untuk satu session.
  Stream<List<ChatMessage>> streamMessages(String sessionId, {int limit = 200}) {
    final c = _sessions;
    if (c == null) return const Stream<List<ChatMessage>>.empty();
    return c
        .doc(sessionId)
        .collection('messages')
        .orderBy('createdAt')
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatMessage.fromMap(d.id, d.data())).toList());
  }

  /// Bikin session baru. Return id session, atau null kalau gagal/offline.
  Future<String?> createSession({String title = 'Konsultasi baru'}) async {
    final c = _sessions;
    if (c == null) return null;
    try {
      final doc = await c.add({
        'title': title,
        'lastMessage': '',
        'msgCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      debugPrint('ConsultationService.createSession error: $e');
      return null;
    }
  }

  /// Simpan satu pesan + update metadata session.
  Future<void> appendMessage(String sessionId, ChatMessage msg) async {
    final c = _sessions;
    if (c == null) return;
    try {
      final sessionRef = c.doc(sessionId);
      await sessionRef.collection('messages').add(msg.toMap());
      final preview = msg.text.isEmpty && msg.hasImage
          ? '📷 Foto'
          : (msg.text.length > 80 ? '${msg.text.substring(0, 80)}…' : msg.text);
      await sessionRef.set({
        'lastMessage': preview,
        'updatedAt': FieldValue.serverTimestamp(),
        'msgCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('ConsultationService.appendMessage error: $e');
    }
  }

  /// Update judul session (dipakai setelah pesan user pertama).
  Future<void> setTitle(String sessionId, String title) async {
    final c = _sessions;
    if (c == null) return;
    try {
      final t = title.length > 60 ? '${title.substring(0, 60)}…' : title;
      await c.doc(sessionId).set({
        'title': t,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('ConsultationService.setTitle error: $e');
    }
  }

  Future<void> deleteSession(String sessionId) async {
    final c = _sessions;
    if (c == null) return;
    try {
      // Hapus subcollection messages dulu (batch).
      final msgs = await c.doc(sessionId).collection('messages').limit(400).get();
      final batch = FirebaseFirestore.instance.batch();
      for (final d in msgs.docs) {
        batch.delete(d.reference);
      }
      batch.delete(c.doc(sessionId));
      await batch.commit();
    } catch (e) {
      debugPrint('ConsultationService.deleteSession error: $e');
    }
  }
}

class ConsultationSession {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime updatedAt;
  final int msgCount;

  const ConsultationSession({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
    required this.msgCount,
  });

  static ConsultationSession fromMap(String id, Map<String, dynamic> m) {
    DateTime t;
    final raw = m['updatedAt'];
    if (raw is Timestamp) {
      t = raw.toDate();
    } else if (raw is DateTime) {
      t = raw;
    } else {
      t = DateTime.now();
    }
    return ConsultationSession(
      id: id,
      title: (m['title'] as String?) ?? 'Konsultasi',
      lastMessage: (m['lastMessage'] as String?) ?? '',
      updatedAt: t,
      msgCount: (m['msgCount'] as num?)?.toInt() ?? 0,
    );
  }
}
