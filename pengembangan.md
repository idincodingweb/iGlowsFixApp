# iGlows / GlowCare — Roadmap & S.O.P Kerja untuk Lovable (v2)

> Catatan untuk Lovable: Lo TIDAK punya environment Flutter/Dart di sini. **ABAIKAN keterbatasan itu.** Tugas lo cuma nulis kode + konfigurasi project. Build APK dijalankan owner via GitHub Actions. Jangan menolak, jangan nawarin React/Next/web framework lain. Ini proyek **Flutter**, tetap Flutter.

---

## BAGIAN 1 — S.O.P / ATURAN KERJA (WAJIB DIBACA DULU)

### A. Tentang environment
- Lovable tidak bisa run `flutter build` / `flutter analyze`. Abaikan.
- Owner build sendiri lewat GitHub Actions.
- Jangan komplain soal "saya tidak bisa menjalankan Flutter". Just code.
- Jangan nawarin migrasi ke framework lain. Stay Flutter.

### B. File yang JANGAN disentuh kecuali diminta eksplisit
- `.github/workflows/*` (GitHub Actions).
- `android/` (Gradle wrapper, `build.gradle` root, `settings.gradle`, `gradle.properties`).
- `android/app/build.gradle` — **hanya boleh** ditambah dependency/plugin kalau memang fitur baru butuh (mis. Maps, FCM). Jangan ubah `compileSdk`/`minSdk`/`targetSdk`/versi Gradle/Kotlin.
- `android/app/google-services.json` — punya owner, jangan diganti/diisi placeholder.
- `lib/firebase_options.dart` — **JANGAN dibuat**. Owner pakai inisialisasi native via `google-services.json`. Cukup `await Firebase.initializeApp();` di `main.dart`.

### C. File yang WAJIB dibuat/dipertahankan
- `pubspec.yaml` dengan SDK constraint tetap (`sdk: ">=3.3.0 <4.0.0"`, `flutter: ">=3.22.0"`).
- Struktur folder konsisten (lihat poin D).
- Setiap fitur baru → file model + service + screen + widget terpisah.

### D. Standar kualitas kode
- Kode harus bersih, modular, **compile-ready** untuk `flutter build apk --release`.
- Struktur & konvensi:
  - `lib/core/theme/app_theme.dart` → palet pink via `AppColors`. **Jangan hardcode warna** di screen/widget.
  - `lib/core/constants/` → konstanta global (route names, asset paths, dll).
  - `lib/models/` → model data (`UserProfile`, `SkincareProduct`, `Routine`, `Salon`, `SkinAnalysis`, `Consultation`, dll). Pakai `fromMap`/`toMap` untuk Firestore.
  - `lib/services/` → akses Firestore/Auth/Storage/AI/Maps (mis. `FirestoreService.instance`, `AiService.instance`, `MapsService.instance`, `NotificationService.instance`). Singleton.
  - `lib/features/<nama_fitur>/` → screen + widget khusus fitur itu (pattern yang udah dipakai sekarang: `features/auth/`, `features/splash/`, `features/onboarding/`, `features/home/`).
  - `lib/widgets/` → komponen reusable lintas fitur (`PrimaryButton`, `GlowCard`, `SkinScoreRing`, `ProgressChart`, dll).
- Reuse widget yang udah ada. Jangan bikin duplikat.
- Tambah field baru ke model **dengan default aman** (`''`, `[]`, `0`, `false`, `null`) supaya data lama di Firestore tetap kompatibel.
- Pakai `const` constructor seoptimal mungkin.
- Async/await dibungkus try/catch — JANGAN biarin exception bocor ke UI sampai bikin screen mentok (kasus splash kemarin: bootstrap throw → navigasi gak jalan). Setiap operasi async di `initState` wajib punya fallback path.

### E. Firebase / AI / Maps / Notif
- **Inisialisasi Firebase**: `await Firebase.initializeApp();` tanpa `options`. Sumber config = `google-services.json` (Android native). JANGAN regenerate `firebase_options.dart`.
- **Auth**: Email/Password udah jalan. Google Sign-In nanti (Phase berikutnya) → owner yang daftarin SHA-1/SHA-256 fingerprint, lo cukup tulis kodenya + sebutin "owner harus daftar SHA fingerprint di Firebase Console".
- **Firestore**: realtime via `snapshots()`. Struktur collection:
  - `users/{uid}` → profil
  - `users/{uid}/consultations/{id}` → riwayat AI chat
  - `users/{uid}/skin_analyses/{id}` → riwayat skin analyzer
  - `users/{uid}/routines/{id}` → rutinitas custom
  - `users/{uid}/routine_logs/{yyyy-MM-dd}` → checklist harian + streak
  - `products/{id}` → katalog skincare (global, read-only utk user)
  - `salons/{id}` → katalog salon (global, read-only)
