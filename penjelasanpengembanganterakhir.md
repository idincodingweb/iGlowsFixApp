Oke, ini penjelasan lengkap sistem yang udah gw bangun di iGlows:

---

1. Progress System — Dari Dummy ke Real & Persisten

Masalah sebelumnya:  
User baru daftar → langsung lihat skor 60, status "Good", progress routine udah 70%. Padahal belum ngapa-ngapain. Datanya cuma di SharedPreferences lokal dan shared antar akun (tidak scoped per user).

Solusi yang dibikin:

A. UID-Scoped Local Storage
Semua key `SharedPreferences` sekarang di-prefix dengan UID user. Contoh:
```
"routines_v2" → "routines_v2_<uid>"
"skinProfile" → "skinProfile_<uid>"
```
Artinya:
- User A login → data User A muncul
- Logout, User B login → data User B muncul (kosong kalau baru)
- Device shared antar orang = aman, nggak saling tumpang tindih

B. FirestoreSync Layer (`firestore_sync.dart`)
Setiap kali user:
- Centang step routine
- Selesai skin analyzer
- Update profil kulit

Data disimpan ke 2 tempat sekaligus:
1. SharedPreferences (untuk UI instant, bisa offline)
2. Firestore (untuk backup & multi-device sync)

Struktur Firestore:
```
users/{uid}/routine_logs/{YYYYMMDD}  → steps hari itu
users/{uid}/skin_analyses/{autoId}   → hasil scan foto
users/{uid}/daily_scores/{YYYYMMDD}  → skor harian
users/{uid}                          → streak count, last analyzer date
```

Fail-safe: Kalau write ke Firestore gagal (offline / rules salah), app tetap jalan. Nanti pas online akan sinkron ulang.

C. Skin Score → Nyata
Skor kulit sekarang cuma naik dari aktivitas nyata:

| Sinyal | Skor yang didapat |
|--------|-------------------|
| Belum ngapa-ngapain | 0 — "Belum ada data" |
| Profil kulit diisi | +5 |
| 1 step routine dicentang | +per step |
| Semua routine hari ini selesai | +streak bonus |
| Hasil analyzer foto | +skor kualitas foto (AI) |

Skor tidak lagi default 60. User baru → "—" di UI, nggak ada angka bohongan.

---

2. Notifikasi System — Real-time Firestore Stream

Masalah sebelumnya:  
Notifikasi isinya static list dummy. Nggak ada hubungan dengan aktivitas user.

Solusi yang dibikin:

A. NotificationService (`notification_service.dart`)
- Collection: `users/{uid}/notifications` (subcollection Firestore)
- Stream real-time: `StreamBuilder` langsung ke Firestore
- Auto-mark-read: saat buka screen notifikasi, semua `isRead` jadi `true`

B. Dedupe System (Anti-Spam)
Tiap notifikasi punya `dedupeKey`. Contoh:
- `welcome_v1` → cuma muncul 1x seumur hidup
- `streak_20250628` → cuma 1x per hari
- `analyzer_20250628` → cuma 1x per hari

Jadi kalau user buka analyzer 3x sehari, notifikasi "Hasil analisis siap!" cuma muncul 1x.

C. Event Notifikasi Nyata

| Trigger | Kapan Muncul | Dedupe Key |
|---------|--------------|------------|
| Welcome | Setelah sign up / login pertama | `welcome_v1` |
| Streak naik | Semua routine hari ini selesai | `streak_{tanggal}` |
| Hasil analyzer | Selesai scan foto + AI analysis | `analyzer_{tanggal}` |
| Reminder malam | Jam ≥ 19:00 & night routine belum kelar | `routine_reminder_{tanggal}` |

---

3. Cara Kerja Alur Data (End-to-End)

Scenario: User baru daftar → isi profil → centang routine

```
1. Sign Up (Firebase Auth)
   │
   ├──► AuthService seed notifikasi "Welcome" ke Firestore
   │       dedupeKey: welcome_v1 → cuma 1x
   │
   └──► LocalStore key scoped ke UID baru (kosong)

2. User isi Skin Profile (oily, acne, sensitive)
   │
   ├──► Simpan ke SharedPreferences (UID-scoped)
   │
   ├──► FirestoreSync: update users/{uid} field skinProfile
   │
   └──► SkinScoreService: recalculate → skor naik dari 0 ke 5

3. User centang "Cleanser" di Morning Routine
   │
   ├──► Simpan ke SharedPreferences: routines_v2_{uid}
   │
   ├──► FirestoreSync: write ke users/{uid}/routine_logs/{today}
   │       { "cleanser": true, "toner": false, ... }
   │
   └──► SkinScoreService: recalculate → skor naik lagi

4. User centang semua step morning + night
   │
   ├──► FirestoreSync: update users/{uid} streak +1
   │
   └──► NotificationService: cek "semua kelar?"
           Ya → kirim notif "Streak 3 hari! 🔥"
           dedupeKey: streak_{today} → cuma 1x
```

Scenario: User scan foto di Analyzer

```
1. User ambil foto → AI analysis (Groq API)
   │
   ├──► Hasil: skor 85, masalah "komedo", "kemerahan"
   │
   ├──► Simpan ke Firestore: users/{uid}/skin_analyses/{id}
   │
   ├──► FirestoreSync: update users/{uid} lastAnalyzer = today
   │
   ├──► SkinScoreService: recalculate (analyzer result masuk ke skor)
   │
   └──► NotificationService: kirim notif
         "Hasil analisis siap — skor kulit kamu 85"
         dedupeKey: analyzer_{today}
```

---

4. Sinkronisasi Multi-Device

Karena data utama di Firestore, kalau user ganti hp:

```
HP Baru → Login → LocalStore.load() → cek Firestore
                                ↓
                         Kalau lokal kosong, hydrate dari Firestore
                                ↓
                         Routine logs, skin analyses, notifikasi
                         semua muncul persis seperti di HP lama
```

---

5. Security Rules yang Wajib

Rules lo yang sekarang (`allow read, write: if false`) akan blokir semua sinkronisasi. Ganti ke versi ini:

```
users/{uid} + subcollections → hanya owner yang bisa baca/tulis
products, salons           → read-only untuk user login
default                    → deny
```

Tanpa rules ini, app tetap jalan lokal tapi progress nggak kesimpan ke cloud dan notifikasi nggak muncul.

---

6. Apa yang Di-Update di pengembangan.md

- Milestone 3.5 ditambahkan: "Progress & Notifikasi Real-time"
- `FirestoreSync` dan `NotificationService` didokumentasikan
- `LocalStore` sekarang UID-scoped
- `SkinScoreService` tidak lagi pakai default dummy
- Catatan: Firestore Security Rules wajib diganti sebelum rilis
- Hotfix 3.5.1: `sample_data.dart` dibersihkan (hapus `sampleNotifications` dummy)

---

Singkatnya: yang sebelumnya "tampilan bohongan" sekarang jadi data nyata yang tersimpan di cloud per-user, dengan notifikasi yang muncul dari aktivitas nyata user — bukan list static.
