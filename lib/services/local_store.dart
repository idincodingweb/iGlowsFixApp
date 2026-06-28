import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/skin_profile.dart';

/// Penyimpanan lokal (shared_preferences) untuk profil kulit,
/// status rutinitas harian, streak, hasil analyzer terakhir, dan cache
/// daily skin score. Aman dipakai tanpa backend.
class LocalStore {
  static const _kProfile = 'skin_profile_v1';
  static const _kRoutinePrefix = 'routine_'; // routine_yyyy-MM-dd -> jsonList
  static const _kStreak = 'streak_count';
  static const _kLastDay = 'streak_last_day';
  static const _kLastAnalyzer = 'last_analyzer_v1';
  static const _kScorePrefix = 'score_'; // score_yyyy-MM-dd -> json

  Future<SharedPreferences> get _p async => SharedPreferences.getInstance();

  // ---------- Skin profile ----------
  Future<SkinProfile?> loadProfile() async {
    final p = await _p;
    final raw = p.getString(_kProfile);
    if (raw == null) return null;
    try {
      return SkinProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(SkinProfile profile) async {
    final p = await _p;
    await p.setString(_kProfile, jsonEncode(profile.toJson()));
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
    final raw = p.getStringList('$_kRoutinePrefix${_dayKey(day)}') ?? const [];
    return raw.toSet();
  }

  Future<void> saveRoutineDone(Set<String> ids, [DateTime? day]) async {
    final p = await _p;
    await p.setStringList('$_kRoutinePrefix${_dayKey(day)}', ids.toList());
  }

  // ---------- Streak ----------
  Future<int> getStreak() async {
    final p = await _p;
    return p.getInt(_kStreak) ?? 0;
  }

  Future<int> bumpStreakIfNeeded() async {
    final p = await _p;
    final today = _dayKey();
    final last = p.getString(_kLastDay);
    if (last == today) return p.getInt(_kStreak) ?? 0;

    final yesterday =
        _dayKey(DateTime.now().subtract(const Duration(days: 1)));
    int current = p.getInt(_kStreak) ?? 0;
    current = (last == yesterday) ? current + 1 : 1;
    await p.setInt(_kStreak, current);
    await p.setString(_kLastDay, today);
    return current;
  }

  // ---------- Last analyzer result ----------
  Future<Map<String, dynamic>?> loadLastAnalyzer() async {
    final p = await _p;
    final raw = p.getString(_kLastAnalyzer);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLastAnalyzer(Map<String, dynamic> data) async {
    final p = await _p;
    final payload = {
      ...data,
      'savedAt': DateTime.now().toIso8601String(),
    };
    await p.setString(_kLastAnalyzer, jsonEncode(payload));
  }

  // ---------- Cached daily score ----------
  Future<Map<String, dynamic>?> loadDailyScore([DateTime? day]) async {
    final p = await _p;
    final raw = p.getString('$_kScorePrefix${_dayKey(day)}');
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDailyScore(Map<String, dynamic> data, [DateTime? day]) async {
    final p = await _p;
    await p.setString('$_kScorePrefix${_dayKey(day)}', jsonEncode(data));
  }
}
