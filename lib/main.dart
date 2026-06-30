import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/auth_gate.dart';
import 'features/home/home_shell.dart';
import 'features/reminders/reminders_screen.dart';
import 'services/reminder_service.dart';
import 'services/ads_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e, st) {
    debugPrint('Firebase init error: $e\n$st');
  }
  // Init reminder lokal — gak nge-block UI kalau gagal.
  try {
    await ReminderService.instance.init();
    final s = await ReminderService.instance.loadSettings();
    await ReminderService.instance.applySchedules(s);
  } catch (e) {
    debugPrint('Reminder init error: $e');
  }
  // M17: init AdMob — safe-fail, gak nge-block UI.
  try {
    await AdsService.instance.init();
    AdsService.instance.preloadInterstitial();
    AdsService.instance.preloadRewarded();
  } catch (e) {
    debugPrint('AdMob init error: $e');
  }
  runApp(const IGlowsApp());
}


class IGlowsApp extends StatelessWidget {
  const IGlowsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iGlows',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        // Pintu utama setelah login. AuthGate dengerin authStateChanges
        // dan otomatis balikin ke /login kalau user logout.
        '/home': (_) => const AuthGate(),
        // Kalau perlu langsung ke shell tanpa gate (mis. dari testing),
        // tetap tersedia.
        '/home-shell': (_) => const HomeShell(),
        '/reminders': (_) => const RemindersScreen(),
      },
    );
  }
}
