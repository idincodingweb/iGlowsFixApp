import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/analyzer_service.dart';
import '../../services/local_store.dart';
import '../../widgets/glow_widgets.dart';

class AnalyzerScreen extends StatefulWidget {
  const AnalyzerScreen({super.key});

  @override
  State<AnalyzerScreen> createState() => _AnalyzerScreenState();
}

class _AnalyzerScreenState extends State<AnalyzerScreen>
    with SingleTickerProviderStateMixin {
  final _svc = AnalyzerService();
  late final AnimationController _scan;
  bool _scanning = false;
  AnalyzerResult? _result;

  @override
  void initState() {
    super.initState();
    _scan = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scan.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _scanning = true;
      _result = null;
    });
    try {
      final r = await _svc.scan();
      if (!mounted) return;
      setState(() {
        _result = r;
        _scanning = false;
      });
      // Persist hasil analyzer terbaru agar dipakai SkinScoreService.
      try {
        await LocalStore().saveLastAnalyzer({
          'skinType': r.skinType,
          'hydration': r.hydration,
          'oiliness': r.oiliness,
          'acne': r.acne,
          'darkSpots': r.darkSpots,
          'wrinkles': r.wrinkles,
          'overallScore': r.overallScore,
        });
      } catch (_) {/* fail-safe */}
    } catch (e) {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Skin Analyzer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            color: AppColors.primary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Riwayat analisis akan tersedia segera.'),
              ));
            },
          )
        ],
      ),
      body: _result == null ? _buildScan() : _buildResult(_result!),
    );
  }

  Widget _buildScan() {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            _scanning ? 'Scanning your skin...' : 'Tap mulai untuk scan',
            style: tt.bodyMedium?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primarySoft.withValues(alpha: .6),
                            AppColors.cream.withValues(alpha: .3),
                          ],
                        ),
                      ),
                    ),
                    const Text('🧖‍♀️', style: TextStyle(fontSize: 92)),
                    if (_scanning)
                      AnimatedBuilder(
                        animation: _scan,
                        builder: (_, __) => CustomPaint(
                          size: const Size.square(260),
                          painter: _ScanPainter(_scan.value),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GlowCard(
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _scanning
                        ? 'Scanning in progress... please keep your face steady'
                        : 'Posisikan wajah dalam frame, pencahayaan cukup, lalu mulai analisis.',
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
                  onPressed: _scanning ? null : () {},
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('Tips'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _scanning ? null : _start,
                  icon: _scanning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.center_focus_strong),
                  label: Text(_scanning ? 'Analisa...' : 'Mulai Scan'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _scanning ? null : () {},
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResult(AnalyzerResult r) {
    final tt = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Your Skin Analysis',
                  style: tt.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
            IconButton(
              onPressed: _start,
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GlowCard(
          gradient: LinearGradient(
            colors: [
              AppColors.primarySoft.withValues(alpha: .5),
              AppColors.cream.withValues(alpha: .7),
            ],
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primarySoft,
                child: Text('🧴', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Skin Type',
                        style: tt.bodySmall
                            ?.copyWith(color: AppColors.textSecondary)),
                    Text(r.skinType,
                        style: tt.headlineSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Skor menyeluruh: ${r.overallScore}/100',
                        style: tt.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _metric('Hydration', r.hydration, Icons.water_drop, false)),
            const SizedBox(width: 12),
            Expanded(child: _metric('Oiliness', r.oiliness, Icons.opacity, true)),
          ],
        ),
        const SizedBox(height: 12),
        GlowCard(
          child: Column(
            children: [
              MetricBar(label: 'Acne Score', value: r.acne, severity: r.severity(r.acne, reverse: true), icon: Icons.face_3),
              MetricBar(label: 'Dark Spots', value: r.darkSpots, severity: r.severity(r.darkSpots, reverse: true), icon: Icons.grain),
              MetricBar(label: 'Wrinkles', value: r.wrinkles, severity: r.severity(r.wrinkles, reverse: true), icon: Icons.waves),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('AI Recommendations',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        ...r.recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlowCard(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.spa, color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(rec)),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _metric(String label, int value, IconData icon, bool reverse) {
    return GlowCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text('$value%',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: (value / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.primarySoft.withValues(alpha: .35),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanPainter extends CustomPainter {
  final double t;
  _ScanPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: .9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 8;
    canvas.drawCircle(c, r, paint..color = AppColors.primary.withValues(alpha: .3));
    const sweep = 1.4;
    final start = -1.6 + (t * 4.2);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      start, sweep, false,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanPainter old) => old.t != t;
}
