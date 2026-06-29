/// Model artikel kesehatan & kecantikan.
class Article {
  final String id;
  final String title;
  final String category;
  final String excerpt;
  final String imageUrl;
  final String author;
  final String readMinutes;
  final String publishedAt;
  final List<ArticleSection> sections;
  final List<String> tags;

  const Article({
    required this.id,
    required this.title,
    required this.category,
    required this.excerpt,
    required this.imageUrl,
    required this.author,
    required this.readMinutes,
    required this.publishedAt,
    required this.sections,
    this.tags = const [],
  });
}

/// Satu bagian (heading + paragraf) dalam artikel.
class ArticleSection {
  final String heading;
  final String body;
  const ArticleSection({required this.heading, required this.body});
}
