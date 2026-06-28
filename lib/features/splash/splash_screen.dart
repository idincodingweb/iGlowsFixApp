import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    String nextRoute = '/onboarding';
    try {
      await Future.delayed(const Duration(milliseconds: 1500));

      bool seenOnboarding = false;
      try {
        final prefs = await SharedPreferences.getInstance();
        seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
      } catch (e) {
        debugPrint('SharedPreferences error: $e');
      }

      User? user;
      try {
        if (Firebase.apps.isNotEmpty) {
          user = FirebaseAuth.instance.currentUser;
        }
      } catch (e) {
        debugPrint('FirebaseAuth error: $e');
      }

      if (!seenOnboarding) {
        nextRoute = '/onboarding';
      } else if (user == null) {
        nextRoute = '/login';
      } else {
        nextRoute = '/home';
      }
    } catch (e, st) {
      debugPrint('Splash bootstrap error: $e\n$st');
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppColors.primarySoft],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: .25),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(Icons.spa_rounded,
                    size: 64, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'iGlows',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Glow with confidence',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
