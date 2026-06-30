import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';

/// Dialog penjelas verifikasi email — dirancang super jelas untuk target
/// user perempuan yang belum tentu familiar dengan konsep "folder spam".
/// Dipakai di register success & login (email-not-verified).
class VerifyEmailDialog extends StatelessWidget {
  final String email;
  final bool isJustRegistered;
  final Future<void> Function()? onResend;

  const VerifyEmailDialog({
    super.key,
    required this.email,
    this.isJustRegistered = false,
    this.onResend,
  });

  static Future<void> show(
    BuildContext context, {
    required String email,
    bool isJustRegistered = false,
    Future<void> Function()? onResend,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => VerifyEmailDialog(
        email: email,
        isJustRegistered: isJustRegistered,
        onResend: onResend,
      ),
    );
  }

  Future<void> _openGmail(BuildContext context) async {
    // Coba buka aplikasi Gmail dulu, fallback ke browser.
    final urls = [
      Uri.parse('googlegmail://'),
      Uri.parse('https://mail.google.com/mail/u/0/#search/iglows+OR+verify'),
    ];
    for (final u in urls) {
      try {
        if (await canLaunchUrl(u)) {
          await launchUrl(u, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buka aplikasi Gmail kamu secara manual ya kak ✨')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isJustRegistered
        ? 'Yeay, akun kamu udah dibuat! 🥳'
        : 'Tinggal satu langkah lagi ✨';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header icon
            Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_rounded,
                    size: 40, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Kami baru aja kirim link verifikasi ke:',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  email,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // PENTING: highlight folder Spam
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFC069), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFD46B08), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: Color(0xFF7A4A00),
                        ),
                        children: [
                          TextSpan(
                            text: 'Cek FOLDER SPAM ya kak!\n',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text:
                                'Email dari kami kadang nyasar ke Spam. Kalau di Inbox gak ada, buka tab "Spam" di Gmail kamu — pasti ada di sana 💌',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step-by-step
            _StepItem(
              num: '1',
              text: 'Buka aplikasi Gmail kamu',
            ),
            _StepItem(
              num: '2',
              text: 'Cari email dari "iGlows" — cek INBOX dan FOLDER SPAM',
            ),
            _StepItem(
              num: '3',
              text: 'Klik tombol / link verifikasi di dalam email',
            ),
            _StepItem(
              num: '4',
              text: 'Balik ke aplikasi iGlows, lalu login 💖',
              isLast: true,
            ),
            const SizedBox(height: 20),

            // Tombol Buka Gmail (primary)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openGmail(context),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Buka Gmail Sekarang'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Tombol resend (opsional)
            if (onResend != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await onResend!();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Link verifikasi udah dikirim ulang ✨')),
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Gagal kirim ulang. Coba beberapa saat lagi ya kak 🥺')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Kirim Ulang Link'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Nanti aja',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String num;
  final String text;
  final bool isLast;
  const _StepItem({required this.num, required this.text, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              num,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
