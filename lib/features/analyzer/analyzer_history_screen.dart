import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/analyzer_history_service.dart';
import '../../widgets/glow_widgets.dart';

class AnalyzerHistoryScreen extends StatelessWidget {
  const AnalyzerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Skin Analyzer')),
      body: StreamBuilder<List<AnalyzerEntry>>(
        stream: AnalyzerHistoryService.instance.stream(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                  'Belum ada hasil scan tersimpan.\nMulai scan dari halaman Analyzer.',
                  textAlign: TextAlign.center),
            ));
          }
          // Untuk chart, sort ascending by date.
          final chartData = items.reversed.toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              GlowCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Progress Skin Score',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('${chartData.length} hasil scan terakhir',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 100,
                          gridData: const FlGridData(
                              show: true, drawVerticalLine: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: 25,
                                getTitlesWidget: (v, _) => Text(
                                    v.toInt().toString(),
                                    style: const TextStyle(fontSize: 10)),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                interval:
                                    (chartData.length / 4).ceilToDouble().clamp(
                                          1,
                                          double.infinity,
                                        ),
                                getTitlesWidget: (v, _) {
                                  final i = v.toInt();
                                  if (i < 0 || i >= chartData.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final d = chartData[i].createdAt;
                                  return Text(
                                      '${d.day}/${d.month}',
                                      style:
                                          const TextStyle(fontSize: 10));
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                for (var i = 0; i < chartData.length; i++)
                                  FlSpot(i.toDouble(),
                                      chartData[i].result.overallScore.toDouble()),
                              ],
                              isCurved: true,
                              color: AppColors.primary,
                              barWidth: 3,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.primary
                                    .withValues(alpha: .15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Semua Scan',
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 8),
              ...items.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlowCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: e.imageBase64 != null
                                ? Image.memory(
                                    base64Decode(e.imageBase64!),
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 56,
                                    height: 56,
                                    color: AppColors.primarySoft
                                        .withValues(alpha: .4),
                                    child: const Icon(Icons.face_3,
                                        color: AppColors.primary),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Skor ${e.result.overallScore} • ${e.result.skinType}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                Text(
                                  '${e.createdAt.day}/${e.createdAt.month}/${e.createdAt.year} '
                                  '${e.createdAt.hour.toString().padLeft(2, '0')}:${e.createdAt.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text('${e.result.overallScore}',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}
