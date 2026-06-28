import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Sinkronisasi data progress user ke Firestore.
///
/// Struktur:
///   users/{uid}/routine_logs/{yyyy-MM-dd}   -> { done: [..], updatedAt }
///   users/{uid}/skin_analyses/{autoId}      -> hasil analyzer
///   users/{uid}/daily_scores/{yyyy-MM-dd}   -> snapshot skin score
///   users/{uid}/notifications/{autoId}      -> notifikasi user
///
/// Semua method fail-safe: kalau Firebase belum siap / user belum login,
/// operasi diabaikan tanpa throw. Tujuannya supaya UI tetap jalan offline.
class FirestoreSync {
  FirestoreSync._();
  static final FirestoreSync instance = FirestoreSync._();

  bool get _ready {
    if (Firebase.apps.isEmpty) return false;
    return FirebaseAuth.instance.currentUser != null;
  }

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final u = uid;
    if (u == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(u);
  }

  String _dayKey(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  Future<void> saveRoutineDone(Set<String> done, {DateTime? day}) async {
    if (!_ready) return;
    try {
      await _userDoc!
          .collection('routine_logs')
          .doc(_dayKey(day ?? DateTime.now()))
          .set({
        'done': done.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FirestoreSync.saveRoutineDone error: $e');
    }
  }

  Future<Set<String>?> loadRoutineDone({DateTime? day}) async {
    if (!_ready) return null;
    try {
      final snap = await _userDoc!
          .collection('routine_logs')
          .doc(_dayKey(day ?? DateTime.now()))
          .get();
      if (!snap.exists) return null;
      final raw = snap.data()?['done'];
      if (raw is List) return raw.map((e) => e.toString()).toSet();
      return null;
    } catch (e) {
      debugPrint('FirestoreSync.loadRoutineDone error: $e');
      return null;
    }
  }

  Future<void> saveStreak(int streak) async {
    if (!_ready) return;
    try {
      await _userDoc!.set({
        'streak': streak,
        'streakUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FirestoreSync.saveStreak error: $e');
    }
  }

  Future<int?> loadStreak() async {
    if (!_ready) return null;
    try {
      final snap = await _userDoc!.get();
      final v = snap.data()?['streak'];
      if (v is num) return v.toInt();
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveAnalyzer(Map<String, dynamic> data) async {
    if (!_ready) return;
    try {
      final col = _userDoc!.collection('skin_analyses');
      await col.add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // simpan juga snapshot terakhir di doc user buat akses cepat
      await _userDoc!.set({
        'lastAnalyzer': data,
        'lastAnalyzerAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FirestoreSync.saveAnalyzer error: $e');
    }
  }

  Future<Map<String, dynamic>?> loadLastAnalyzer() async {
    if (!_ready) return null;
    try {
      final snap = await _userDoc!.get();
      final v = snap.data()?['lastAnalyzer'];
      if (v is Map) return Map<String, dynamic>.from(v);
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDailyScore(Map<String, dynamic> data,
      {DateTime? day}) async {
    if (!_ready) return;
    try {
      await _userDoc!
          .collection('daily_scores')
          .doc(_dayKey(day ?? DateTime.now()))
          .set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FirestoreSync.saveDailyScore error: $e');
    }
  }
}
