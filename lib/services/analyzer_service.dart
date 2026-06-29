import 'dart:math';

import 'groq_service.dart';
import '../models/skin_profile.dart';

class AnalyzerResult {
  final String skinType;
  final int hydration;
  final int oiliness;
  final int acne;
  final int darkSpots;
  final int wrinkles;
  final int overallScore;
  final List<String> recommendations;
  final bool fromAi; // true = hasil real dari Groq Vision

  const AnalyzerResult({
    required this.skinType,
    required this.hydration,
    required this.oiliness,
    required this.acne,
    required this.darkSpots,
    required this.wrinkles,
    required this.overallScore,
    required this.recommendations,
    this.fromAi = false,
  });

  Map<String, dynamic> toMap() => {
        'skinType': skinType,
        'hydration': hydration,
        'oiliness': oiliness,
        'acne': acne,
        'darkSpots': darkSpots,
        'wrinkles': wrinkles,
        'overallScore': overallScore,
        'recommendations': recommendations,
        'fromAi': fromAi,
      };

  static AnalyzerResult fromMap(Map<String, dynamic> m) {
    int i(String k) => (m[k] as num?)?.toInt() ?? 0;
    final recs = (m['recommendations'] as List?)?.cast<String>() ??
        const <String>[];
    return AnalyzerResult(
      skinType: (m['skinType'] as String?) ?? 'Normal',
      hydration: i('hydration'),
      oiliness: i('oiliness'),
      acne: i('acne'),
      darkSpots: i('darkSpots'),
      wrinkles: i('wrinkles'),
      overallScore: i('overallScore'),
      recommendations: recs,
      fromAi: (m['fromAi'] as bool?) ?? false,
    );
  }

  String severity(int v, {bool reverse = false}) {
    if (reverse) {
      if (v < 25) return 'Ringan';
      if (v < 50) return 'Sedang';
      return 'Tinggi';
    } else {
      if (v >= 70) return 'Good';
      if (v >= 45) return 'Moderate';
      return 'Low';
    }
  }
}

class AnalyzerService {
  AnalyzerService({GroqService? groq}) : _groq = groq ?? GroqService();
  final GroqService _groq;

  void dispose() => _groq.dispose();

  /// Scan REAL via Groq Vision. Lempar exception kalau gagal — caller
  /// (UI) yang putusin tampil error / fallback ke [simulate].
  Future<AnalyzerResult> scanWithImage({
    required String imageBase64,
    String mime = 'image/jpeg',
    SkinProfile? profile,
  }) async {
    final json = await _groq.analyzeSkin(
      imageBase64: imageBase64,
      mime: mime,
      profile: profile,
    );
    int clamp(num? v) => (v ?? 0).toInt().clamp(0, 100);
    final recsRaw = json['recommendations'];
    final recs = recsRaw is List
        ? recsRaw.map((e) => e.toString()).toList()
        : <String>['Pakai sunscreen tiap hari ✨'];
    return AnalyzerResult(
      skinType: (json['skinType'] as String?) ?? 'Normal',
      hydration: clamp(json['hydration'] as num?),
      oiliness: clamp(json['oiliness'] as num?),
      acne: clamp(json['acne'] as num?),
      darkSpots: clamp(json['darkSpots'] as num?),
      wrinkles: clamp(json['wrinkles'] as num?),
      overallScore: clamp(json['overallScore'] as num?),
      recommendations: recs,
      fromAi: true,
    );
  }

  /// Simulasi (dipakai kalau tanpa foto / fallback offline).
  Future<AnalyzerResult> simulate() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    final r = Random();
    final hydration = 55 + r.nextInt(35);
    final oiliness = 30 + r.nextInt(40);
    final acne = 10 + r.nextInt(30);
    final darkSpots = 15 + r.nextInt(40);
    final wrinkles = 10 + r.nextInt(30);

    final score = ((hydration * 0.4) +
            ((100 - oiliness) * 0.15) +
            ((100 - acne) * 0.2) +
            ((100 - darkSpots) * 0.15) +
            ((100 - wrinkles) * 0.1))
        .round();

    final types = ['Normal', 'Kering', 'Berminyak', 'Kombinasi', 'Sensitif'];
    final type = types[r.nextInt(types.length)];

    return AnalyzerResult(
      skinType: type,
      hydration: hydration,
      oiliness: oiliness,
      acne: acne,
      darkSpots: darkSpots,
      wrinkles: wrinkles,
      overallScore: score,
      recommendations: [
        if (hydration < 70) 'Tambah hydrating serum di rutinitas pagi',
        if (oiliness > 50) 'Coba gel moisturizer & toner BHA 2x/minggu',
        if (acne > 25) 'Tambah serum niacinamide untuk redain jerawat',
        if (darkSpots > 35) 'Pakai vitamin C pagi & SPF 50 wajib',
        if (wrinkles > 25) 'Retinol low-dose 2x/minggu di malam hari',
        'Jangan skip sunscreen — kuncinya glow jangka panjang ✨',
      ],
    );
  }

  /// Legacy entry — masih dipanggil di beberapa tempat lama.
  Future<AnalyzerResult> scan() => simulate();
}
