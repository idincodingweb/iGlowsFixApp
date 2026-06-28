# iGlows — Flutter Project

Tugas pertama sudah dikemas sebagai project Flutter Android-first:

- Tema pink feminine premium (`#FF8FB1`, `#FFC2D4`, cream, rose gold)
- Splash screen
- Onboarding 3 screen
- Login email/password
- Register email/password
- Firebase Auth + Firestore user bootstrap
- Android project scaffold
- Web/iOS placeholder scaffold
- GitHub Actions build APK

## Setup Firebase

File `lib/firebase_options.dart` masih placeholder supaya kode tetap aman dibagikan.
Sebelum rilis asli, jalankan:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Lalu aktifkan Firebase Authentication provider **Email/Password**.

## Build APK lokal

```bash
flutter pub get
flutter build apk --release
```

Output APK:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Build APK via GitHub Actions

Workflow sudah ada di:

```text
.github/workflows/build-apk.yml
```

Push folder ini ke GitHub, lalu jalankan workflow **Build Android APK**.

## Struktur penting

```text
lib/
├── core/theme/app_theme.dart
├── features/
│   ├── auth/auth_service.dart
│   ├── auth/login_screen.dart
│   ├── auth/register_screen.dart
│   ├── home/home_screen.dart
│   ├── onboarding/onboarding_screen.dart
│   └── splash/splash_screen.dart
├── firebase_options.dart
└── main.dart

android/
web/
ios/
test/
.github/workflows/build-apk.yml
```

## Catatan

Kalau Android folder ingin diregenerate sesuai versi Flutter terbaru:

```bash
flutter create . --project-name iglows --org com.iglows --platforms=android,ios,web
```
