import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../services/notification_service.dart';

/// Exception khusus untuk alur auth iGlows.
/// Dipakai supaya UI bisa menampilkan pesan yang ramah ke user
/// (misal: belum verifikasi email, email bukan gmail.com, dsb).
class AuthFlowException implements Exception {
  final String code;
  final String message;
  AuthFlowException(this.code, this.message);
  @override
  String toString() => message;
}

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Regex validasi alamat Gmail. Hanya menerima domain gmail.com
  /// (case-insensitive) dengan local-part 1-64 karakter yang umum dipakai
  /// Gmail. Mencegah pendaftaran massal dari domain disposable.
  static final RegExp _gmailRegex = RegExp(
    r'^[A-Za-z0-9](?:[A-Za-z0-9._%+-]{0,62}[A-Za-z0-9])?@gmail\.com$',
    caseSensitive: false,
  );

  static bool isValidGmail(String email) =>
      _gmailRegex.hasMatch(email.trim());

  void _ensureFirebaseReady() {
    if (Firebase.apps.isNotEmpty) return;
    throw FirebaseException(
      plugin: 'firebase_core',
      message:
          'Firebase belum siap. Pastikan google-services.json dan konfigurasi Android sudah terpasang.',
    );
  }

  /// Login email + password.
  ///
  /// Aturan iGlows:
  /// - Email wajib gmail.com.
  /// - Email wajib sudah terverifikasi (klik link di inbox Gmail).
  ///   Kalau belum, user otomatis di-signOut + kirim ulang link verifikasi,
  ///   dan dilempar [AuthFlowException] dengan code 'email-not-verified'.
  Future<UserCredential> signIn(String email, String password) async {
    _ensureFirebaseReady();
    final cleanEmail = email.trim();
    if (!isValidGmail(cleanEmail)) {
      throw AuthFlowException(
        'invalid-gmail',
        'Login hanya menerima alamat @gmail.com.',
      );
    }
    final cred = await _auth.signInWithEmailAndPassword(
        email: cleanEmail, password: password);
    final user = cred.user;
    // Reload untuk memastikan status emailVerified up-to-date.
    try {
      await user?.reload();
    } catch (_) {}
    final fresh = _auth.currentUser ?? user;
    if (fresh != null && !fresh.emailVerified) {
      // Coba kirim ulang link verifikasi, lalu sign-out paksa.
      try {
        await fresh.sendEmailVerification();
      } catch (_) {}
      try {
        await _auth.signOut();
      } catch (_) {}
      throw AuthFlowException(
        'email-not-verified',
        'Email kamu belum diverifikasi. Cek inbox/Spam Gmail kamu, lalu klik link verifikasi sebelum login.',
      );
    }
    // Pastikan welcome notification ada (fail-safe).
    try {
      await NotificationService.instance.seedWelcomeIfNeeded();
    } catch (_) {}
    return cred;
  }

  /// Daftar akun baru.
  ///
  /// Aturan iGlows:
  /// - Email wajib gmail.com (anti pembuatan akun massal dari domain random).
  /// - Setelah akun dibuat, langsung kirim email verifikasi & sign-out user.
  ///   User harus klik link verifikasi sebelum bisa login.
  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _ensureFirebaseReady();
    final cleanEmail = email.trim();
    if (!isValidGmail(cleanEmail)) {
      throw AuthFlowException(
        'invalid-gmail',
        'Pendaftaran hanya menerima alamat @gmail.com.',
      );
    }
    final cred = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail, password: password);
    final user = cred.user;
    await user?.updateDisplayName(name);
    await _db.collection('users').doc(user!.uid).set({
      'name': name,
      'email': cleanEmail,
      'emailVerified': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Kirim email verifikasi.
    try {
      await user.sendEmailVerification();
    } catch (_) {}
    // Paksa sign-out: user harus verifikasi dulu baru bisa login.
    try {
      await _auth.signOut();
    } catch (_) {}
    return cred;
  }

  /// Kirim ulang email verifikasi untuk email tertentu.
  /// Butuh password karena Firebase hanya bisa kirim verifikasi pada user
  /// yang sedang sign-in.
  Future<void> resendVerification({
    required String email,
    required String password,
  }) async {
    _ensureFirebaseReady();
    final cleanEmail = email.trim();
    if (!isValidGmail(cleanEmail)) {
      throw AuthFlowException(
        'invalid-gmail',
        'Hanya alamat @gmail.com yang didukung.',
      );
    }
    final cred = await _auth.signInWithEmailAndPassword(
        email: cleanEmail, password: password);
    try {
      await cred.user?.sendEmailVerification();
    } finally {
      try {
        await _auth.signOut();
      } catch (_) {}
    }
  }

  Future<void> signOut() async {
    _ensureFirebaseReady();
    await _auth.signOut();
  }
}
