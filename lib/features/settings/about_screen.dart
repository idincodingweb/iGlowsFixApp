import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/glow_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _appVersion = '0.1.0';
  static const _devName = 'Idin Iskandar, S.Kom';
  static const _devEmail = 'idiniskandar.tech@gmail.com';
  static const _linkedinUrl =
      'https://www.linkedin.com/in/idin-iskandar-163773271';
  static const _instagramUrl = 'https://instagram.com/idin_iskndr';

  Future<void> _open(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak bisa membuka: $url')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka tautan.')),
        );
      }
    }
  }

  Future<void> _mail(BuildContext context) async {
    final uri = Uri(
        scheme: 'mailto',
        path: _devEmail,
        query: 'subject=iGlows%20-%20Halo%20Developer');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka email.')),
        );
      }
    } catch (_) {/* safe */}
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tentang iGlows')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          // Developer card
          GlowCard(
            gradient: LinearGradient(colors: [
              AppColors.primarySoft.withValues(alpha: .55),
              AppColors.cream,
            ]),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    'II',
                    style: tt.headlineSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Developer',
                    style: tt.bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(_devName,
                    style: tt.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _mail(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.mail_outline_rounded,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(_devEmail,
                            style: tt.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton(
                      label: 'LinkedIn',
                      bg: const Color(0xFF0A66C2),
                      icon: _LinkedInIcon(),
                      onTap: () => _open(context, _linkedinUrl),
                    ),
                    const SizedBox(width: 14),
                    _socialButton(
                      label: 'Instagram',
                      bg: const Color(0xFFE1306C),
                      icon: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 22),
                      onTap: () => _open(context, _instagramUrl),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SectionHeader(title: 'Tentang Aplikasi'),
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          AppColors.primary,
                          AppColors.roseGold,
                        ]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.spa_rounded,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('iGlows',
                              style: tt.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                          Text('Versi $_appVersion',
                              style: tt.bodySmall?.copyWith(
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'iGlows adalah aplikasi pendamping skincare berbasis AI yang membantu kamu memahami kondisi kulit, menyusun rutinitas harian, dan memantau progress secara mudah dan menyenangkan.',
                  style: tt.bodySmall?.copyWith(
                      color: AppColors.textPrimary, height: 1.55),
                ),
                const SizedBox(height: 10),
                Text(
                  'Aplikasi ini dirancang untuk pengguna di Indonesia dengan bahasa yang ramah, tampilan lembut, serta panduan langkah demi langkah agar siapa pun bisa mulai merawat kulit tanpa bingung.',
                  style: tt.bodySmall?.copyWith(
                      color: AppColors.textPrimary, height: 1.55),
                ),
              ],
            ),
          ),

          const SectionHeader(title: 'Fitur Unggulan'),
          ..._features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlowCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            AppColors.primarySoft.withValues(alpha: .55),
                        child: Icon(f.icon, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(f.title,
                                style: tt.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(f.body,
                                style: tt.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),

          const SectionHeader(title: 'Teknologi'),
          const GlowCard(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip('Flutter'),
                _Chip('Firebase'),
                _Chip('Groq AI'),
                _Chip('RapidAPI Maps'),
                _Chip('Material 3'),
              ],
            ),
          ),

          const SizedBox(height: 18),
          Center(
            child: Text(
              '© 2026 iGlows • Dibuat dengan ❤ oleh $_devName',
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton({
    required String label,
    required Color bg,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

const _features = <_Feature>[
  _Feature(
    icon: Icons.center_focus_strong_rounded,
    title: 'Skin Analyzer AI',
    body:
        'Foto wajah → AI Vision menilai kondisi kulit dan memberi saran perawatan.',
  ),
  _Feature(
    icon: Icons.chat_bubble_rounded,
    title: 'Konsultasi Glowy AI',
    body:
        'Chat AI 24/7 untuk pertanyaan skincare, bahan aktif, dan rutinitas.',
  ),
  _Feature(
    icon: Icons.spa_rounded,
    title: 'Rutin Pagi & Malam',
    body: 'Checklist rutin skincare lengkap dengan streak harian.',
  ),
  _Feature(
    icon: Icons.alarm_rounded,
    title: 'Reminder Skincare',
    body: 'Notifikasi pengingat agar rutinitas kamu tidak skip.',
  ),
  _Feature(
    icon: Icons.shopping_bag_rounded,
    title: 'Rekomendasi Produk',
    body: 'Saran produk yang disesuaikan dengan jenis kulit kamu.',
  ),
  _Feature(
    icon: Icons.map_rounded,
    title: 'Cari Salon Terdekat',
    body: 'Temukan klinik & salon kecantikan terdekat lewat peta.',
  ),
];

class _Feature {
  final IconData icon;
  final String title;
  final String body;
  const _Feature(
      {required this.icon, required this.title, required this.body});
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primarySoft),
      ),
      child: Text(label,
          style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12)),
    );
  }
}

/// Simple "in" mark untuk LinkedIn — tanpa dependency tambahan.
class _LinkedInIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'in',
        style: TextStyle(
          color: Color(0xFF0A66C2),
          fontSize: 13,
          fontWeight: FontWeight.w900,
          height: 1.0,
        ),
      ),
    );
  }
}
