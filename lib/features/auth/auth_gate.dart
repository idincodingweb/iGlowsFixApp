import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/theme/app_theme.dart';
import '../home/home_shell.dart';
import 'login_screen.dart';

/// Dengerin status auth Firebase secara realtime.
///
/// - User belum login -> [LoginScreen].
/// - User udah login  -> [HomeShell].
/// - Stream lagi loading / error -> fallback aman (loader / login).
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) {
      debugPrint('AuthGate: Firebase belum siap, fallback ke LoginScreen.');
      return const LoginScreen();
    }

    late final Stream<User?> authStream;
    try {
      authStream = FirebaseAuth.instance.authStateChanges();
    } catch (e, st) {
      debugPrint('AuthGate FirebaseAuth error: $e\n$st');
      return const LoginScreen();
    }

    return StreamBuilder<User?>(
      stream: authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          // Fallback aman: arahkan ke login, jangan biarin user mentok.
          return const LoginScreen();
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }
        // Tolak sesi yang belum terverifikasi (mis. sesi lama sebelum aturan
        // verifikasi email diberlakukan). Paksa sign-out + balik ke login.
        if (!user.emailVerified) {
          // Fire-and-forget; tidak boleh blokir build().
          FirebaseAuth.instance.signOut().catchError((_) {});
          return const LoginScreen();
        }
        return const HomeShell();
      },
    );
  }
}