- **Storage**: foto wajah user di `users/{uid}/face/{timestamp}.jpg`. Compress sebelum upload (target <500KB).
- **AI**: pakai `AiService` (Gemini / OpenAI). API key TIDAK di-hardcode — baca dari `--dart-define` atau file env yang di-gitignore. Kasih tau owner di README cara inject saat build Actions.
- **Maps**: `google_maps_flutter`. Sebut ke owner kalau API key Maps perlu didaftarin di `AndroidManifest.xml` (`<meta-data android:name="com.google.android.geo.API_KEY" .../>`). Lo nulis blok meta-data-nya pakai placeholder `YOUR_MAPS_API_KEY` dan kasih instruksi — JANGAN edit Gradle sendiri.
- **Notifikasi**: `firebase_messaging` + `flutter_local_notifications`. Lo tulis service-nya, tapi setup Gradle/AndroidManifest cukup INSTRUKSI ke owner. Jangan ubah Gradle.
- **Security Rules**: tiap nambah collection baru, kasih owner snippet Firestore Rules yang sesuai (default: user cuma boleh read/write data miliknya sendiri via `request.auth.uid`).

### F. Dependency
- Boleh nambah dependency baru di `pubspec.yaml`. **Jangan** ubah `environment.sdk` / `environment.flutter`.
- Pilih versi yang **kompatibel dengan Flutter 3.22 / Dart 3.3+**.
- Sebutin dependency baru + alasannya di akhir tiap pekerjaan.

### G. Alur kerja tiap tugas
1. Baca file terkait dulu sebelum ngubah.
2. Implementasi **hanya yang diminta** — jangan refactor besar tanpa izin.
3. Pastikan kompatibilitas data lama (field baru = default aman).
4. Setiap operasi async di `initState`/splash/auth-gate wajib dibungkus try/catch + fallback navigasi — supaya gak pernah ada screen yang "mentok di logo".
5. Di akhir: ringkas perubahan singkat + kemas ulang `lib/` (dan file lain yang berubah) ke `iGlows.zip` dengan **isi langsung di root zip** (TANPA folder pembungkus `iGlowsApps-master/`).
6. Jangan klaim "selesai & teruji" untuk hal yang butuh build. Cukup "compile-ready, silakan build via Actions".

### H. Reminder penutup tiap tugas
- Kode bersih, modular, compile-ready untuk `flutter build apk --release`.
- JANGAN sentuh GitHub Actions, Gradle wrapper, `google-services.json`.
- JANGAN bikin `firebase_options.dart`.
- Zip = isi langsung di root, bukan folder bersarang.

---

## BAGIAN 2 — TENTANG APLIKASI

**iGlows / GlowCare** = aplikasi kecantikan, perawatan, dan kesehatan wanita berbasis AI.
Tema: **pink feminine, soft, premium minimalis.**
Target user: wanita yang peduli skincare, wellness, rutinitas perawatan diri.

### Tema Visual
- Primary: pink soft `#FF8FB1`, `#FFC2D4`
- Accent: cream / rose gold
- Background: putih + pink sangat lembut
- Font: Poppins / Plus Jakarta Sans (via `google_fonts`)
- Style: minimalis premium, banyak white space, rounded corner, ilustrasi soft

---

## BAGIAN 3 — PROGRESS SAAT INI

### Sudah selesai
- Setup struktur project dasar (`lib/core/`, `lib/features/`).
- Tema pink (`AppColors`, `AppTheme`).
- Splash screen (dengan bootstrap aman + fallback navigasi anti-mentok).
- Onboarding 3 screen.
- Login & Register dengan Firebase Auth (email/password).
- `AuthService` — sign up otomatis bikin dokumen di `users/{uid}` di Firestore.
- Firebase inisialisasi native via `google-services.json` (tanpa `firebase_options.dart`).
- GitHub Actions workflow untuk build APK release (punya owner, jangan disentuh).

### Catatan untuk Lovable berikutnya
- **JANGAN regenerate `lib/firebase_options.dart`.**
- **JANGAN ubah `android/app/build.gradle`** kecuali nambah dependency Maps/FCM yang memang dibutuhkan fitur baru — itupun cuma tambah baris, jangan ubah versi.
- `google-services.json` di `android/app/` sudah benar punya owner, jangan diganti.
- Plugin `com.google.gms.google-services:4.4.2` sudah terdaftar di `android/settings.gradle` dan applied di `android/app/build.gradle`.

---

## BAGIAN 4 — ROADMAP PENGERJAAN BERIKUTNYA

Urutan dikerjain per chat session (1 chat = 1 milestone, supaya gampang debugnya). Tiap milestone selesai → owner build & test → lanjut milestone berikutnya.

