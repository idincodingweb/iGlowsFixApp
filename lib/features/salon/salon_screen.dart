import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../models/salon.dart';
import '../../services/sample_data.dart';
import '../../widgets/glow_widgets.dart';
import '../../widgets/map_embed.dart';
import 'salon_detail_screen.dart';

class SalonScreen extends StatefulWidget {
  const SalonScreen({super.key});

  @override
  State<SalonScreen> createState() => _SalonScreenState();
}

class _SalonScreenState extends State<SalonScreen> {
  String _cat = 'Facial';

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    const cats = ['Facial', 'Massage', 'Hair', 'Nails', 'Spa'];
    final list = sampleSalons
        .where((s) => _cat == 'All' || s.services.contains(_cat))
        .toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text('Salon Maps',
              style:
                  tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          Row(
            children: [
              Text('Discover beauty near you',
                  style: tt.bodySmall
                      ?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(width: 4),
              const Text('✨'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
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
          const SizedBox(height: 12),
          // Map embed Google Maps (tanpa API key) — fokus salon terdekat.
          _SalonsMapEmbed(salons: list),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _openMaps(list),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Buka di Google Maps'),
            ),
          ),
          const SectionHeader(title: 'Nearby Salons ✨', action: 'See all'),
          ...list.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlowCard(
                  padding: const EdgeInsets.all(10),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => SalonDetailScreen(salon: s))),
                  child: Row(
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.primarySoft.withValues(alpha: .4),
                        ),
                        alignment: Alignment.center,
                        child:
                            Text(s.emoji, style: const TextStyle(fontSize: 40)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name,
                                style: tt.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft
                                        .withValues(alpha: .4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star_rounded,
                                          color: Colors.amber, size: 12),
                                      Text(' ${s.rating}',
                                          style: tt.bodySmall),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('${s.distanceKm} km',
                                    style: tt.bodySmall?.copyWith(
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.services.join(' • '),
                              style: tt.bodySmall?.copyWith(
                                  color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          const Icon(Icons.favorite_outline,
                              color: AppColors.primary),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _book(context, s),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(80, 32),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            child: const Text('Book Now'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _book(BuildContext context, Salon s) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking ke ${s.name} sedang diproses ✨')),
    );
  }

  Future<void> _openMaps(List<Salon> list) async {
    final first = list.firstWhere(
      (s) => s.hasCoords,
      orElse: () => list.isNotEmpty ? list.first : sampleSalons.first,
    );
    final uri = first.hasCoords
        ? Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${first.lat},${first.lng}')
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('${first.name} ${first.area}')}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('openMaps error: $e');
    }
  }
}

/// Map embed kecil — center ke salon pertama yg punya koordinat.
class _SalonsMapEmbed extends StatelessWidget {
  final List<Salon> salons;
  const _SalonsMapEmbed({required this.salons});

  @override
  Widget build(BuildContext context) {
    final s = salons.firstWhere(
      (x) => x.hasCoords,
      orElse: () => salons.isNotEmpty ? salons.first : sampleSalons.first,
    );
    if (s.hasCoords) {
      return MapEmbed.coords(lat: s.lat, lng: s.lng, zoom: 13, height: 200);
    }
    return MapEmbed.query(
        query: '${s.name} ${s.area}', zoom: 13, height: 200);
  }
}
