import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../models/skin_profile.dart';
import '../../services/analyzer_history_service.dart';
import '../../services/analyzer_service.dart';
import '../../services/groq_service.dart';
import '../../services/local_store.dart';
import '../../services/notification_service.dart';
import '../../widgets/glow_widgets.dart';
import 'analyzer_compare_screen.dart';
import 'analyzer_history_screen.dart';

class AnalyzerScreen extends StatefulWidget {
  const AnalyzerScreen({super.key});

  @override
  State<AnalyzerScreen> createState() => _AnalyzerScreenState();
}

class _AnalyzerScreenState extends State<AnalyzerScreen>
    with SingleTickerProviderStateMixin {
  final _svc = AnalyzerService();
  final _picker = ImagePicker();
  final _store = LocalStore();
  late final AnimationController _scan;
  bool _scanning = false;
  AnalyzerResult? _result;
  String? _imgB64;
  String? _imgMime;
  String? _error;

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
    _svc.dispose();
    super.dispose();
  }

  String _mimeFromPath(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.png')) return 'image/png';
    if (p.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<void> _pickAndAnalyze(ImageSource src) async {
    try {
      final x = await _picker.pickImage(
        source: src,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 75,
        preferredCameraDevice: CameraDevice.front,
      );
      if (x == null) return;
      final bytes = await x.readAsBytes();
      final b64 = base64Encode(bytes);
      final mime = _mimeFromPath(x.path);
      if (!mounted) return;
      setState(() {
        _imgB64 = b64;
        _imgMime = mime;
        _scanning = true;
        _result = null;
        _error = null;
      });
      await _runAnalysis(b64: b64, mime: mime);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _error = 'Gagal akses kamera/galeri: $e';
      });
    }
  }

  Future<void> _runAnalysis({String? b64, String? mime}) async {
    final imageB64 = b64 ?? _imgB64;
    final imageMime = mime ?? _imgMime ?? 'image/jpeg';

    SkinProfile? profile;
    try {
      profile = await _store.loadProfile();
    } catch (_) {}

    AnalyzerResult r;
    try {
      if (imageB64 != null) {
        r = await _svc.scanWithImage(
          imageBase64: imageB64,
          mime: imageMime,
          profile: profile,
        );
      } else {
        r = await _svc.simulate();
      }
    } on GroqException catch (e) {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _error =
            'AI Skin Analyzer error: ${e.message}. Tampilkan estimasi cadangan.';
      });
      // Fallback ke simulasi biar user tetap dapet hasil.
      r = await _svc.simulate();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _error = 'Gangguan koneksi: $e';
      });
      r = await _svc.simulate();
    }

    if (!mounted) return;
    setState(() {
      _result = r;
      _scanning = false;
    });

    // Persist hasil & kirim notifikasi.
    try {
      await _store.saveLastAnalyzer(r.toMap());
      await AnalyzerHistoryService.instance.save(
        r,
        imageBase64: imageB64,
        mime: imageMime,
      );
      final now = DateTime.now();
      final dk = '${now.year}-${now.month}-${now.day}';
      await NotificationService.instance.add(
        title: 'Hasil skin analyzer siap 🪞',
        body:
            'Skor kulit kamu: ${r.overallScore}. Buka Home untuk lihat insight lengkapnya.',
        kind: 'analyzer',
        dedupeKey: 'analyzer_$dk',
      );
    } catch (_) {}
  }

  void _showPickSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(2))),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded,
                  color: AppColors.primary),
              title: const Text('Scan via Kamera'),
              subtitle:
                  const Text('AI cek langsung wajah kamu (kamera depan).'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndAnalyze(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: const Text('Pilih dari Galeri'),
              subtitle: const Text('Unggah foto wajah yang udah ada.'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndAnalyze(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skin Analyst'),
        actions: [
          IconButton(
            tooltip: 'Riwayat',
            icon: const Icon(Icons.history_rounded, color: AppColors.primary),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const AnalyzerHistoryScreen())),
          ),
          IconButton(
            tooltip: 'Before/After',
            icon: const Icon(Icons.compare_rounded, color: AppColors.primary),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const AnalyzerCompareScreen())),
          ),
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
          const SizedBox(height: 12),
          Text('Scan Kulit Kamu',
              style: tt.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            'AI analisa kondisi kulit dari foto wajah kamu — pakai kamera live atau upload dari galeri.',
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: AnimatedBuilder(
                  animation: _scan,
                  builder: (_, __) => CustomPaint(
                    painter: _ScanPainter(_scan.value),
                    child: Center(
                      child: ClipOval(
                        child: _imgB64 != null
                            ? Image.memory(
                                base64Decode(_imgB64!),
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 180,
                                height: 180,
                                color: AppColors.primarySoft
                                    .withValues(alpha: .35),
                                child: const Icon(Icons.face_retouching_natural,
                                    size: 90, color: AppColors.primary),
                              ),
                      ),
                    ),
                  ),
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
                        ? 'AI sedang menganalisa foto kamu... ✨'
                        : 'Klik tombol di bawah → pilih kamera atau galeri.',
                    style: tt.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
                textAlign: TextAlign.center,
                style: tt.bodySmall?.copyWith(color: Colors.redAccent)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _scanning ? null : _showPickSheet,
              icon: _scanning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.center_focus_strong_rounded),
              label: Text(_scanning ? 'Menganalisa...' : 'Mulai Scan Wajah'),
            ),
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
              tooltip: 'Scan ulang',
              onPressed: () => setState(() {
                _result = null;
                _imgB64 = null;
                _imgMime = null;
                _error = null;
              }),
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.primary),
            ),
          ],
        ),
        if (!r.fromAi)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '⚠️ Estimasi cadangan (AI gak bisa diakses) — coba scan ulang kalau koneksi udah stabil.',
              style:
                  tt.bodySmall?.copyWith(color: Colors.orange.shade700),
            ),
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
              if (_imgB64 != null)
                ClipOval(
                  child: Image.memory(
                    base64Decode(_imgB64!),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                )
              else
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
            Expanded(
                child: _metric(
                    'Hydration', r.hydration, Icons.water_drop, false)),
            const SizedBox(width: 12),
            Expanded(
                child: _metric('Oiliness', r.oiliness, Icons.opacity, true)),
          ],
        ),
        const SizedBox(height: 12),
        GlowCard(
          child: Column(
            children: [
              MetricBar(
                  label: 'Acne Score',
                  value: r.acne,
                  severity: r.severity(r.acne, reverse: true),
                  icon: Icons.face_3),
              MetricBar(
                  label: 'Dark Spots',
                  value: r.darkSpots,
                  severity: r.severity(r.darkSpots, reverse: true),
                  icon: Icons.grain),
              MetricBar(
                  label: 'Wrinkles',
                  value: r.wrinkles,
                  severity: r.severity(r.wrinkles, reverse: true),
                  icon: Icons.waves),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('Rekomendasi Konsultan iGlows',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        ...r.recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlowCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.spa,
                        color: AppColors.primary, size: 18),
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
              backgroundColor:
                  AppColors.primarySoft.withValues(alpha: .35),
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.primary),
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
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 8;
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = AppColors.primary.withValues(alpha: .3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    const sweep = 1.4;
    final start = -1.6 + (t * 4.2);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      start,
      sweep,
      false,
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