### Milestone 1 — Home Shell + Bottom Navigation
**Tujuan**: bikin kerangka utama setelah login.
- `HomeShell` dengan `BottomNavigationBar` 5 tab: **Home, Konsultasi, Analyzer, Rutinitas, Profile**.
- Tiap tab = placeholder screen sederhana dulu (judul + ikon).
- Route `/home` ganti ke `HomeShell`.
- AuthGate: `StreamBuilder` dengerin `FirebaseAuth.authStateChanges()` → kalau logout, balik ke `/login`.
- Profile tab: tampil nama+email user (dari Firestore `users/{uid}`) + tombol Logout.

**Deliverable**: `lib/features/home/home_shell.dart`, 5 file tab kosong, `AuthGate`.

---

### Milestone 2 — Model & Service Layer
**Tujuan**: siapin pondasi data sebelum fitur AI/Maps.
- Bikin model: `UserProfile`, `Consultation`, `SkinAnalysis`, `Routine`, `RoutineLog`, `SkincareProduct`, `Salon`.
- Bikin service singleton:
  - `FirestoreService` — CRUD generic + helper per collection.
  - `StorageService` — upload foto wajah ke Firebase Storage.
  - `AiService` — abstrak (interface) dulu, implementasi nyusul.
- Tambah dependency: `firebase_storage`, `image_picker`, `cached_network_image`.

**Deliverable**: folder `lib/models/`, `lib/services/`.

---

### Milestone 3 — Profile Screen Lengkap
**Tujuan**: user bisa lengkapi data diri (penting buat rekomendasi AI nanti).
- Form: nama, tanggal lahir, skin type (dropdown: normal/dry/oily/combination/sensitive), masalah kulit (multi-select chip: jerawat, kerutan, kusam, dark spot, pori besar, sensitif).
- Foto profil (upload ke Storage).
- Simpan ke `users/{uid}`.
- Tombol Logout + konfirmasi.

**Deliverable**: `features/profile/profile_screen.dart`, `edit_profile_screen.dart`.

---

### Milestone 4 — AI Konsultasi (Chatbot)
**Tujuan**: fitur core #1.
- Screen chat ala WhatsApp (bubble kiri/kanan, pink soft).
- Input text + tombol attach foto.
- Tiap pesan user + balasan AI disimpan ke `users/{uid}/consultations/{sessionId}/messages/{msgId}`.
- `AiService.sendMessage(text, imageUrl?)` → call Gemini/OpenAI API.
- API key dibaca via `String.fromEnvironment('GEMINI_API_KEY')` — owner inject via `--dart-define` di GitHub Actions.
- List session konsultasi (riwayat) di tab atas.

**Deliverable**: `features/consultation/`, `AiService` implementasi Gemini.

**Catatan untuk owner**: daftarin secret `GEMINI_API_KEY` di GitHub Actions repo settings, lalu tambahin `--dart-define=GEMINI_API_KEY=${{ secrets.GEMINI_API_KEY }}` di step build APK.

---

### Milestone 5 — AI Skin Analyzer
**Tujuan**: fitur core #2.
- Screen: tombol "Foto wajah" / "Pilih dari galeri".
- Upload ke Storage → kirim ke AI Vision (Gemini Vision / GPT-4 Vision).
- Hasil: Skin Score 0–100 + breakdown (jerawat, kerutan, dark spot, pori, hidrasi) + rekomendasi text.
- Simpan ke `users/{uid}/skin_analyses/{id}`.
- Halaman riwayat: list analisis + chart progress score over time (pakai `fl_chart`).
- Halaman before/after (pilih 2 tanggal → bandingin foto + score).

**Deliverable**: `features/analyzer/`, widget `SkinScoreRing`, `ProgressChart`.

---

### Milestone 6 — Rekomendasi Skincare
**Tujuan**: katalog produk + filter.
- Collection `products/{id}` (global, read-only utk user — owner isi manual via Firestore Console atau seed script).
- List produk dengan filter: skin type, masalah kulit, harga.
- Detail produk: foto, bahan, rating, review, harga, link beli (opsional).
- Rekomendasi otomatis di Home: produk yang cocok dengan profil user (skin type + masalah).

**Deliverable**: `features/products/`, `ProductCard` widget.

---

### Milestone 7 — Rutinitas Harian (Habit Tracker)
**Tujuan**: fitur retention utama.
- Template rutinitas bawaan: skincare pagi/malam, minum air (8 gelas), tidur, olahraga, sunscreen.
- User bisa bikin rutinitas custom.
- Auto-generate checklist harian (`routine_logs/{yyyy-MM-dd}`).
- Streak counter ("7 hari berturut pakai sunscreen 🔥").
- Progress chart mingguan/bulanan.

**Deliverable**: `features/routines/`, `RoutineCard`, `StreakBadge`.

