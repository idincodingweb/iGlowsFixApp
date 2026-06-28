import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/glow_widgets.dart';
import '../../../services/local_store.dart';
import '../../../services/notification_service.dart';
import '../../../services/skin_score_service.dart';
import '../../../models/skin_profile.dart';
import '../../../models/routine_step.dart';
import '../../consultation/consultation_screen.dart';
import '../../analyzer/analyzer_screen.dart';
import '../../profile/profile_screen.dart';
import '../../notifications/notifications_screen.dart';
import '../../products/products_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _store = LocalStore();
  final _scoreSvc = SkinScoreService();
  SkinProfile? _profile;
  Set<String> _done = {};
  int _streak = 0;
  DailySkinScore? _score;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await _store.loadProfile();
      final d = await _store.loadRoutineDone();
      final s = await _store.getStreak();
      final score = await _scoreSvc.compute(useCache: false);
      if (!mounted) return;
      setState(() {
        _profile = p;
        _done = d;
        _streak = s;
        _score = score;
      });
      // Welcome notif (idempotent) + reminder malam kalau night routine
      // belum kelar dan sudah lewat jam 19:00 lokal.
      try {
        await NotificationService.instance.seedWelcomeIfNeeded();
        final now = DateTime.now();
        final nightDone = nightRoutine.every((st) => d.contains(st.id));
        if (now.hour >= 19 && !nightDone) {
          final dk = '${now.year}-${now.month}-${now.day}';
          await NotificationService.instance.add(
            title: 'Waktunya rutinitas malam ✨',
            body:
                'Yuk lanjut step skincare malam kamu biar streak tetap menyala!',
            kind: 'routine',
            dedupeKey: 'routine_night_$dk',
          );
        }
      } catch (_) {/* safe */}
    } catch (_) {/* safe */}
  }

  String _greetingName() {
    if (_profile?.name?.isNotEmpty == true) return _profile!.name!;
    final u = FirebaseAuth.instance.currentUser;
    return (u?.displayName?.trim().isNotEmpty == true)
        ? u!.displayName!.split(' ').first
        : (u?.email?.split('@').first ?? 'Beauty');
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final hasData = _score?.hasData ?? false;
    final score = hasData ? (_score?.overall ?? 0) : 0;
    final caption = _score?.caption ?? 'Belum ada data';
    final updatedLabel = _score == null
        ? '✨ Memuat...'
        : (!hasData
            ? '✨ Mulai rutinitas / scan untuk lihat skor kamu'
            : (_score!.hasAnalyzer
                ? '✨ Update dari scan terakhir'
                : '✨ Update dari aktivitas kamu'));
    final name = _greetingName();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              // Header
              Row(
                children: [
                  Text('iGlows',
                      style: tt.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800)),
                  const Spacer(),
                  _CircleIconButton(
                    icon: Icons.notifications_none_rounded,
                    dot: true,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const NotificationsScreen())),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (_) => const ProfileScreen()))
                        .then((_) => _load()),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primarySoft,
                      child: Text(
                        name.characters.first.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Hi, $name ✨',
                  style: tt.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              Row(
                children: [
                  const Icon(Icons.favorite,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('Your glow, our priority',
                      style: tt.bodySmall
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 18),

              // Skin score card
              GlowCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    ScoreRing(value: score, caption: caption),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Daily Skin Score',
                              style: tt.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(updatedLabel,
                              style: tt.bodySmall?.copyWith(
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 10),
                          _miniMetric(Icons.water_drop, 'Hydration',
                              _score?.hydration.rating ?? '-'),
                          _miniMetric(Icons.spa, 'Smoothness',
                              _score?.smoothness.rating ?? '-'),
                          _miniMetric(Icons.wb_sunny_outlined, 'Brightness',
                              _score?.brightness.rating ?? '-'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Today's routine + streak
              GlowCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Today's Routine",
                            style: tt.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft.withValues(alpha: .4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
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
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 72,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: morningRoutine.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final s = morningRoutine[i];
                          final done = _done.contains(s.id);
                          return Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: done
                                      ? AppColors.primary
                                      : AppColors.primarySoft
                                          .withValues(alpha: .35),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  done ? Icons.check_rounded : s.icon,
                                  color: done ? Colors.white : AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(s.name,
                                  style: tt.bodySmall?.copyWith(fontSize: 11)),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // AI consultation + Analyzer dual cards
              Row(
                children: [
                  Expanded(
                    child: GlowCard(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primarySoft.withValues(alpha: .55),
                          AppColors.cream.withValues(alpha: .8),
                        ],
                      ),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const ConsultationScreen())),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.auto_awesome,
                              color: AppColors.primary),
                          const SizedBox(height: 8),
                          Text('AI Consultation',
                              style: tt.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('Get personalized skin advice from Glowy',
                              style: tt.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 10),
                          _miniButton('Start Chat'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlowCard(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primarySoft.withValues(alpha: .55),
                          AppColors.cream.withValues(alpha: .8),
                        ],
                      ),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const AnalyzerScreen())),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.face_retouching_natural,
                              color: AppColors.primary),
                          const SizedBox(height: 8),
                          Text('Skin Analyzer',
                              style: tt.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('Scan your skin & get instant analysis',
                              style: tt.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 10),
                          _miniButton('Analyze Now'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Products promo
              GlowCard(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.cream,
                    AppColors.primarySoft.withValues(alpha: .55),
                  ],
                ),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ProductsScreen())),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome,
                                  color: AppColors.primary, size: 18),
                              const SizedBox(width: 6),
                              Text('Unlock your best glow',
                                  style: tt.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Explore personalized products curated for your skin',
                              style: tt.bodySmall?.copyWith(
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 10),
                          _miniButton('Explore'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('🧴', style: TextStyle(fontSize: 48)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniMetric(IconData icon, String label, String value) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: tt.bodySmall),
          const Spacer(),
          Text(value,
              style: tt.bodySmall?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _miniButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white, size: 10),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final bool dot;
  final VoidCallback? onTap;
  const _CircleIconButton({required this.icon, this.dot = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primarySoft.withValues(alpha: .5)),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 22),
          ),
          if (dot)
            const Positioned(
              right: 8,
              top: 8,
              child: CircleAvatar(
                  radius: 4, backgroundColor: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
