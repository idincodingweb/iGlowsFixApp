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

  /// Parse dari JSON admin dashboard (https://iglowsadmin.vercel.app/articles).
  /// Semua field punya default aman supaya artikel lama / field hilang tidak crash UI.
  factory Article.fromJson(Map<String, dynamic> json) {
    String s(dynamic v, [String fallback = '']) =>
        v == null ? fallback : v.toString();

    final rawSections = json['sections'];
    final sections = <ArticleSection>[];
    if (rawSections is List) {
      for (final item in rawSections) {
        if (item is Map) {
          sections.add(ArticleSection(
            heading: s(item['heading']),
            body: s(item['body']),
          ));
        }
      }
    }

    final rawTags = json['tags'];
    final tags = <String>[];
    if (rawTags is List) {
      for (final t in rawTags) {
        final str = s(t);
        if (str.isNotEmpty) tags.add(str);
      }
    }

    return Article(
      id: s(json['id'], s(json['_id'])),
      title: s(json['title']),
      category: s(json['category'], 'Lifestyle'),
      excerpt: s(json['excerpt']),
      imageUrl: s(json['imageUrl'], s(json['image_url'])),
      author: s(json['author'], 'iGlows Editorial'),
      readMinutes: s(json['readMinutes'], s(json['read_minutes'], '3 min')),
      publishedAt: s(json['publishedAt'], s(json['published_at'])),
      sections: sections,
      tags: tags,
    );
  }
}

/// Satu bagian (heading + paragraf) dalam artikel.
class ArticleSection {
  final String heading;
  final String body;
  const ArticleSection({required this.heading, required this.body});
}
