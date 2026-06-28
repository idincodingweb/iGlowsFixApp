import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/salon.dart';
import '../../widgets/glow_widgets.dart';

class SalonDetailScreen extends StatelessWidget {
  final Salon salon;
  const SalonDetailScreen({super.key, required this.salon});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(salon.name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(colors: [
                AppColors.primarySoft.withValues(alpha: .6),
                AppColors.cream,
              ]),
            ),
            alignment: Alignment.center,
            child: Text(salon.emoji, style: const TextStyle(fontSize: 96)),
          ),
          const SizedBox(height: 16),
          Text(salon.name,
              style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          Row(
            children: [
              const Icon(Icons.location_on,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 4),
              Text('${salon.area} • ${salon.distanceKm} km',
                  style: tt.bodySmall),
              const Spacer(),
              const Icon(Icons.star_rounded,
                  color: Colors.amber, size: 18),
              Text(' ${salon.rating}', style: tt.bodyMedium),
            ],
          ),
          const SizedBox(height: 16),
          Text('Services',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final s in salon.services) PillChip(label: s, selected: true)],
          ),
          const SizedBox(height: 20),
          GlowCard(
            child: Row(
              children: [
                const Icon(Icons.payments_outlined,
                    color: AppColors.primary),
                const SizedBox(width: 10),
                Text('Tier harga: ${salon.priceTier}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Booking ke ${salon.name} ✨')),
              );
            },
            icon: const Icon(Icons.calendar_month),
            label: const Text('Book Appointment'),
          ),
        ],
      ),
    );
  }
}
