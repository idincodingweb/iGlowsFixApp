import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingItem {
  final IconData icon;
  final String title;
  final String desc;
  const _OnboardingItem(this.icon, this.title, this.desc);
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _index = 0;
  bool _finishing = false;

  static const List<_OnboardingItem> _items = [
    _OnboardingItem(
      Icons.face_retouching_natural,
      'Kenali Kulitmu',
      'Analisa tipe kulit dan kondisi wajahmu hanya dalam hitungan detik.',
    ),
    _OnboardingItem(
      Icons.auto_awesome,
      'Rekomendasi Personal',
      'Dapatkan rangkaian skincare yang cocok khusus untukmu.',
    ),
    _OnboardingItem(
      Icons.chat_bubble_outline_rounded,
      'Konsultasi Mudah',
      'Tanya jawab langsung dengan asisten kecantikan kapan saja.',
    ),
  ];

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seen_onboarding', true);
    } catch (e) {
      debugPrint('Onboarding prefs error: $e');
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _goNext() {
    if (_finishing || !mounted) return;

    final isLast = _index >= _items.length - 1;
    if (isLast) {
      _finish();
      return;
    }

    setState(() => _index += 1);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index >= _items.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextButton(
                  onPressed: _finishing ? null : _finish,
                  child: const Text(
                    'Lewati',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _OnboardingPage(
                  key: ValueKey(_index),
                  item: _items[_index],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_items.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _finishing ? null : _goNext,
                child: _finishing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(isLast ? 'Mulai Sekarang' : 'Lanjut'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    super.key,
    required this.item,
  });

  final _OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.primarySoft.withValues(alpha: .4),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 110, color: AppColors.primary),
          ),
          const SizedBox(height: 40),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            item.desc,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
