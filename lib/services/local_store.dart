import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/skin_profile.dart';
import 'firestore_sync.dart';

/// Penyimpanan lokal (shared_preferences) per-user.
///
/// Semua key di-prefix dengan UID Firebase agar ganti akun di device
/// yang sama tidak membawa progress user sebelumnya. Untuk user yang
/// belum login (mis. onboarding), prefix `guest_` dipakai.
///
/// Setiap write juga mirror ke Firestore via [FirestoreSync] secara
/// fire-and-forget — gagal sync tidak menggagalkan operasi lokal.
class LocalStore {
  static const _kProfileBase = 'skin_profile_v1';
  static const _kRoutinePrefix = 'routine_';
  static const _kStreak = 'streak_count';
  static const _kLastDay = 'streak_last_day';
  static const _kLastAnalyzer = 'last_analyzer_v1';
  static const _kScorePrefix = 'score_';

  Future<SharedPreferences> get _p async => SharedPreferences.getInstance();

  String get _uidScope {
    try {
      if (Firebase.apps.isEmpty) return 'guest';
      final u = FirebaseAuth.instance.currentUser;
      return u?.uid ?? 'guest';
    } catch (_) {
      return 'guest';
    }
  }

  String _k(String key) => '${_uidScope}_$key';

  // ---------- Skin profile ----------
  Future<SkinProfile?> loadProfile() async {
    final p = await _p;
    final raw = p.getString(_k(_kProfileBase));
    if (raw == null) return null;
    try {
      return SkinProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(SkinProfile profile) async {
    final p = await _p;
    await p.setString(_k(_kProfileBase), jsonEncode(profile.toJson()));
  }

  // ---------- Helpers ----------
  String _dayKey([DateTime? d]) {
    final n = d ?? DateTime.now();
    final m = n.month.toString().padLeft(2, '0');
    final day = n.day.toString().padLeft(2, '0');
    return '${n.year}-$m-$day';
  }

  // ---------- Routine done set ----------
  Future<Set<String>> loadRoutineDone([DateTime? day]) async {
    final p = await _p;
    final key = _k('$_kRoutinePrefix${_dayKey(day)}');
    final raw = p.getStringList(key) ?? const [];
    final local = raw.toSet();
    // Hydrate dari Firestore di background biar device lain juga sync.
    // (await singkat agar UI bisa pakai data terbaru kalau tersedia.)
    try {
      final remote = await FirestoreSync.instance.loadRoutineDone(day: day);
      if (remote != null && remote.isNotEmpty) {
        final merged = {...local, ...remote};
        await p.setStringList(key, merged.toList());
        return merged;
      }
    } catch (_) {/* offline-safe */}
    return local;
  }

  Future<void> saveRoutineDone(Set<String> ids, [DateTime? day]) async {
    final p = await _p;
    await p.setStringList(
        _k('$_kRoutinePrefix${_dayKey(day)}'), ids.toList());
    // mirror ke Firestore (fail-safe)
    FirestoreSync.instance.saveRoutineDone(ids, day: day);
  }

  // ---------- Streak ----------
  Future<int> getStreak() async {
    final p = await _p;
    final local = p.getInt(_k(_kStreak)) ?? 0;
    if (local > 0) return local;
    try {
      final remote = await FirestoreSync.instance.loadStreak();
      if (remote != null && remote > 0) {
        await p.setInt(_k(_kStreak), remote);
        return remote;
      }
    } catch (_) {}
    return local;
  }

  Future<int> bumpStreakIfNeeded() async {
    final p = await _p;
    final today = _dayKey();
    final last = p.getString(_k(_kLastDay));
    if (last == today) return p.getInt(_k(_kStreak)) ?? 0;

    final yesterday =
        _dayKey(DateTime.now().subtract(const Duration(days: 1)));
    int current = p.getInt(_k(_kStreak)) ?? 0;
    current = (last == yesterday) ? current + 1 : 1;
    await p.setInt(_k(_kStreak), current);
    await p.setString(_k(_kLastDay), today);
    FirestoreSync.instance.saveStreak(current);
    return current;
  }

  // ---------- Last analyzer result ----------
  Future<Map<String, dynamic>?> loadLastAnalyzer() async {
    final p = await _p;
    final raw = p.getString(_k(_kLastAnalyzer));
    if (raw != null) {
      try {
        return jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }
    try {
      final remote = await FirestoreSync.instance.loadLastAnalyzer();
      if (remote != null) {
        await p.setString(_k(_kLastAnalyzer), jsonEncode(remote));
        return remote;
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveLastAnalyzer(Map<String, dynamic> data) async {
    final p = await _p;
    final payload = {
      ...data,
      'savedAt': DateTime.now().toIso8601String(),
    };
    await p.setString(_k(_kLastAnalyzer), jsonEncode(payload));
    FirestoreSync.instance.saveAnalyzer(payload);
  }

  // ---------- Cached daily score ----------
  Future<Map<String, dynamic>?> loadDailyScore([DateTime? day]) async {
    final p = await _p;
    final raw = p.getString(_k('$_kScorePrefix${_dayKey(day)}'));
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDailyScore(Map<String, dynamic> data,
      [DateTime? day]) async {
    final p = await _p;
    await p.setString(
        _k('$_kScorePrefix${_dayKey(day)}'), jsonEncode(data));
    FirestoreSync.instance.saveDailyScore(data, day: day);
  }
}
