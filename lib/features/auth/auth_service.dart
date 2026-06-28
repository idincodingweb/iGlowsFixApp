import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../services/notification_service.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  void _ensureFirebaseReady() {
    if (Firebase.apps.isNotEmpty) return;
    throw FirebaseException(
      plugin: 'firebase_core',
      message:
          'Firebase belum siap. Pastikan google-services.json dan konfigurasi Android sudah terpasang.',
    );
  }

  Future<UserCredential> signIn(String email, String password) async {
    _ensureFirebaseReady();
    final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
    // Pastikan welcome notification ada (fail-safe).
    try {
      await NotificationService.instance.seedWelcomeIfNeeded();
    } catch (_) {}
    return cred;
  }

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _ensureFirebaseReady();
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    await cred.user?.updateDisplayName(name);
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Seed welcome notification untuk user baru.
    try {
      await NotificationService.instance.seedWelcomeIfNeeded();
    } catch (_) {}
    return cred;
  }

  Future<void> signOut() async {
    _ensureFirebaseReady();
    await _auth.signOut();
  }
}