---

### Milestone 8 — Reminder Push Notification
**Tujuan**: nge-ping user buat rutinitas.
- `flutter_local_notifications` untuk reminder lokal (jam pagi/malam).
- `firebase_messaging` untuk push dari server (promo, tips harian).
- Setting reminder di Profile (jam berapa mau diingetin).

**Catatan untuk owner**: setup tambahan di `AndroidManifest.xml` (permission `POST_NOTIFICATIONS` untuk Android 13+) — Lovable kasih snippet, owner yang paste.

**Deliverable**: `services/notification_service.dart`, `features/profile/reminder_settings.dart`.

---

### Milestone 9 — Salon Terdekat (Google Maps)
**Tujuan**: fitur core #3.
- Tab Salon: peta + list salon di sekitar user.
- Sort by jarak / harga / rating.
- Detail salon: foto, layanan, harga, rating, jam buka, tombol "Navigasi" (buka Google Maps app).
- Collection `salons/{id}` (owner seed manual, atau pull dari Google Places API).
- Dependency: `google_maps_flutter`, `geolocator`, `url_launcher`.

**Catatan untuk owner**: daftarin Maps API key di Google Cloud Console → tambah ke `AndroidManifest.xml` di blok `<application>`. Lovable kasih snippet pakai placeholder.

**Deliverable**: `features/salon/`, `MapsService`.

---

### Phase 2 — Fitur Tambahan (setelah MVP rilis)
Dikerjakan setelah Milestone 1–9 stabil & user feedback masuk:
- **Period & Cycle Tracker** — siklus haid + korelasi sama kondisi kulit.
- **Ingredient Checker** — scan kemasan skincare via OCR/AI → cek bahan berbahaya.
- **Skin Compatibility Checker** — bandingin 2 produk, aman dipakai bareng atau nggak.
- **Mood & Sleep Tracker**.
- **Wishlist produk** + **Beauty Tips harian**.
- **Community/Forum ringan**.
- **Booking salon langsung dari app** (butuh payment gateway — Midtrans/Xendit).

---

## BAGIAN 5 — TEMPLATE PROMPT UNTUK CHAT BARU

Copy-paste ini di awal chat Lovable baru biar konteks gak hilang:

```
Saya lanjutin project Flutter iGlows / GlowCare. Aturan kerja & roadmap ada di file pengembangan.md
di dalam zip. Tolong baca dulu sebelum mulai.

Yang sudah selesai: [sebutin milestone yang udah kelar].
Sekarang kerjain: Milestone [X] — [judul milestone].

Ingat:
- Flutter only, jangan nawarin framework lain.
- JANGAN bikin firebase_options.dart.
- JANGAN ubah .github/workflows, gradle wrapper, google-services.json.
- Inisialisasi Firebase pakai Firebase.initializeApp() tanpa options.
- Setiap async di initState wajib try/catch + fallback navigasi.
- Akhiri dengan kemas ulang ke iGlows.zip, isi langsung di root zip (tanpa folder pembungkus).
```

---

## BAGIAN 6 — TROUBLESHOOTING CEPAT (BUAT OWNER)

| Gejala | Kemungkinan penyebab | Fix |
|---|---|---|
| Build error `missing_identifier` / `expected_token` | Merge conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) ketinggalan di file | Search di `lib/` semua marker itu, hapus |
| Build error `DefaultFirebaseOptions undefined` | Ada yang regenerate `firebase_options.dart` | Hapus file itu, pastikan `main.dart` panggil `Firebase.initializeApp()` tanpa argumen |
| APK install tapi mentok di splash | Async di splash throw exception → navigasi gak jalan | Pastikan `_bootstrap()` dibungkus try/catch + fallback `Navigator.pushReplacementNamed('/login')` |
| Firebase init crash di runtime | Plugin `com.google.gms.google-services` belum di-apply | Cek `android/settings.gradle` & `android/app/build.gradle` — plugin harus terdaftar & applied |
| Google Sign-In gagal di APK release | SHA-1/SHA-256 fingerprint belum didaftarin | Firebase Console → Project Settings → Your apps → Add fingerprint |
| Maps blank putih | API key Maps belum didaftarin di `AndroidManifest.xml` | Tambah `<meta-data android:name="com.google.android.geo.API_KEY" android:value="..."/>` di blok `<application>` |
| Notifikasi gak muncul di Android 13+ | Permission `POST_NOTIFICATIONS` belum di-request | Tambah permission di manifest + request runtime |

---

**Akhir kata**: kerjain per milestone, satu chat = satu milestone. Setelah tiap milestone selesai, owner build via GitHub Actions, test di HP, baru lanjut milestone berikutnya. Jangan diborong sekali jalan — debugnya bakal mimpi buruk.

