import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/notification_item.dart';
import '../../services/notification_service.dart';
import '../../widgets/glow_widgets.dart';
import '../../widgets/native_ad_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _svc = NotificationService.instance;

  @override
  void initState() {
    super.initState();
    // Tandai semua sudah dibaca saat layar dibuka (fire-and-forget).
    Future.microtask(() async {
      try {
        await _svc.markAllRead();
      } catch (_) {/* safe */}
    });
  }

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 60) return 'baru';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}j';
    if (d.inDays < 7) return '${d.inDays}h';
    return '${(d.inDays / 7).floor()}mg';
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: StreamBuilder<List<NotificationItem>>(
        stream: _svc.stream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return _empty(
              tt,
              icon: Icons.cloud_off_rounded,
              title: 'Gagal memuat notifikasi',
              body: 'Periksa koneksi internet kamu lalu coba lagi.',
            );
          }
          final items = snapshot.data ?? const <NotificationItem>[];
          if (items.isEmpty) {
            return _empty(
              tt,
              icon: Icons.notifications_none_rounded,
              title: 'Belum ada notifikasi',
              body:
                  'Mulai rutinitas atau scan kulit kamu — update progress akan muncul di sini.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            // +1 slot di akhir untuk Native Ad (M17).
            itemCount: items.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              if (i == items.length) {
                return const NativeAdCard();
              }
              final n = items[i];
              return GlowCard(
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              AppColors.primarySoft.withValues(alpha: .4),
                          child: Icon(n.icon, color: AppColors.primary),
                        ),
                        if (n.unread)
                          const Positioned(
                            right: 0,
                            top: 0,
                            child: CircleAvatar(
                                radius: 5,
                                backgroundColor: AppColors.primary),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(n.title,
                                    style: tt.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700)),
                              ),
                              Text(_ago(n.time),
                                  style: tt.bodySmall?.copyWith(
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(n.body,
                              style: tt.bodySmall?.copyWith(
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _empty(TextTheme tt,
      {required IconData icon,
      required String title,
      required String body}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(title,
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(body,
                textAlign: TextAlign.center,
                style: tt.bodySmall
                    ?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
