import 'dart:math';

class AnalyzerResult {
  final String skinType;
  final int hydration;
  final int oiliness;
  final int acne;
  final int darkSpots;
  final int wrinkles;
  final int overallScore;
  final List<String> recommendations;

  const AnalyzerResult({
    required this.skinType,
    required this.hydration,
    required this.oiliness,
    required this.acne,
    required this.darkSpots,
    required this.wrinkles,
    required this.overallScore,
    required this.recommendations,
  });

  String severity(int v, {bool reverse = false}) {
    // reverse=true: lebih tinggi makin buruk (acne/dark spots/wrinkles/oiliness)
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
  /// Simulasi scan kulit dengan delay & hasil random tapi reasonable.
  Future<AnalyzerResult> scan() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    final r = Random();
    final hydration = 55 + r.nextInt(35);
    final oiliness = 30 + r.nextInt(40);
    final acne = 10 + r.nextInt(30);
    final darkSpots = 15 + r.nextInt(40);
    final wrinkles = 10 + r.nextInt(30);

    final score = ((hydration * 0.4) + ((100 - oiliness) * 0.15) +
            ((100 - acne) * 0.2) + ((100 - darkSpots) * 0.15) +
            ((100 - wrinkles) * 0.1))
        .round();

    final types = ['Normal','Kering','Berminyak','Kombinasi','Sensitif'];
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
}
