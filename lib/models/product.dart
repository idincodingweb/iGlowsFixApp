class Product {
  final String id;
  final String name;
  final String brand;
  final String category; // Cleanser, Toner, Serum, Moisturizer, Sunscreen, Mask
  final String description;
  final double price; // IDR
  final double rating;
  final List<String> goodFor; // skin types
  final String emoji;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.price,
    required this.rating,
    required this.goodFor,
    required this.emoji,
  });
}
