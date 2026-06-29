import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/article.dart';
import '../../services/sample_articles.dart';
import '../../widgets/glow_widgets.dart';
import 'article_detail_screen.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  String _selected = 'All';

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final list = _selected == 'All'
        ? sampleArticles
        : sampleArticles.where((a) => a.category == _selected).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text('iGlows',
                style: tt.titleMedium?.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w800)),
            Text('Glow Beautiful, Everywhere',
                style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Beauty & Wellness',
                    style: tt.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Row(
                  children: [
                    Text('Artikel inspiratif buat kamu',
                        style: tt.bodySmall
                            ?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(width: 4),
                    const Text('📖✨'),
                  ],
                ),
              ],
            ),
          ),
          // Kategori horizontal scroll
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: articleCategories.length,
              itemBuilder: (_, i) {
                final c = articleCategories[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: PillChip(
                    label: c,
                    selected: _selected == c,
                    onTap: () => setState(() => _selected = c),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text('Belum ada artikel di kategori ini ✨',
                        style: tt.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _ArticleCard(article: list[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlowCard(
        padding: const EdgeInsets.all(10),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(article: article))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                article.imageUrl,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                loadingBuilder: (c, child, p) {
                  if (p == null) return child;
                  return Container(
                    width: 96,
                    height: 96,
                    color: AppColors.primarySoft.withValues(alpha: .3),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  width: 96, height: 96,
                  color: AppColors.primarySoft.withValues(alpha: .4),
                  alignment: Alignment.center,
                  child: const Text('📰', style: TextStyle(fontSize: 32)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft.withValues(alpha: .5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(article.category,
                        style: tt.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11)),
                  ),
                  const SizedBox(height: 6),
                  Text(article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700, height: 1.3)),
                  const SizedBox(height: 4),
                  Text(article.excerpt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodySmall
                          ?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.schedule,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(article.readMinutes,
                          style: tt.bodySmall?.copyWith(
                              color: AppColors.textSecondary, fontSize: 11)),
                      const SizedBox(width: 8),
                      const Icon(Icons.person_outline,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(article.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.bodySmall?.copyWith(
                                color: AppColors.textSecondary, fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
