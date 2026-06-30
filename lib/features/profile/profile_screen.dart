import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_theme.dart';
import '../../models/skin_profile.dart';
import '../../services/local_store.dart';
import '../../widgets/glow_widgets.dart';
import '../auth/auth_service.dart';
import '../settings/about_screen.dart';
import '../settings/help_screen.dart';
import '../settings/notifications_settings_screen.dart';
import '../settings/privacy_security_screen.dart';
import 'edit_skin_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _store = LocalStore();
  SkinProfile? _profile;
  int _streak = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await _store.loadProfile();
      final s = await _store.getStreak();
      if (!mounted) return;
      setState(() {
        _profile = p;
        _streak = s;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar akun?'),
        content: const Text('Kamu akan kembali ke halaman login.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Logout')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await AuthService().signOut();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal logout: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary)));
    }
    final user = FirebaseAuth.instance.currentUser;
    final tt = Theme.of(context).textTheme;
    final name = (_profile?.name?.trim().isNotEmpty == true)
        ? _profile!.name!
        : (user?.displayName ?? user?.email?.split('@').first ?? 'Beauty');

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          GlowCard(
            gradient: LinearGradient(colors: [
              AppColors.primarySoft.withValues(alpha: .5),
              AppColors.cream,
            ]),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    name.characters.first.toUpperCase(),
                    style: tt.headlineMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                Text(name,
                    style: tt.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text(user?.email ?? '-',
                    style: tt.bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _stat('🔥', '$_streak hari', 'Streak'),
                    _stat('🧴', _profile?.skinType ?? '-', 'Skin Type'),
                    _stat('🎯', _profile?.goal ?? 'Set', 'Goal'),
                  ],
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Skin Profile'),
          GlowCard(
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => EditSkinProfileScreen(initial: _profile)));
              _load();
            },
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.primarySoft,
                  child: Icon(Icons.face_3, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profile == null
                            ? 'Belum diatur'
                            : '${_profile!.skinType} • ${_profile!.age} thn',
                        style: tt.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _profile == null
                            ? 'Atur jenis kulit & concern untuk rekomendasi yang akurat.'
                            : (_profile!.concerns.isEmpty
                                ? 'Tap untuk lengkapi concern'
                                : _profile!.concerns.join(', ')),
                        style: tt.bodySmall?.copyWith(
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.primary),
              ],
            ),
          ),
          const SectionHeader(title: 'Pengaturan'),
          _menu(Icons.alarm, 'Reminder Skincare',
              onTap: () => Navigator.pushNamed(context, '/reminders')),
          _menu(Icons.notifications_none, 'Notifikasi', onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const NotificationsSettingsScreen()));
          }),
          _menu(Icons.lock_outline, 'Privasi & Keamanan', onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const PrivacySecurityScreen()));
          }),
          _menu(Icons.help_outline, 'Bantuan', onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HelpScreen()));
          }),
          _menu(Icons.info_outline, 'Tentang iGlows', onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AboutScreen()));
          }),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _stat(String emoji, String value, String label) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 2),
        Text(value, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        Text(label,
            style:
                tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _menu(IconData icon, String label, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlowCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$label akan tersedia segera.')));
            },
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
