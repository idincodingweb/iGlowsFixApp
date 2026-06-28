import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/routine_step.dart';
import '../../../services/local_store.dart';
import '../../../services/notification_service.dart';
import '../../../widgets/glow_widgets.dart';

class RoutinesTab extends StatefulWidget {
  const RoutinesTab({super.key});

  @override
  State<RoutinesTab> createState() => _RoutinesTabState();
}

class _RoutinesTabState extends State<RoutinesTab> {
  final _store = LocalStore();
  Set<String> _done = {};
  int _streak = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await _store.loadRoutineDone();
      final s = await _store.getStreak();
      if (!mounted) return;
      setState(() {
        _done = d;
        _streak = s;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(String id) async {
    setState(() {
      if (_done.contains(id)) {
        _done.remove(id);
      } else {
        _done.add(id);
      }
    });
    await _store.saveRoutineDone(_done);

    final allCount = morningRoutine.length + nightRoutine.length;
    if (_done.length >= allCount) {
      final s = await _store.bumpStreakIfNeeded();
      if (!mounted) return;
      setState(() => _streak = s);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Streak naik jadi $s hari! ✨')),
      );
      // Catat ke notifikasi (real, per-user) — dedupe per hari.
      try {
        final today = DateTime.now();
        final dk =
            '${today.year}-${today.month}-${today.day}';
        await NotificationService.instance.add(
          title: 'Streak kamu naik jadi $s hari 🔥',
          body:
              'Semua step rutin hari ini selesai. Pertahankan biar glow-nya makin stabil!',
          kind: 'streak',
          dedupeKey: 'streak_$dk',
        );
      } catch (_) {/* safe */}
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    final total = morningRoutine.length + nightRoutine.length;
    final progress = (_done.length / total).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinitas'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft.withValues(alpha: .45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('🔥'),
                    const SizedBox(width: 4),
                    Text('$_streak hari',
                        style: tt.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Progress hari ini',
                    style: tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: progress,
                    backgroundColor:
                        AppColors.primarySoft.withValues(alpha: .35),
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 6),
                Text('${_done.length} / $total step selesai',
                    style: tt.bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SectionHeader(title: '☀️  Morning Routine'),
          ...morningRoutine.map((s) => _buildStep(s)),
          const SizedBox(height: 8),
          const SectionHeader(title: '🌙  Night Routine'),
          ...nightRoutine.map((s) => _buildStep(s)),
        ],
      ),
    );
  }

  Widget _buildStep(RoutineStep s) {
    final tt = Theme.of(context).textTheme;
    final done = _done.contains(s.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlowCard(
        onTap: () => _toggle(s.id),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? AppColors.primary
                    : AppColors.primarySoft.withValues(alpha: .35),
              ),
              alignment: Alignment.center,
              child: Icon(done ? Icons.check_rounded : s.icon,
                  color: done ? Colors.white : AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name,
                      style: tt.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text(s.hint,
                      style: tt.bodySmall
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(
              done
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked_rounded,
              color: done ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
