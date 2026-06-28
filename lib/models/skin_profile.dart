class SkinProfile {
  final String? name;
  final String skinType; // Normal, Kering, Berminyak, Kombinasi, Sensitif
  final List<String> concerns; // Jerawat, Komedo, Kusam, dll
  final int age;
  final String goal;

  const SkinProfile({
    this.name,
    this.skinType = 'Kombinasi',
    this.concerns = const [],
    this.age = 22,
    this.goal = 'Glowing & Sehat',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'skinType': skinType,
        'concerns': concerns,
        'age': age,
        'goal': goal,
      };

  factory SkinProfile.fromJson(Map<String, dynamic> j) => SkinProfile(
        name: j['name'] as String?,
        skinType: (j['skinType'] as String?) ?? 'Kombinasi',
        concerns: ((j['concerns'] as List?) ?? const []).cast<String>(),
        age: (j['age'] as num?)?.toInt() ?? 22,
        goal: (j['goal'] as String?) ?? 'Glowing & Sehat',
      );

  SkinProfile copyWith({
    String? name,
    String? skinType,
    List<String>? concerns,
    int? age,
    String? goal,
  }) =>
      SkinProfile(
        name: name ?? this.name,
        skinType: skinType ?? this.skinType,
        concerns: concerns ?? this.concerns,
        age: age ?? this.age,
        goal: goal ?? this.goal,
      );
}
