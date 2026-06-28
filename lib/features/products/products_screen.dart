import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/product.dart';
import '../../services/sample_data.dart';
import '../../widgets/glow_widgets.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _cat = 'All';
  String _query = '';

  List<Product> get _filtered {
    var list = sampleProducts;
    if (_cat != 'All') {
      list = list.where((p) => p.category == _cat).toList();
    }
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.brand.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cats = ['All', 'Cleanser', 'Toner', 'Serum', 'Moisturizer', 'Sunscreen', 'Mask'];

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                for (final c in cats)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: PillChip(
                      label: c,
                      selected: _cat == c,
                      onTap: () => setState(() => _cat = c),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: .68,
              ),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final p = _filtered[i];
                return GlowCard(
                  padding: const EdgeInsets.all(12),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: p))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft.withValues(alpha: .35),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(p.emoji,
                              style: const TextStyle(fontSize: 52)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(p.category,
                          style: tt.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                      Text(p.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: Colors.amber),
                          Text(' ${p.rating}',
                              style: tt.bodySmall),
                          const Spacer(),
                          Text('Rp${(p.price/1000).toStringAsFixed(0)}K',
                              style: tt.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary)),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
