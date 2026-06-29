import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/reminder_service.dart';
import '../../widgets/glow_widgets.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _svc = ReminderService.instance;
  ReminderSettings _s = const ReminderSettings();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await _svc.init();
      final s = await _svc.loadSettings();
      if (!mounted) return;
      setState(() {
        _s = s;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _apply(ReminderSettings next) async {
    setState(() {
      _s = next;
      _saving = true;
    });
    try {
      final granted = await _svc.requestPermission();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Izin notifikasi belum diberikan. Aktifkan lewat Settings HP ya.')),
        );
      }
      await _svc.saveSettings(next);
      await _svc.applySchedules(next);
    } catch (_) {/* safe */} finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickTime({required bool morning}) async {
    final initial = morning
        ? TimeOfDay(hour: _s.morningHour, minute: _s.morningMinute)
        : TimeOfDay(hour: _s.nightHour, minute: _s.nightMinute);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: Theme.of(c).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    await _apply(morning
        ? _s.copyWith(morningHour: picked.hour, morningMinute: picked.minute)
        : _s.copyWith(nightHour: picked.hour, nightMinute: picked.minute));
  }

  String _fmt(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Reminder')),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Text('Atur reminder rutinitas',
                    style:
                        tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  'Reminder berjalan lokal di HP kamu — gak butuh internet ✨',
                  style: tt.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                GlowCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primary,
                        title: const Text('Rutinitas pagi'),
                        subtitle:
                            Text('Setiap hari • ${_fmt(_s.morningHour, _s.morningMinute)}'),
                        value: _s.morningEnabled,
                        onChanged: _saving
                            ? null
                            : (v) => _apply(_s.copyWith(morningEnabled: v)),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _saving || !_s.morningEnabled
                              ? null
                              : () => _pickTime(morning: true),
                          icon: const Icon(Icons.access_time,
                              color: AppColors.primary),
                          label: const Text('Ubah jam pagi'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GlowCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primary,
                        title: const Text('Rutinitas malam'),
                        subtitle:
                            Text('Setiap hari • ${_fmt(_s.nightHour, _s.nightMinute)}'),
                        value: _s.nightEnabled,
                        onChanged: _saving
                            ? null
                            : (v) => _apply(_s.copyWith(nightEnabled: v)),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _saving || !_s.nightEnabled
                              ? null
                              : () => _pickTime(morning: false),
                          icon: const Icon(Icons.access_time,
                              color: AppColors.primary),
                          label: const Text('Ubah jam malam'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GlowCard(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                    title: const Text('Cek skin score mingguan'),
                    subtitle: const Text('Minggu • 19:00'),
                    value: _s.weeklyEnabled,
                    onChanged: _saving
                        ? null
                        : (v) => _apply(_s.copyWith(weeklyEnabled: v)),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _saving
                      ? null
                      : () async {
                          await _svc.requestPermission();
                          await _svc.fireTest();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Test reminder dikirim ✨')),
                          );
                        },
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('Kirim test reminder'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Catatan: di Android 13+ HP akan minta izin notifikasi pertama kali kamu nyalain reminder.',
                  style: tt.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
    );
  }
}