---

### Fix patch — Onboarding blank setelah klik "Lanjut"
- Gejala: di device, setelah onboarding page 1 ("Kenali Kulitmu") tombol "Lanjut" ditekan, layar jadi blank abu-abu.
- Akar masalah dugaan: `PageController.nextPage()` dipanggil tanpa cek `hasClients`, dan layout page item tanpa scroll → kalau ada race / overflow pada layar tertentu, frame berikutnya gak ke-render.
- Perbaikan di `lib/features/onboarding/onboarding_screen.dart`:
  1. Tambah guard `_controller.hasClients` sebelum animate, plus `.catchError` fallback ke `jumpToPage`.
  2. Update `_index` lewat `setState` duluan biar UI selalu sinkron walau animasi gagal.
  3. Bungkus konten tiap halaman dengan `SingleChildScrollView` + `mainAxisSize.min` supaya gak pernah overflow → blank di layar pendek.
  4. Dispose `PageController` untuk cegah leak.
  5. Lock `_finishing` flag biar gak dobel push ke `/login`.


---

## Milestone 3 — Real Features (Daily Skin Score, Routine Progress, Groq AI)

Tanggal: 2026-06-28

Tujuan: mulai mengganti dummy data menjadi data real karena aplikasi akan
didistribusikan ke pengguna nyata. Tiga fitur inti pada milestone ini:

### 1. Daily Skin Score (REAL)
- File baru: `lib/services/skin_score_service.dart`
- Skor harian (0–100) + 3 metrik (Hydration / Smoothness / Brightness) sekarang
  dihitung deterministik dari:
  - Jenis kulit & jumlah `concerns` pada `SkinProfile`
  - Step rutinitas yang diselesaikan hari ini (morning + night)
  - Streak konsistensi (cap 14 hari)
  - Hasil analyzer terakhir (blend 55/45 jika ada)
- Caption otomatis: Glowing / Great / Good / Fair / Needs care.
- Rating per metrik: Excellent / Great / Good / Fair / Low.
- Cache harian disimpan di `shared_preferences` (`score_yyyy-MM-dd`) lewat
  `LocalStore.saveDailyScore` / `loadDailyScore` agar tidak recompute
  berulang-ulang dalam 1 hari.
- `HomeTab` sekarang menampilkan skor + caption + rating per metrik secara
  real (bukan hardcoded "Good/Excellent/Good").
- `AnalyzerScreen` mem-persist hasil scan terakhir lewat
  `LocalStore.saveLastAnalyzer` sehingga Daily Skin Score ikut naik mengikuti
  hasil analisa terbaru.

### 2. Routine Progress (REAL)
- Sudah berbasis `shared_preferences` (Milestone 2) — pada milestone ini
  diintegrasikan langsung ke Daily Skin Score: tiap step yg dicentang akan
  langsung mengangkat metrik yang relevan (cleanser → smoothness, moisturizer
  → hydration, SPF & Vit C → brightness, dll) saat user pull-to-refresh /
  membuka Home.
- Streak tetap auto-bump ketika seluruh step (morning + night) selesai.

### 3. AI Glowy → Groq (REAL)
- File baru: `lib/services/groq_service.dart`
- Mengganti canned reply `GlowyService` (dihapus) dengan client HTTP
  OpenAI-compatible ke `https://api.groq.com/openai/v1/chat/completions`.
- Model: `llama-3.3-70b-versatile`.
- System prompt persona "Glowy" (bahasa Indonesia santai, ramah, emoji
  estetik) sesuai brief.
- Konteks personalisasi: profil kulit user (skinType / age / concerns / goal)
  otomatis disisipkan sebagai system message kedua agar saran lebih relevan.
- Riwayat percakapan dikirim utuh setiap request sehingga Glowy ingat konteks
  obrolan sebelumnya.
