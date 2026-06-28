# iGlows — Project Overview & Architecture

> Aplikasi skincare companion bergaya minimalis premium, dibangun dengan **Flutter Android-first** dan backend **Firebase Auth + Firestore**. Dokumen ini merangkum struktur awal untuk Splash, Onboarding, Login, Register, tema pink, dan setup build APK.

---

## 1. Stack & Environment

| Layer | Teknologi |
| --- | --- |
| UI / Client | Flutter ≥ 3.22, Dart ≥ 3.3, Material 3 |
| Theme | `google_fonts` Poppins, palette pink feminine |
| Auth | `firebase_auth` Email/Password |
| Database | `cloud_firestore` untuk profil user awal |
| Local State | `shared_preferences` untuk flag onboarding |
| Build | GitHub Actions APK release |

---

## 2. Struktur Folder

```text
lib/
├── core/
│   └── theme/
│       └── app_theme.dart
├── features/
│   ├── auth/
│   │   ├── auth_service.dart
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── onboarding/
│   │   └── onboarding_screen.dart
│   └── splash/
│       └── splash_screen.dart
├── firebase_options.dart
└── main.dart
```

---

## 3. Navigasi Awal

```text
SplashScreen
├── belum onboarding       → OnboardingScreen
├── sudah onboarding login → HomeScreen
└── sudah onboarding guest → LoginScreen
```

Routes:

| Route | Screen |
| --- | --- |
| `/` | Splash |
| `/onboarding` | Onboarding 3 screen |
| `/login` | Login email/password |
| `/register` | Register email/password |
| `/home` | Placeholder home |

---

## 4. Tema Visual

| Token | Warna |
| --- | --- |
| Primary | `#FF8FB1` |
| Soft Pink | `#FFC2D4` |
| Cream | `#FFF5EE` |
| Rose Gold | `#E8B4A0` |
| Background | `#FFF9FB` |
| Text Primary | `#2D2A32` |
| Text Secondary | `#7A7280` |

Style: minimalis premium, rounded, banyak whitespace, soft feminine.

---

## 5. Firebase Auth Flow

### Register

1. Input nama, email, password.
2. `FirebaseAuth.createUserWithEmailAndPassword`.
3. `updateDisplayName(name)`.
4. Simpan dokumen awal ke `users/{uid}`:

```json
{
  "name": "User Name",
  "email": "user@email.com",
  "createdAt": "serverTimestamp"
}
```

### Login

1. Input email + password.
2. `FirebaseAuth.signInWithEmailAndPassword`.
3. Redirect ke `/home`.

---

## 6. SOP Lanjutan

- Jangan ganti SDK constraint tanpa izin.
- Warna UI selalu dari `AppColors`.
- Feature baru masuk folder `lib/features/<nama_feature>`.
- Service/backend logic dipisah dari screen.
- Setelah tugas selesai, repack project menjadi `iglows-flutter.zip`.