import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/sample_data.dart';
import '../../widgets/glow_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}j';
    return '${d.inDays}h';
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        itemCount: sampleNotifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final n = sampleNotifications[i];
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
                        right: 0, top: 0,
                        child: CircleAvatar(
                          radius: 5, backgroundColor: AppColors.primary),
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
      ),
    );
  }
}
