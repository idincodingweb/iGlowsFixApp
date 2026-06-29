import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/analyzer_history_service.dart';
import '../../widgets/glow_widgets.dart';

class AnalyzerCompareScreen extends StatefulWidget {
  const AnalyzerCompareScreen({super.key});

  @override
  State<AnalyzerCompareScreen> createState() => _AnalyzerCompareScreenState();
}

class _AnalyzerCompareScreenState extends State<AnalyzerCompareScreen> {
  AnalyzerEntry? _before;
  AnalyzerEntry? _after;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Before / After')),
      body: StreamBuilder<List<AnalyzerEntry>>(
        stream: AnalyzerHistoryService.instance.stream(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? const [];
          if (items.length < 2) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                  'Butuh minimal 2 hasil scan untuk membandingkan.\nLakukan scan lagi dulu ya 💖',
                  textAlign: TextAlign.center),
            ));
          }
          // default: paling lama vs paling baru
          _before ??= items.last;
          _after ??= items.first;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                      child: _slotPicker(
                          'Before', _before!, items, (e) => setState(() => _before = e))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _slotPicker(
                          'After', _after!, items, (e) => setState(() => _after = e))),
                ],
              ),
              const SizedBox(height: 16),
              GlowCard(
                child: Column(
                  children: [
                    _diffRow('Overall', _before!.result.overallScore,
                        _after!.result.overallScore),
                    _diffRow('Hydration', _before!.result.hydration,
                        _after!.result.hydration),
                    _diffRow('Acne (lower = better)',
                        _before!.result.acne, _after!.result.acne,
                        reverse: true),
                    _diffRow('Dark Spots (lower = better)',
                        _before!.result.darkSpots, _after!.result.darkSpots,
                        reverse: true),
                    _diffRow('Wrinkles (lower = better)',
                        _before!.result.wrinkles, _after!.result.wrinkles,
                        reverse: true),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _slotPicker(String label, AnalyzerEntry current,
      List<AnalyzerEntry> all, ValueChanged<AnalyzerEntry> onChange) {
    return GlowCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: current.imageBase64 != null
                ? Image.memory(
                    base64Decode(current.imageBase64!),
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 140,
                    color: AppColors.primarySoft.withValues(alpha: .4),
                    child: const Center(
                        child: Icon(Icons.face_3,
                            size: 48, color: AppColors.primary)),
                  ),
          ),
          const SizedBox(height: 8),
          Text('${current.createdAt.day}/${current.createdAt.month} • Skor ${current.result.overallScore}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.event_rounded, size: 16),
            label: const Text('Pilih tanggal'),
            onPressed: () async {
              final picked = await showModalBottomSheet<AnalyzerEntry>(
                context: context,
                builder: (c) => SafeArea(
                  child: ListView.builder(
                    itemCount: all.length,
                    itemBuilder: (_, i) {
                      final e = all[i];
                      return ListTile(
                        leading: e.imageBase64 != null
                            ? ClipOval(
                                child: Image.memory(
                                  base64Decode(e.imageBase64!),
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const CircleAvatar(
                                backgroundColor: AppColors.primarySoft,
                                child: Icon(Icons.face_3,
                                    color: AppColors.primary)),
                        title: Text(
                            '${e.createdAt.day}/${e.createdAt.month}/${e.createdAt.year}'),
                        subtitle: Text(
                            'Skor ${e.result.overallScore} • ${e.result.skinType}'),
                        onTap: () => Navigator.pop(c, e),
                      );
                    },
                  ),
                ),
              );
              if (picked != null) onChange(picked);
            },
          ),
        ],
      ),
    );
  }

  Widget _diffRow(String label, int before, int after, {bool reverse = false}) {
    final diff = after - before;
    final good = reverse ? diff < 0 : diff > 0;
    final color = diff == 0
        ? AppColors.textSecondary
        : (good ? Colors.green.shade700 : Colors.redAccent);
    final sign = diff > 0 ? '+' : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          Text('$before', style: const TextStyle(color: AppColors.textSecondary)),
          const Icon(Icons.arrow_right_alt, color: AppColors.textSecondary),
          Text('$after',
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          Text('$sign$diff',
              style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
