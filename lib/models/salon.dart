class Salon {
  final String id;
  final String name;
  final String area;
  final double distanceKm;
  final double rating;
  final List<String> services;
  final String priceTier; // $, $$, $$$
  final String emoji;

  const Salon({
    required this.id,
    required this.name,
    required this.area,
    required this.distanceKm,
    required this.rating,
    required this.services,
    required this.priceTier,
    required this.emoji,
  });
}
