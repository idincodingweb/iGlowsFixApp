import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/glow_widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final guides = <_Guide>[
      _Guide(
        icon: Icons.login_rounded,
        title: 'Daftar & Masuk',
        steps: const [
          'Buka aplikasi, tap "Daftar" untuk akun baru atau "Masuk" jika sudah punya akun.',
          'Gunakan email Gmail aktif, masukkan password minimal 6 karakter.',
          'Cek email kamu untuk link verifikasi sebelum login pertama kali.',
        ],
      ),
      _Guide(
        icon: Icons.face_retouching_natural,
        title: 'Lengkapi Skin Profile',
        steps: const [
          'Masuk ke tab Profile lalu ketuk kartu "Skin Profile".',
          'Isi jenis kulit, usia, dan concern (jerawat, kusam, dll).',
          'Simpan agar rekomendasi rutin & produk lebih akurat.',
        ],
      ),
      _Guide(
        icon: Icons.spa_rounded,
        title: 'Rutin Skincare Harian',
        steps: const [
          'Buka tab Routines untuk melihat langkah pagi & malam.',
          'Centang langkah yang sudah kamu lakukan agar streak naik.',
          'Streak harian bisa kamu lihat di kartu profil kamu.',
        ],
      ),
      _Guide(
        icon: Icons.alarm_rounded,
        title: 'Atur Reminder',
        steps: const [
          'Masuk Profile → Reminder Skincare.',
          'Pilih jam pagi & malam, aktifkan toggle reminder.',
          'iGlows akan kirim notifikasi sesuai jadwal kamu.',
        ],
      ),
      _Guide(
        icon: Icons.center_focus_strong_rounded,
        title: 'Skin Analyzer (AI Vision)',
        steps: const [
          'Buka tab Analyzer, tap tombol scan.',
          'Foto wajah dengan pencahayaan cukup tanpa makeup tebal.',
          'Tunggu AI memproses, lihat skor & saran perawatannya.',
          'Bandingkan hasil scan lewat menu "Compare" untuk pantau progress.',
        ],
      ),
      _Guide(
        icon: Icons.chat_bubble_rounded,
        title: 'Konsultasi dengan Glowy AI',
        steps: const [
          'Buka tab Consultation untuk ngobrol bareng Glowy.',
          'Tanya apa saja seputar skincare, bahan aktif, atau rutinitas.',
          'Jawaban dipersonalisasi berdasarkan skin profile kamu.',
        ],
      ),
      _Guide(
        icon: Icons.shopping_bag_rounded,
        title: 'Cari Produk & Salon',
        steps: const [
          'Tab Products: lihat rekomendasi produk sesuai jenis kulit.',
          'Tab Salon: temukan klinik/salon terdekat lewat peta.',
          'Tap kartu untuk detail dan rute menuju lokasi.',
        ],
      ),
      _Guide(
        icon: Icons.notifications_active_rounded,
        title: 'Notifikasi',
        steps: const [
          'Atur jenis notifikasi di Profile → Notifikasi.',
          'Aktifkan reminder, tips, atau promo sesuai kebutuhan.',
          'Riwayat notifikasi tersimpan di menu yang sama.',
        ],
      ),
    ];

    final faqs = <_Faq>[
      _Faq(
        q: 'Apakah iGlows gratis?',
        a: 'Ya, fitur inti iGlows gratis. Beberapa fitur AI bisa memiliki batas pemakaian harian.',
      ),
      _Faq(
        q: 'Apakah data foto saya aman?',
        a: 'Foto hanya diproses untuk analisa AI dan tidak dibagikan ke pihak ketiga. Lihat halaman Privasi & Keamanan untuk detail.',
      ),
      _Faq(
        q: 'Kenapa rekomendasi belum akurat?',
        a: 'Pastikan kamu sudah mengisi Skin Profile lengkap dan minimal satu kali scan dengan Skin Analyzer.',
      ),
      _Faq(
        q: 'Reminder tidak muncul, kenapa?',
        a: 'Cek izin notifikasi aplikasi di pengaturan HP, lalu pastikan toggle reminder aktif di Profile → Reminder Skincare.',
      ),
      _Faq(
        q: 'Bagaimana cara hapus akun?',
        a: 'Kirim email ke idiniskandar.tech@gmail.com dengan subjek "Hapus Akun iGlows" dari email akun kamu.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan')),
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
                  child: Icon(Icons.help_rounded, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Panduan penggunaan iGlows',
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        'Belajar cepat memakai semua fitur iGlows step-by-step.',
                        style: tt.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Panduan Fitur'),
          ...guides.map((g) => _guideCard(tt, g)),
          const SectionHeader(title: 'FAQ'),
          ...faqs.map((f) => _faqCard(tt, f)),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Masih butuh bantuan? Email idiniskandar.tech@gmail.com',
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _guideCard(TextTheme tt, _Guide g) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlowCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      AppColors.primarySoft.withValues(alpha: .55),
                  child: Icon(g.icon, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(g.title,
                      style: tt.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...List.generate(g.steps.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2, right: 10),
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text('${i + 1}',
                          style: tt.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                    Expanded(
                      child: Text(g.steps[i],
                          style: tt.bodySmall?.copyWith(
                              color: AppColors.textPrimary, height: 1.5)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _faqCard(TextTheme tt, _Faq f) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlowCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Theme(
          data: ThemeData(
            dividerColor: Colors.transparent,
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 12, top: 0),
            iconColor: AppColors.primary,
            collapsedIconColor: AppColors.primary,
            title: Text(f.q,
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(f.a,
                    style: tt.bodySmall?.copyWith(
                        color: AppColors.textSecondary, height: 1.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Guide {
  final IconData icon;
  final String title;
  final List<String> steps;
  _Guide({required this.icon, required this.title, required this.steps});
}

class _Faq {
  final String q;
  final String a;
  _Faq({required this.q, required this.a});
}