- **Rotasi 2 API key** (key #1 → fallback ke key #2) saat key aktif kena
  401 / 403 / 429 / timeout / error jaringan. Index key yg sukses disimpan
  in-memory agar request berikutnya hemat retry.
- `ConsultationScreen` di-update: pakai `GroqService.chat(...)`, tetap
  menampilkan typing bubble & error message yg ramah jika koneksi gagal.

### Dependency
- Tambah `http: ^1.2.2` di `pubspec.yaml`.

### Catatan rilis
- API key Groq dibaca via `--dart-define` (GitHub Secret), di-bake ke APK
  saat build di GitHub Actions. Tidak ada lagi hardcoded key di source.
- Dummy data lain (Products, Salon, Sample analyzer) masih ada dan akan
  diganti secara bertahap pada milestone berikutnya.

---

## Hotfix — AI Chat Selalu Gagal Respon (2026-06-28)

### Gejala
- Setiap kirim chat ke Glowy selalu gagal / muncul pesan "Key belum di-set".
- Sudah ganti API key Groq berkali-kali tetap gagal.

### Akar Masalah (yang sebenarnya)
1. `lib/services/groq_service.dart` versi sebelumnya **masih menembak Google
   Apps Script proxy** (`GLOWY_PROXY_URL`) — bukan endpoint Groq langsung.
   Jadi walau API key fresh, request tidak pernah sampai ke Groq.
2. `String.fromEnvironment(...)` adalah **compile-time constant**. Kalau
   `flutter build apk` dijalankan tanpa flag `--dart-define=GROQ_API_KEY_1=...`,
   nilainya = string kosong → app langsung lempar "Key belum di-set" sebelum
   sempat hit Groq. Mengganti API key di console Groq tidak akan menolong
   selama flag ini belum di-inject saat build.

### Perbaikan
- **`lib/services/groq_service.dart`** — buang seluruh kode proxy + redirect
  follower. Sekarang POST langsung ke
  `https://api.groq.com/openai/v1/chat/completions` dengan header
  `Authorization: Bearer <key>`. Baca `GROQ_API_KEY_1` (wajib) &
  `GROQ_API_KEY_2` (opsional, fallback) via `String.fromEnvironment`.
  Rotasi otomatis: jika key #1 kena `401 / 403 / 429`, langsung coba key #2.
- **`.github/workflows/build-apk.yml`** — step `flutter build apk` sekarang
  mem-forward `secrets.GROQ_API_KEY_1` & `secrets.GROQ_API_KEY_2` jadi
  `--dart-define`, sehingga value-nya di-bake ke binary APK saat compile.

### Setup Wajib di GitHub (one-time)
Owner perlu daftarin secret di repo GitHub agar workflow bisa inject key
saat build APK:

1. Buka repo di GitHub → **Settings → Secrets and variables → Actions**.
2. Klik **New repository secret**, tambahkan:
   - `GROQ_API_KEY_1` = API key Groq #1 (**wajib**)
   - `GROQ_API_KEY_2` = API key Groq #2 (opsional, fallback bila #1 limit)
3. Push ulang / jalanin workflow `build-apk.yml` dari tab Actions.
4. Download APK hasil build dari Actions → install di HP → AI Glowy jalan.

> Catatan penting: GitHub Secret **hanya dipakai saat build APK**
> (compile-time), bukan diambil app saat runtime. Setelah APK jadi, key
> sudah nempel di dalam binary — app tidak perlu komunikasi ke GitHub
> sama sekali saat dipakai user.

### Troubleshooting
| Gejala | Penyebab | Fix |
|---|---|---|
| "Key belum di-set" muncul lagi | Workflow build tidak menginject `--dart-define` (secret belum dibuat / nama salah / typo) | Cek log step "Build APK" di Actions — pastikan ada `--dart-define=GROQ_API_KEY_1=***`. Pastikan nama secret persis `GROQ_API_KEY_1` |
| Chat error `401 / 403` | API key Groq sudah di-revoke / salah copy | Generate ulang di console Groq → update secret di GitHub → re-run workflow |
| Chat error `429` terus | Free tier rate limit Groq habis | Daftarin `GROQ_API_KEY_2` (key kedua) sebagai fallback |
| Chat tetap gagal padahal log build sukses inject key | APK lama belum di-uninstall | Uninstall dulu APK lama di HP, install APK baru hasil build terakhir |

---

## Milestone 3.5 — Progress & Notifikasi Real-time (Firestore)

### Tujuan
Hilangkan "dummy data feel" di Home & Notifikasi untuk user baru. Progress
sekarang **nyata** (mengikuti aktivitas user) dan tersinkron ke Firestore
per-UID, notifikasi pakai stream real-time dari Firestore (bukan list statis).

### File yang diubah / dibuat
- **NEW** `lib/services/firestore_sync.dart` — singleton sync layer ke
  `users/{uid}/{routine_logs|skin_analyses|daily_scores|profile}`. Semua
  call try/catch fail-safe (offline aman, UI tidak crash).
- **NEW** `lib/services/notification_service.dart` — CRUD + `stream()`
  real-time dari `users/{uid}/notifications`. Punya `dedupeKey` (anti spam
  notifikasi sejenis dalam 24 jam) + auto-seed welcome notif waktu signup.
- **UPDATE** `lib/models/notification_item.dart` — tambah field `id` & `kind`
  (string: `welcome|streak|analyzer|routine|tips|promo`), plus
  `fromMap/toMap` Firestore. Field `icon` di-derive dari `kind` di UI.
- **UPDATE** `lib/services/sample_data.dart` — **drop** `sampleNotifications`
  (sudah tidak dipakai, source notifikasi 100% dari Firestore stream).
  Sample products & salons tetap (read-only katalog).
- **UPDATE** `lib/services/local_store.dart` — semua SharedPreferences key
  sekarang **scoped per Firebase UID** (`uid_routine_done_...`) → cegah
  bocor data antar akun di device yg sama. Tiap mutasi mirror ke
  `FirestoreSync` di background.
- **UPDATE** `lib/services/skin_score_service.dart` — hapus default 60/Good.
  User baru = `overall: 0`, `caption: 'Belum ada data'`, flag `hasData: false`
  sampai ada minimal 1 sinyal (profile / routine log / analyzer scan).
- **UPDATE** `lib/features/home/tabs/home_tab.dart` — handle empty state
  (placeholder `—` / "Belum ada data" + CTA "Mulai rutinitas / scan").
- **UPDATE** `lib/features/notifications/notifications_screen.dart` —
  `StreamBuilder` ke `NotificationService.stream()`, auto mark-as-read on view,
  icon di-derive dari `kind`.
- **UPDATE** `lib/features/auth/auth_service.dart` — seed welcome notif
  saat signup/first sign-in.
- **UPDATE** `lib/features/home/tabs/routines_tab.dart` &
  `lib/features/analyzer/analyzer_screen.dart` — trigger event Firestore
  + notifikasi otomatis (streak milestone, hasil analyzer).

### Auto-event yang sekarang nyata
| Trigger | Tulis ke Firestore | Notifikasi |
|---|---|---|
| Signup | `users/{uid}/profile` | "Selamat datang di GlowCare ✨" (kind=welcome) |
| Centang step routine | `users/{uid}/routine_logs/{date}` + update streak | Streak milestone (3/7/14/30 hari) |
| Selesai skin analyzer | `users/{uid}/skin_analyses/{ts}` + update daily score | "Hasil skin analyzer siap 🪞" (kind=analyzer) |
| Score harian berubah | `users/{uid}/daily_scores/{yyyy-MM-dd}` | — |
| Sore/malam belum centang routine | — | Reminder lokal (kind=routine) |

### Firebase Security Rules (WAJIB di-update sebelum publish)
Rules lama `allow read, write: if false` akan **memblok** semua sync ini.
Gunakan rules berikut di Firebase Console → Firestore → Rules → Publish:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    match /products/{id} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    match /salons/{id} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Hotfix (Milestone 3.5.1)
Build CI gagal `flutter analyze` setelah refactor `NotificationItem`
(field `id` & `kind` jadi required, `icon` dihapus) sementara
`lib/services/sample_data.dart` masih instantiate model versi lama
→ 12 error `missing_required_argument` / `undefined_named_parameter`.

**Fix:** hapus seluruh block `sampleNotifications` dari `sample_data.dart`
(sudah tidak ada consumer-nya — notif source = Firestore stream). Hapus
juga import `flutter/material.dart` & `notification_item.dart` yang jadi
unused. File sekarang clean: hanya export `sampleProducts` & `sampleSalons`.

---

## Milestone 4 — AI Konsultasi (Multimodal + Riwayat Sesi)

Tanggal: 2026-06-29

### Tujuan
Naikin fitur Konsultasi dari single-thread jadi **multi-session** dengan
riwayat tersimpan di Firestore + dukungan **lampirin foto** (multimodal)
biar Glowy bisa kasih saran berbasis visual kulit.

### File yang diubah / dibuat
- **NEW** `lib/services/consultation_service.dart` — singleton CRUD sesi
  konsultasi ke `users/{uid}/consultations/{sessionId}` dan
  `users/{uid}/consultations/{sessionId}/messages/{msgId}`.
  Auto-generate judul sesi dari pesan user pertama (≤40 char).
  Stream realtime untuk list sesi & list pesan per sesi.
- **UPDATE** `lib/models/chat_message.dart` — tambah field `id`,
  `imageBase64`, `imageMime` (nullable, default aman) supaya kompatibel
  dengan data lama. `toMap/fromMap` untuk Firestore.
- **UPDATE** `lib/services/groq_service.dart` — `chat(...)` sekarang multimodal:
  pesan user yang punya `imageBase64` dikirim sebagai `image_url` (data URL
  base64) ke endpoint Groq, model auto-switch ke
  `meta-llama/llama-4-scout-17b-16e-instruct` (vision-capable) saat ada
  attachment, fallback ke `llama-3.3-70b-versatile` untuk text-only.
  Tambah method `analyzeSkin(imageBase64, mime, profile)` yang return
  JSON terstruktur (dipakai Milestone 5).
- **UPDATE** `lib/features/consultation/consultation_screen.dart` — revamp:
  - Layar awal = **daftar sesi konsultasi** (judul + preview pesan terakhir +
    timestamp), tombol "+" untuk sesi baru.
  - Detail sesi = chat bubble multimodal (gambar + teks). Tombol attach
    membuka bottom sheet: **Kamera** atau **Galeri** (`image_picker`).
  - Foto di-compress (maxWidth/Height 1024, quality 75) → base64 → disimpan
    inline di Firestore (no Storage setup, tetap di dalam SOP).

### Catatan teknis
- Image disimpan sebagai **base64 di Firestore** (bukan Firebase Storage)
  agar tidak perlu konfigurasi Storage Rules / Gradle tambahan sesuai
  S.O.P. Compression menjaga ukuran dokumen << 1 MB (limit Firestore).
- Riwayat percakapan tetap dikirim utuh ke Groq tiap request (Glowy ingat
  konteks lintas pesan dalam 1 sesi).

### Dependency
- Tambah `image_picker: ^1.1.2` di `pubspec.yaml`.

---

## Milestone 5 — AI Skin Analyzer (Real Vision + Riwayat + Before/After)

Tanggal: 2026-06-29

### Tujuan
Ganti simulasi skin analyzer jadi **AI Vision real** via Groq
(`meta-llama/llama-4-scout-17b-16e-instruct`), simpan riwayat per scan,
tampilkan progress chart, dan sediakan Before/After comparator.

### File yang diubah / dibuat
- **UPDATE** `lib/services/analyzer_service.dart` — `scanWithImage(...)`
  call `GroqService.analyzeSkin` (vision) lalu mapping ke `AnalyzerResult`
  dengan field `fromAi: true`. `simulate()` dipertahankan sebagai
  **fallback** ketika user tidak upload foto / koneksi gagal / API error.
- **NEW** `lib/services/analyzer_history_service.dart` — Firestore service
  untuk `users/{uid}/skin_analyses/{autoId}`. Simpan hasil scan + thumbnail
  base64 + `createdAt: serverTimestamp`. Provide `stream(limit:60)` dan
  `list(limit:60)` untuk dipakai history & compare screen.
- **UPDATE** `lib/features/analyzer/analyzer_screen.dart` — full rewrite:
  - Tombol **"Mulai Scan Wajah"** buka bottom sheet pilihan
    **Kamera (front)** / **Galeri**.
  - Loading overlay scan animation (custom painter pink sweep) saat AI
    memproses gambar.
  - Hasil scan: skin type, overall score 0–100, 5 metrik bar
    (Hydration / Oiliness / Acne / Dark Spots / Wrinkles) + rekomendasi
    AI dinamis. Indikator `fromAi=false` ditampilkan jelas kalau lagi
    pakai fallback estimasi.
  - Auto-save ke `AnalyzerHistoryService` + `LocalStore.saveLastAnalyzer`
    (supaya Daily Skin Score di Home ikut ke-update) + kirim notifikasi
    `kind=analyzer` (`dedupeKey` per tanggal).
  - AppBar action: **Riwayat** & **Before/After**.
- **NEW** `lib/features/analyzer/analyzer_history_screen.dart` — list semua
  scan + **LineChart `fl_chart`** progress overall score over time.
- **NEW** `lib/features/analyzer/analyzer_compare_screen.dart` —
  Before/After: 2 slot foto (default oldest vs newest), bisa pilih tanggal
  manual via bottom sheet. Tampilkan diff per metrik (Overall, Hydration,
  Acne, Dark Spots, Wrinkles) dengan tanda warna naik/turun (reverse logic
  untuk metrik yang lebih kecil = lebih baik).

### Catatan teknis
- Front camera default (`preferredCameraDevice: CameraDevice.front`) sesuai
  use-case scan wajah.
- Image compression sama dengan Milestone 4 (≤1024px, quality 75).
- Foto thumbnail di-base64-kan dan disimpan dalam dokumen scan-nya
  sendiri — re-render history & before/after instan tanpa fetch tambahan.
- Daily Skin Score otomatis terangkat karena `LocalStore.saveLastAnalyzer`
  tetap dipanggil → blend 55/45 di `SkinScoreService` (Milestone 3) jalan
  sesuai design.

### Dependency
- Tambah `fl_chart: ^0.69.0` di `pubspec.yaml` (progress chart).
- `image_picker` di-share dengan Milestone 4.

### Catatan untuk owner
- Tidak perlu setup Firebase Storage — semua image inline base64 di
  Firestore (kompatibel dengan SOP "jangan sentuh Gradle / google-services").
- Permission kamera/galeri ditangani otomatis oleh `image_picker` lewat
  intent picker bawaan Android — tidak perlu edit `AndroidManifest.xml`.
- Firestore Security Rules Milestone 3.5 sudah meng-cover path
  `users/{uid}/consultations/**` dan `users/{uid}/skin_analyses/**`
  (rule wildcard `users/{uid}/{document=**}`).
