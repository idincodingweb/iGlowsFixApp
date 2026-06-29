import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'analyzer_service.dart';

/// History entry untuk skin analyzer.
class AnalyzerEntry {
  final String id;
  final AnalyzerResult result;
  final DateTime createdAt;
  final String? imageBase64; // thumbnail (compressed)
  final String? imageMime;

  const AnalyzerEntry({
    required this.id,
    required this.result,
    required this.createdAt,
    this.imageBase64,
    this.imageMime,
  });

  static AnalyzerEntry fromMap(String id, Map<String, dynamic> m) {
    DateTime t;
    final raw = m['createdAt'];
    if (raw is Timestamp) {
      t = raw.toDate();
    } else if (raw is DateTime) {
      t = raw;
    } else if (raw is String) {
      t = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      t = DateTime.now();
    }
    return AnalyzerEntry(
      id: id,
      result: AnalyzerResult.fromMap(m),
      createdAt: t,
      imageBase64: m['imageBase64'] as String?,
      imageMime: m['imageMime'] as String?,
    );
  }
}

/// History service untuk hasil skin analyzer (untuk progress chart
/// & before/after compare).
///
/// Firestore: users/{uid}/skin_analyses/{autoId}
class AnalyzerHistoryService {
  AnalyzerHistoryService._();
  static final AnalyzerHistoryService instance = AnalyzerHistoryService._();

  bool get _ready =>
      Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null;

  CollectionReference<Map<String, dynamic>>? get _col {
    if (!_ready) return null;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('skin_analyses');
  }

  Future<String?> save(
    AnalyzerResult r, {
    String? imageBase64,
    String mime = 'image/jpeg',
  }) async {
    final c = _col;
    if (c == null) return null;
    try {
      final doc = await c.add({
        ...r.toMap(),
        if (imageBase64 != null) 'imageBase64': imageBase64,
        if (imageBase64 != null) 'imageMime': mime,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      debugPrint('AnalyzerHistoryService.save error: $e');
      return null;
    }
  }

  Stream<List<AnalyzerEntry>> stream({int limit = 60}) {
    final c = _col;
    if (c == null) return const Stream<List<AnalyzerEntry>>.empty();
    return c
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AnalyzerEntry.fromMap(d.id, d.data()))
            .toList());
  }

  Future<List<AnalyzerEntry>> list({int limit = 60}) async {
    final c = _col;
    if (c == null) return const [];
    try {
      final snap = await c
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snap.docs
          .map((d) => AnalyzerEntry.fromMap(d.id, d.data()))
          .toList();
    } catch (e) {
      debugPrint('AnalyzerHistoryService.list error: $e');
      return const [];
    }
  }
}
