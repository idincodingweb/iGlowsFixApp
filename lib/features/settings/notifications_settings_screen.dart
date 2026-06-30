import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/glow_widgets.dart';
import '../notifications/notifications_screen.dart';

/// Preferensi notifikasi in-app + akses cepat ke daftar notifikasi.
/// Setting disimpan lokal via SharedPreferences supaya tidak butuh backend tambahan.
class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  static const _kMaster = 'notif_master_enabled';
  static const _kReminder = 'notif_reminder_enabled';
  static const _kTips = 'notif_tips_enabled';
  static const _kPromo = 'notif_promo_enabled';
  static const _kSound = 'notif_sound_enabled';

  bool _loading = true;
  bool _master = true;
  bool _reminder = true;
  bool _tips = true;
  bool _promo = false;
  bool _sound = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _master = p.getBool(_kMaster) ?? true;
        _reminder = p.getBool(_kReminder) ?? true;
        _tips = p.getBool(_kTips) ?? true;
        _promo = p.getBool(_kPromo) ?? false;
        _sound = p.getBool(_kSound) ?? true;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save(String key, bool value) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(key, value);
    } catch (_) {/* safe */}
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
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
                  child: Icon(Icons.notifications_active_rounded,
                      color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Atur notifikasi kamu',
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        'Pilih jenis notifikasi yang ingin kamu terima dari iGlows.',
                        style: tt.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Umum'),
          _switchTile(
            icon: Icons.power_settings_new_rounded,
            title: 'Aktifkan notifikasi',
            subtitle: 'Master switch untuk semua notifikasi iGlows.',
            value: _master,
            onChanged: (v) {
              setState(() => _master = v);
              _save(_kMaster, v);
            },
          ),
          _switchTile(
            icon: Icons.volume_up_rounded,
            title: 'Suara notifikasi',
            subtitle: 'Mainkan suara saat notifikasi muncul.',
            value: _sound,
            enabled: _master,
            onChanged: (v) {
              setState(() => _sound = v);
              _save(_kSound, v);
            },
          ),
          const SectionHeader(title: 'Kategori'),
          _switchTile(
            icon: Icons.alarm_rounded,
            title: 'Pengingat skincare',
            subtitle: 'Reminder pagi & malam sesuai jadwal kamu.',
            value: _reminder,
            enabled: _master,
            onChanged: (v) {
              setState(() => _reminder = v);
              _save(_kReminder, v);
            },
          ),
          _switchTile(
            icon: Icons.tips_and_updates_rounded,
            title: 'Tips & artikel baru',
            subtitle: 'Update tips harian dan artikel rekomendasi.',
            value: _tips,
            enabled: _master,
            onChanged: (v) {
              setState(() => _tips = v);
              _save(_kTips, v);
            },
          ),
          _switchTile(
            icon: Icons.local_offer_rounded,
            title: 'Promo & penawaran',
            subtitle: 'Info diskon produk skincare partner.',
            value: _promo,
            enabled: _master,
            onChanged: (v) {
              setState(() => _promo = v);
              _save(_kPromo, v);
            },
          ),
          const SectionHeader(title: 'Riwayat'),
          GlowCard(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const NotificationsScreen()));
            },
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.primarySoft,
                  child: Icon(Icons.inbox_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lihat semua notifikasi',
                          style: tt.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                        'Riwayat notifikasi yang kamu terima di aplikasi.',
                        style: tt.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlowCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: tt.bodySmall
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Switch(
              value: value && enabled,
              activeThumbColor: AppColors.primary,
              onChanged: enabled ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }
}
