import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Placeholder sederhana untuk tab yang belum diimplementasikan.
///
/// Dipakai di Milestone 1 sambil nunggu fitur asli dibikin di milestone
/// berikutnya. Pakai widget ini di tiap tab supaya tampilannya konsisten.
class TabPlaceholder extends StatelessWidget {
  const TabPlaceholder({
    super.key,
    required this.title,
    required this.icon,
    required this.subtitle,
  });

  final String title;
  final IconData icon;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft.withValues(alpha: .35),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 56, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
