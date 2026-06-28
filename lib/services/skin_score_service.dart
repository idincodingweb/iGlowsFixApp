import 'dart:math';

import '../models/routine_step.dart';
import '../models/skin_profile.dart';
import 'local_store.dart';

class SkinMetric {
  final String label;
  final int value; // 0..100
  const SkinMetric({required this.label, required this.value});

  /// "Excellent" / "Great" / "Good" / "Fair" / "Low"
  String get rating {
    if (value >= 85) return 'Excellent';
    if (value >= 72) return 'Great';
    if (value >= 58) return 'Good';
    if (value >= 42) return 'Fair';
    return 'Low';
  }
}

class DailySkinScore {
  final int overall; // 0..100
  final String caption; // Glowing / Great / Good / Needs care
  final SkinMetric hydration;
  final SkinMetric smoothness;
  final SkinMetric brightness;
  final DateTime computedAt;
  final bool hasAnalyzer;

  const DailySkinScore({
    required this.overall,
    required this.caption,
    required this.hydration,
    required this.smoothness,
    required this.brightness,
    required this.computedAt,
    required this.hasAnalyzer,
  });

  Map<String, dynamic> toJson() => {
        'overall': overall,
        'caption': caption,
        'hydration': hydration.value,
        'smoothness': smoothness.value,
        'brightness': brightness.value,
        'computedAt': computedAt.toIso8601String(),
        'hasAnalyzer': hasAnalyzer,
      };

  static DailySkinScore fromJson(Map<String, dynamic> j) => DailySkinScore(
        overall: (j['overall'] as num?)?.toInt() ?? 60,
        caption: (j['caption'] as String?) ?? 'Good',
        hydration: SkinMetric(
            label: 'Hydration',
            value: (j['hydration'] as num?)?.toInt() ?? 60),
        smoothness: SkinMetric(
            label: 'Smoothness',
            value: (j['smoothness'] as num?)?.toInt() ?? 60),
        brightness: SkinMetric(
            label: 'Brightness',
            value: (j['brightness'] as num?)?.toInt() ?? 60),
        computedAt:
            DateTime.tryParse(j['computedAt'] as String? ?? '') ?? DateTime.now(),
        hasAnalyzer: (j['hasAnalyzer'] as bool?) ?? false,
      );
}

/// Menghitung Daily Skin Score secara deterministik dari:
/// - SkinProfile (jenis kulit & jumlah concern)
/// - Routine completion hari ini (morning + night)
/// - Streak (loyalitas)
/// - Hasil analyzer terakhir (jika ada, di-blend)
class SkinScoreService {
  SkinScoreService({LocalStore? store}) : _store = store ?? LocalStore();
  final LocalStore _store;

  Future<DailySkinScore> compute({bool useCache = true}) async {
    if (useCache) {
      final cached = await _store.loadDailyScore();
      if (cached != null) {
        try {
          final s = DailySkinScore.fromJson(cached);
          // Cache valid kalau dihitung di hari yg sama.
          final now = DateTime.now();
          if (s.computedAt.year == now.year &&
              s.computedAt.month == now.month &&
              s.computedAt.day == now.day) {
            // Tetap recompute kalau jumlah routine done berubah signifikan.
            final done = await _store.loadRoutineDone();
            final total = morningRoutine.length + nightRoutine.length;
            final expectedBonus =
                ((done.length / total).clamp(0.0, 1.0) * 100).round();
            // Cek loose: kalau hydration berubah > 5 anggap stale.
            if ((s.hydration.value - expectedBonus).abs() < 60) {
              return s;
            }
          }
        } catch (_) {/* recompute */}
      }
    }

    final profile = await _store.loadProfile();
    final done = await _store.loadRoutineDone();
    final streak = await _store.getStreak();
    final analyzer = await _store.loadLastAnalyzer();
    final score = _calc(
      profile: profile,
      doneIds: done,
      streak: streak,
      analyzer: analyzer,
    );
    await _store.saveDailyScore(score.toJson());
    return score;
  }

