import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product.dart';
import '../../widgets/glow_widgets.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(product.brand)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primarySoft.withValues(alpha: .6),
                    AppColors.cream,
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (_, child, prog) {
                        if (prog == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Text(
                        product.emoji,
                        style: const TextStyle(fontSize: 110),
                      ),
                    )
                  : Text(product.emoji,
                      style: const TextStyle(fontSize: 110)),
            ),
          ),
          const SizedBox(height: 16),
          Text(product.category,
              style: tt.bodySmall?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w700)),
          Text(product.name,
              style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              Text(' ${product.rating}', style: tt.bodyMedium),
              const Spacer(),
              Text('Rp ${product.price.toStringAsFixed(0)}',
                  style: tt.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 14),
          Text(product.description, style: tt.bodyMedium),
          const SizedBox(height: 16),
          Text('Cocok untuk',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in product.goodFor)
                PillChip(label: t, selected: true)
            ],
          ),
          const SizedBox(height: 24),
          GlowCard(
            gradient: LinearGradient(
              colors: [
                AppColors.primarySoft.withValues(alpha: .5),
                AppColors.cream,
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Direkomendasikan Glowy untuk skin profile kamu ✨',
                    style: tt.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Disimpan ke favorit 💖')));
                  },
                  icon: const Icon(Icons.favorite_outline),
                  label: const Text('Wishlist'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Fitur ini akan segera tersedia')));
                  },
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Beli Sekarang'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
