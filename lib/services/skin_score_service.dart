import 'dart:math';

import '../models/routine_step.dart';
import '../models/skin_profile.dart';
import 'local_store.dart';

class SkinMetric {
  final String label;
  final int value; // 0..100
  const SkinMetric({required this.label, required this.value});

  /// "Excellent" / "Great" / "Good" / "Fair" / "Low" / "-"
  String get rating {
    if (value <= 0) return '-';
    if (value >= 85) return 'Excellent';
    if (value >= 72) return 'Great';
    if (value >= 58) return 'Good';
    if (value >= 42) return 'Fair';
    return 'Low';
  }
}

class DailySkinScore {
  final int overall; // 0..100 (0 = belum ada data)
  final String caption;
  final SkinMetric hydration;
  final SkinMetric smoothness;
  final SkinMetric brightness;
  final DateTime computedAt;
  final bool hasAnalyzer;
  final bool hasData;

  const DailySkinScore({
    required this.overall,
    required this.caption,
    required this.hydration,
    required this.smoothness,
    required this.brightness,
    required this.computedAt,
    required this.hasAnalyzer,
    required this.hasData,
  });

  Map<String, dynamic> toJson() => {
        'overall': overall,
        'caption': caption,
        'hydration': hydration.value,
        'smoothness': smoothness.value,
        'brightness': brightness.value,
        'computedAt': computedAt.toIso8601String(),
        'hasAnalyzer': hasAnalyzer,
        'hasData': hasData,
      };

  static DailySkinScore fromJson(Map<String, dynamic> j) => DailySkinScore(
        overall: (j['overall'] as num?)?.toInt() ?? 0,
        caption: (j['caption'] as String?) ?? 'Belum ada data',
        hydration: SkinMetric(
            label: 'Hydration',
            value: (j['hydration'] as num?)?.toInt() ?? 0),
        smoothness: SkinMetric(
            label: 'Smoothness',
            value: (j['smoothness'] as num?)?.toInt() ?? 0),
        brightness: SkinMetric(
            label: 'Brightness',
            value: (j['brightness'] as num?)?.toInt() ?? 0),
        computedAt: DateTime.tryParse(j['computedAt'] as String? ?? '') ??
            DateTime.now(),
        hasAnalyzer: (j['hasAnalyzer'] as bool?) ?? false,
        hasData: (j['hasData'] as bool?) ??
            (((j['overall'] as num?)?.toInt() ?? 0) > 0),
      );
}

/// Menghitung Daily Skin Score berdasarkan data REAL user:
/// - SkinProfile (opsional)
/// - Routine completion hari ini (morning + night)
/// - Streak (loyalitas)
/// - Hasil analyzer terakhir (opsional)
///
/// Jika user belum punya sinyal apa pun (profil belum diisi, belum scan,
/// belum mengerjakan satu pun step rutin, streak 0) maka score balikin
/// `hasData=false` dan semua nilai 0 — UI menampilkan placeholder, BUKAN
/// angka dummy.
class SkinScoreService {
  SkinScoreService({LocalStore? store}) : _store = store ?? LocalStore();
  final LocalStore _store;

  Future<DailySkinScore> compute({bool useCache = true}) async {
    if (useCache) {
      final cached = await _store.loadDailyScore();
      if (cached != null) {
        try {
          final s = DailySkinScore.fromJson(cached);
          final now = DateTime.now();
          if (s.computedAt.year == now.year &&
              s.computedAt.month == now.month &&
              s.computedAt.day == now.day) {
            return s;
          }
        } catch (_) {/* recompute */}
      }
    }

    final profile = await _store.loadProfile();
    final done = await _store.loadRoutineDone();
    final streak = await _store.getStreak();
    final analyzer = await _store.loadLastAnalyzer();

    final hasData = profile != null ||
        analyzer != null ||
        done.isNotEmpty ||
        streak > 0;

    if (!hasData) {
      final empty = DailySkinScore(
        overall: 0,
        caption: 'Belum ada data',
        hydration: const SkinMetric(label: 'Hydration', value: 0),
        smoothness: const SkinMetric(label: 'Smoothness', value: 0),
        brightness: const SkinMetric(label: 'Brightness', value: 0),
        computedAt: DateTime.now(),
        hasAnalyzer: false,
        hasData: false,
      );
      await _store.saveDailyScore(empty.toJson());
      return empty;
    }

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
    // Base berasal dari profil — kalau profil belum diisi, base = 0.
    final baseByType = <String, int>{
      'Normal': 50,
      'Kombinasi': 46,
      'Berminyak': 44,
      'Kering': 42,
      'Sensitif': 40,
    };
    final base =
        profile == null ? 0 : (baseByType[profile.skinType] ?? 45);
    final concernPenalty = (profile?.concerns.length ?? 0) * 2;

    final totalSteps = morningRoutine.length + nightRoutine.length;
    final doneMorning =
        morningRoutine.where((s) => doneIds.contains(s.id)).length;
    final doneNight =
        nightRoutine.where((s) => doneIds.contains(s.id)).length;
    final routineRatio =
        ((doneMorning + doneNight) / totalSteps).clamp(0.0, 1.0);
    final routineBonus = (routineRatio * 28).round(); // 0..28

    final streakBonus = (min(streak, 14) * 0.8).round(); // 0..11

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
      overall = ((overall * 0.5) + (analyzerOverall * 0.5)).round();
    }
    overall = overall.clamp(1, 100);

    int hydration = _metricBase(
      hasProfile: profile != null,
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
      hasProfile: profile != null,
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
      hasProfile: profile != null,
      profileBoost: (profile?.concerns
                  .any((c) => c.toLowerCase().contains('kusam')) ??
              false)
          ? -8
          : 0,
      analyzerValue: hasAnalyzer ? aBright : null,
      routineSignals: [
        if (doneIds.contains('serum_am')) 8,
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
      hasData: true,
    );
  }

  int _metricBase({
    required bool hasProfile,
    required int profileBoost,
    required int? analyzerValue,
    required List<int> routineSignals,
    required int streak,
  }) {
    int v = hasProfile ? (40 + profileBoost) : 0;
    for (final s in routineSignals) {
      v += s;
    }
    v += (min(streak, 10) * 0.8).round();
    if (analyzerValue != null) {
      v = ((v * 0.5) + (analyzerValue * 0.5)).round();
    }
    if (v <= 0) return 0;
    return v.clamp(5, 100);
  }

  String _caption(int v) {
    if (v <= 0) return 'Belum ada data';
    if (v >= 85) return 'Glowing';
    if (v >= 72) return 'Great';
    if (v >= 58) return 'Good';
    if (v >= 45) return 'Fair';
    return 'Needs care';
  }
}
