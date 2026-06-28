import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/notification_item.dart';

/// Service notifikasi berbasis Firestore per-user.
///
/// Collection: users/{uid}/notifications/{autoId}
/// Field: title, body, kind, createdAt (Timestamp), read (bool)
///
/// Fail-safe: tanpa Firebase / tanpa user, stream balikin list kosong.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  bool get _ready =>
      Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null;

  CollectionReference<Map<String, dynamic>>? get _col {
    if (!_ready) return null;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications');
  }

  Stream<List<NotificationItem>> stream({int limit = 50}) {
    final c = _col;
    if (c == null) {
      return const Stream<List<NotificationItem>>.empty();
    }
    return c
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => NotificationItem.fromMap(d.id, d.data()))
            .toList());
  }

  /// Tambah notifikasi baru. Hindari duplikat berdasarkan [dedupeKey]
  /// (mis. 'streak_3', 'analyzer_2026-06-28') — kalau key sama udah ada
  /// dalam 24 jam terakhir, di-skip.
  Future<void> add({
    required String title,
    required String body,
    required String kind,
    String? dedupeKey,
  }) async {
    final c = _col;
    if (c == null) return;
    try {
      if (dedupeKey != null) {
        // Dedupe permanen berdasarkan key (mis. 'routine_night_2026-06-28').
        // Sengaja TIDAK pakai filter waktu agar tidak butuh composite index.
        final dup = await c
            .where('dedupeKey', isEqualTo: dedupeKey)
            .limit(1)
            .get();
        if (dup.docs.isNotEmpty) return;
      }
      await c.add({
        'title': title,
        'body': body,
        'kind': kind,
        'dedupeKey': dedupeKey,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('NotificationService.add error: $e');
    }
  }

  Future<void> markAllRead() async {
    final c = _col;
    if (c == null) return;
    try {
      final snap = await c.where('read', isEqualTo: false).limit(100).get();
      if (snap.docs.isEmpty) return;
      final batch = FirebaseFirestore.instance.batch();
      for (final d in snap.docs) {
        batch.update(d.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('NotificationService.markAllRead error: $e');
    }
  }

  Future<int> unreadCount() async {
    final c = _col;
    if (c == null) return 0;
    try {
      final snap = await c.where('read', isEqualTo: false).limit(20).get();
      return snap.docs.length;
    } catch (_) {
      return 0;
    }
  }

  /// Notifikasi welcome dibuat 1x untuk user baru.
  Future<void> seedWelcomeIfNeeded() async {
    await add(
      title: 'Selamat datang di iGlows ✨',
      body:
          'Mulai isi profil kulit kamu & jalankan rutinitas pertama biar skor glow-nya naik.',
      kind: 'welcome',
      dedupeKey: 'welcome_v1',
    );
  }
}
