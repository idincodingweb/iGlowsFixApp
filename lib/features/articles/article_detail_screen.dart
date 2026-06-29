import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/article.dart';
import '../../widgets/glow_widgets.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    article.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.primarySoft,
                      alignment: Alignment.center,
                      child: const Text('📰',
                          style: TextStyle(fontSize: 64)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: .35),
                          Colors.transparent,
                          Colors.black.withValues(alpha: .55),
                        ],
                        stops: const [0, 0.5, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft.withValues(alpha: .5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(article.category,
                            style: tt.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Text(article.publishedAt,
                          style: tt.bodySmall
                              ?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(article.title,
                      style: tt.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800, height: 1.3)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primarySoft,
                        child: Icon(Icons.person,
                            color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(article.author,
                                style: tt.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600)),
                            Text('${article.readMinutes} baca',
                                style: tt.bodySmall?.copyWith(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Disimpan ke favorit ✨')),
                          );
                        },
                        icon: const Icon(Icons.bookmark_outline,
                            color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GlowCard(
                    padding: const EdgeInsets.all(14),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primarySoft.withValues(alpha: .35),
                        AppColors.primarySoft.withValues(alpha: .15),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(article.excerpt,
                              style: tt.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic, height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final s in article.sections) ...[
                    Text(s.heading,
                        style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                    const SizedBox(height: 6),
                    Text(s.body,
                        style: tt.bodyMedium?.copyWith(height: 1.6)),
                    const SizedBox(height: 18),
                  ],
                  if (article.tags.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final t in article.tags)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primarySoft.withValues(alpha: .3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('#$t',
                                style: tt.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
