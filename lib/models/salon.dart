class Salon {
  final String id;
  final String name;
  final String area;
  final double distanceKm;
  final double rating;
  final List<String> services;
  final String priceTier; // $, $$, $$$
  final String emoji;

  /// Alamat lengkap untuk ditampilkan di detail salon.
  final String address;

  /// Koordinat opsional untuk embed Google Maps.
  /// Default 0,0 = fallback aman; kalau 0,0, UI fallback pakai pencarian
  /// berdasarkan [name] + [area] (`?q=nama+area`).
  final double lat;
  final double lng;

  const Salon({
    required this.id,
    required this.name,
    required this.area,
    required this.distanceKm,
    required this.rating,
    required this.services,
    required this.priceTier,
    required this.emoji,
    this.address = '',
    this.lat = 0,
    this.lng = 0,
  });

  bool get hasCoords => lat != 0 || lng != 0;
}
