import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/auth_gate.dart';
import 'features/home/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e, st) {
    debugPrint('Firebase init error: $e\n$st');
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
      },
    );
  }
}
