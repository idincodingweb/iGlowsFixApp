import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/glow_widgets.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  Future<void> _openMail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'idiniskandar.tech@gmail.com',
      query: 'subject=iGlows%20-%20Privasi%20%26%20Keamanan',
    );
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tidak bisa membuka aplikasi email.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka email.')),
        );
      }
    }
  }

  Future<void> _resetPassword(BuildContext context) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email akun tidak ditemukan.')),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Link reset password dikirim ke $email')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal kirim reset: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Privasi & Keamanan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          GlowCard(
            gradient: LinearGradient(colors: [
              AppColors.primarySoft.withValues(alpha: .45),
              AppColors.cream,
            ]),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.shield_rounded, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Keamanan akun kamu',
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        'iGlows menjaga data kamu tetap aman dan tidak membagikannya ke pihak ketiga tanpa izin.',
                        style: tt.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Akun'),
          _infoTile(context,
              icon: Icons.email_outlined,
              title: 'Email akun',
              subtitle: user?.email ?? '-'),
          _infoTile(context,
              icon: Icons.verified_user_outlined,
              title: 'Status verifikasi',
              subtitle: (user?.emailVerified ?? false)
                  ? 'Terverifikasi'
                  : 'Belum terverifikasi'),
          _actionTile(
            context,
            icon: Icons.lock_reset_rounded,
            title: 'Reset password',
            subtitle: 'Kirim link reset password ke email akun kamu.',
            onTap: () => _resetPassword(context),
          ),
          const SectionHeader(title: 'Data & Privasi'),
          _policySection(
            tt,
            icon: Icons.policy_outlined,
            title: 'Data yang kami kumpulkan',
            body:
                'Kami menyimpan info dasar akun (email, nama), preferensi kulit yang kamu isi sendiri, hasil scan/analisa kulit, riwayat reminder, serta interaksi dengan AI Glowy. Data ini dipakai untuk menampilkan dan memperbaiki rekomendasi skincare kamu.',
          ),
          _policySection(
            tt,
            icon: Icons.cloud_done_outlined,
            title: 'Tempat penyimpanan',
            body:
                'Data utama disimpan di Firebase (Authentication & Cloud Firestore) milik Google. Beberapa preferensi & cache disimpan lokal di perangkat kamu (SharedPreferences). Foto hasil scan diproses lokal dan hanya dikirim ke layanan AI saat kamu memintanya.',
          ),
          _policySection(
            tt,
            icon: Icons.smart_toy_outlined,
            title: 'Layanan AI pihak ketiga',
            body:
                'Saat menggunakan fitur AI (Glowy & Skin Analyzer), pertanyaan/foto kamu dikirim ke penyedia model (Groq) untuk diproses. Kami tidak menyimpan riwayat tersebut di server pihak ketiga melebihi keperluan respons.',
          ),
          _policySection(
            tt,
            icon: Icons.location_on_outlined,
            title: 'Lokasi & peta',
            body:
                'Fitur peta salon menggunakan layanan Maps (RapidAPI). Lokasi kamu hanya diakses bila kamu mengizinkan dan tidak disimpan permanen.',
          ),
          _policySection(
            tt,
            icon: Icons.delete_outline_rounded,
            title: 'Hak atas data kamu',
            body:
                'Kamu bisa minta data dihapus kapan saja dengan menghubungi kami via email di bawah. Akun yang dihapus akan menghapus profil, hasil analisa, dan riwayat terkait.',
          ),
          const SectionHeader(title: 'Hubungi Kami'),
          _actionTile(
            context,
            icon: Icons.mail_outline_rounded,
            title: 'idiniskandar.tech@gmail.com',
            subtitle:
                'Kirim email untuk pertanyaan privasi, hapus data, atau laporan keamanan.',
            onTap: () => _openMail(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Dokumen ini bersifat ringkasan. Dengan memakai iGlows kamu setuju pada ketentuan layanan & kebijakan privasi yang berlaku.',
            style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _infoTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle}) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlowCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primarySoft.withValues(alpha: .55),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: tt.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: tt.bodySmall
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlowCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primarySoft.withValues(alpha: .55),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: tt.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: tt.bodySmall
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _policySection(TextTheme tt,
      {required IconData icon,
      required String title,
      required String body}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlowCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primarySoft.withValues(alpha: .55),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: tt.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(body,
                      style: tt.bodySmall?.copyWith(
                          color: AppColors.textSecondary, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