  DailySkinScore _calc({
    required SkinProfile? profile,
    required Set<String> doneIds,
    required int streak,
    required Map<String, dynamic>? analyzer,
  }) {
    // ---- Base dari jenis kulit ----
    final baseByType = <String, int>{
      'Normal': 72,
      'Kombinasi': 66,
      'Berminyak': 62,
      'Kering': 60,
      'Sensitif': 58,
    };
    final base = baseByType[profile?.skinType ?? 'Kombinasi'] ?? 65;
    final concernPenalty = (profile?.concerns.length ?? 0) * 2;

    // ---- Routine factor ----
    final totalSteps = morningRoutine.length + nightRoutine.length;
    final doneMorning =
        morningRoutine.where((s) => doneIds.contains(s.id)).length;
    final doneNight =
        nightRoutine.where((s) => doneIds.contains(s.id)).length;
    final routineRatio =
        ((doneMorning + doneNight) / totalSteps).clamp(0.0, 1.0);
    final routineBonus = (routineRatio * 18).round(); // 0..18

    // ---- Streak factor ----
    final streakBonus = (min(streak, 14) * 0.7).round(); // 0..10

    // ---- Analyzer blend ----
    int analyzerOverall = 0;
    int aHydration = 0;
    int aSmooth = 0;
    int aBright = 0;
    bool hasAnalyzer = false;
    if (analyzer != null) {
      hasAnalyzer = true;
      analyzerOverall = (analyzer['overallScore'] as num?)?.toInt() ?? 0;
      aHydration = (analyzer['hydration'] as num?)?.toInt() ?? 0;
      final acne = (analyzer['acne'] as num?)?.toInt() ?? 0;
      final wrinkles = (analyzer['wrinkles'] as num?)?.toInt() ?? 0;
      final darkSpots = (analyzer['darkSpots'] as num?)?.toInt() ?? 0;
      aSmooth = (100 - ((acne + wrinkles) / 2)).round();
      aBright = (100 - darkSpots);
    }

    int overall = base - concernPenalty + routineBonus + streakBonus;
    if (hasAnalyzer) {
      overall = ((overall * 0.55) + (analyzerOverall * 0.45)).round();
    }
    overall = overall.clamp(30, 100);

    // ---- Per-metric ----
    int hydration = _metricBase(
      profileBoost: profile?.skinType == 'Kering' ? -8 : 0,
      analyzerValue: hasAnalyzer ? aHydration : null,
      routineSignals: [
        if (doneIds.contains('toner_am')) 6,
        if (doneIds.contains('moist_am')) 8,
        if (doneIds.contains('toner_pm')) 4,
        if (doneIds.contains('moist_pm')) 6,
      ],
      streak: streak,
    );

    int smoothness = _metricBase(
      profileBoost: (profile?.concerns
                  .any((c) => c.toLowerCase().contains('jerawat')) ??
              false)
          ? -6
          : 0,
      analyzerValue: hasAnalyzer ? aSmooth : null,
      routineSignals: [
        if (doneIds.contains('serum_am')) 6,
        if (doneIds.contains('serum_pm')) 8,
        if (doneIds.contains('cleanser_am')) 4,
        if (doneIds.contains('cleanser_pm')) 6,
      ],
      streak: streak,
    );

    int brightness = _metricBase(
      profileBoost: (profile?.concerns
                  .any((c) => c.toLowerCase().contains('kusam')) ??
              false)
          ? -8
          : 0,
      analyzerValue: hasAnalyzer ? aBright : null,
      routineSignals: [
        if (doneIds.contains('serum_am')) 8, // Vit C
        if (doneIds.contains('spf_am')) 10,
        if (doneIds.contains('moist_pm')) 3,
      ],
      streak: streak,
    );

    return DailySkinScore(
      overall: overall,
      caption: _caption(overall),
      hydration: SkinMetric(label: 'Hydration', value: hydration),
      smoothness: SkinMetric(label: 'Smoothness', value: smoothness),
      brightness: SkinMetric(label: 'Brightness', value: brightness),
      computedAt: DateTime.now(),
      hasAnalyzer: hasAnalyzer,
    );
  }

  int _metricBase({
    required int profileBoost,
    required int? analyzerValue,
    required List<int> routineSignals,
    required int streak,
  }) {
    int v = 60 + profileBoost;
    for (final s in routineSignals) {
      v += s;
    }
    v += (min(streak, 10) * 0.6).round();
    if (analyzerValue != null) {
      v = ((v * 0.55) + (analyzerValue * 0.45)).round();
    }
    return v.clamp(20, 100);
  }

  String _caption(int v) {
    if (v >= 85) return 'Glowing';
    if (v >= 72) return 'Great';
    if (v >= 58) return 'Good';
    if (v >= 45) return 'Fair';
    return 'Needs care';
  }
}
