import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_theme.dart';
import '../services/app_update_service.dart';

/// Dialog modal untuk broadcast update versi baru.
/// Force update => non-dismissable + tombol "Nanti" disembunyikan.
class AppUpdateDialog extends StatelessWidget {
  final AppUpdateInfo info;
  const AppUpdateDialog({super.key, required this.info});

  static Future<void> show(BuildContext context, AppUpdateInfo info) {
    return showDialog<void>(
      context: context,
      barrierDismissible: !info.forceUpdate,
      builder: (_) => PopScope(
        canPop: !info.forceUpdate,
        child: AppUpdateDialog(info: info),
      ),
    );
  }

  Future<void> _launch(BuildContext context) async {
    final uri = Uri.tryParse(info.downloadUrl);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka link unduhan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft.withValues(alpha: .4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.system_update_rounded,
                      color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Update tersedia',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Versi terbaru: v${info.latestVersion}',
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              info.message.isNotEmpty
                  ? info.message
                  : 'Silakan unduh versi terbaru iGlows untuk pengalaman terbaik ✨',
              style: tt.bodyMedium,
            ),
            if (info.forceUpdate) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Update wajib sebelum melanjutkan',
                  style: tt.bodySmall
                      ?.copyWith(color: Colors.red.shade700, fontWeight: FontWeight.w600),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!info.forceUpdate)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Nanti'),
                  ),
                const SizedBox(width: 4),
                FilledButton.icon(
                  onPressed: () => _launch(context),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Unduh sekarang'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
