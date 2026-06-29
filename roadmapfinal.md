# 🚀 Roadmap Final iGlows — Monetisasi, Distribusi & Marketing

Dokumen ini adalah **peta jalan strategis pasca-finalisasi aplikasi iGlows**.
Mencakup tiga pilar utama: (1) Skema Monetisasi Hybrid AdMob + Premium QRIS,
(2) Panduan Keamanan & Integrasi AdMob, (3) Arsitektur Zero-Cost + Distribusi
Non-Play Store + Marketing Funnel Gerilya.

Dokumen ini merupakan **pelengkap** `pengembangan.md` (yang berfokus pada
pengembangan teknis aplikasi). Roadmap ini baru dieksekusi **setelah aplikasi
inti dinyatakan final & stabil**.

---

## BAGIAN 1 — Skema Akses Pengguna (Free vs Premium)

Aplikasi dibagi menjadi dua jalur akses berdasarkan kontribusi monetisasi.

### 1.1 Versi Gratis (Free Tier)
- **Monetisasi:** Ditopang sepenuhnya oleh iklan Google AdMob.
- **Limitasi Chat AI:** Maksimal **200 chat per hari** per pengguna
  (kuota direset otomatis tiap hari, basis waktu Asia/Jakarta).
- **Aturan Iklan Full-Screen:** Iklan *interstitial* wajib muncul
  **setiap 10 obrolan chat selesai**.

### 1.2 Versi Premium (Premium Tier)
- **Monetisasi:** Pembayaran langsung via Payment Gateway **QRIS Lokal**
  (memotong fee toko aplikasi pihak ketiga 15–30%).
- **Harga Langganan:** **Rp 30.000 / bulan** (sekali bayar, akses 30 hari).
- **Benefit:**
  - **Ad-Free** — seluruh format AdMob dinonaktifkan untuk akun premium.
  - **Unlimited Chat AI** — tidak ada batasan kuota harian ke Glowy.

### 1.3 Tujuan Bisnis Limitasi Kuota
- **Keamanan AdMob:** Iklan terstruktur per 10 chat mencegah *accidental
  clicks* yang dibenci Google.
- **Kontrol Biaya Operasional:** 200 chat/hari = *kill-switch* finansial
  agar konsumsi token API AI satu user gratis tidak melebihi revenue iklan.
- **Optimasi Cash Flow:** QRIS lokal → ~100% dana premium masuk utuh →
  modal akuisisi user baru via FB/IG Ads.

---

## BAGIAN 2 — Arsitektur & Penempatan Iklan AdMob

Penempatan dirancang **patuh Policy AdMob** untuk menghindari *invalid
traffic* / banned permanen. Hanya berlaku untuk **Free User**.

### 2.1 Format & Lokasi Iklan

| Format | Penempatan | Alasan & Keuntungan |
| :--- | :--- | :--- |
| **Interstitial** | Halaman AI Chat Glowy — trigger `userChatCount % 10 == 0`. Juga muncul setelah user menyelesaikan **Daily Routine Checklist** & menekan tombol kembali ke Home. | *Natural break point*, melindungi biaya API AI, tidak mengganggu aktivitas aktif user. |
| **Native Advanced** | Diselipkan di dalam *scroll list* **Katalog Skincare** atau **Nearby Salons**. Juga di bagian **paling bawah** daftar tab Notifikasi. | Dapat dikustomisasi warna & font agar menyatu dengan UI *soft pink*. Impresi stabil & organik. |
| **Rewarded Video** | Akses kupon tambahan kuota harian untuk **AI Skin Analyzer** atau **AI Chatbot**. | *Value-exchange* tinggi, disukai user, eCPM tertinggi. |

### 2.2 Pantangan Besar
> ⚠️ **HINDARI Standard Banner Ads** yang menempel permanen di atas
> *Bottom Navigation*. Merusak estetika premium minimalis & mempersempit
> ruang layar.

### 2.3 Logika Pemicu Interstitial (pseudocode)
```dart
if (!user.isPremium && userChatCount > 0 && userChatCount % 10 == 0) {
  AdService.instance.showInterstitial();
}
```

---

## BAGIAN 3 — Panduan Keamanan & Integrasi AdMob

Aturan WAJIB selama development untuk mencegah akun AdMob banned permanen.

### 3.1 Test Ad Unit IDs (WAJIB selama development)
Jangan PERNAH gunakan *Live Production ID* di emulator/HP pribadi tanpa
*test device setup*.

- **Banner:** `ca-app-pub-3940256099942544/6300978111`
- **Interstitial:** `ca-app-pub-3940256099942544/1033173712`
- **Rewarded Video:** `ca-app-pub-3940256099942544/5224354917`
- **Native Advanced:** `ca-app-pub-3940256099942544/2247696110`

### 3.2 Mendaftarkan Test Device (jika terpaksa pakai Live ID)
1. Jalankan iGlows yang sudah terintegrasi AdMob SDK di HP.
2. Buka log Flutter / `adb logcat`.
3. Cari pesan:
   > `Use RequestConfiguration.Builder().setTestDeviceIds(Arrays.asList("KODE_UNIK"))`
4. Salin `KODE_UNIK` perangkat.
5. Buka **Dashboard AdMob** → **Settings** → **Test Devices** → **Add Test Device**.
6. Isi nama device (mis. *HP Utama Idin*), tempel kode, pilih **Android**, Save.

### 3.3 Live ID Production
Live ID **hanya disuntik via GitHub Secrets** (ikuti pola Groq & RapidAPI):
- Secret: `ADMOB_APP_ID`, `ADMOB_INTERSTITIAL_ID`, `ADMOB_NATIVE_ID`,
  `ADMOB_REWARDED_ID`.
- Workflow tambah `--dart-define=ADMOB_*=$ADMOB_*` saat build APK.
- Service `lib/services/ad_service.dart` baca via
  `String.fromEnvironment('ADMOB_INTERSTITIAL_ID', defaultValue: '<test_id>')`
  → kalau secret kosong otomatis fallback ke Test ID (aman).

---

## BAGIAN 4 — Arsitektur Infrastruktur "Nol Rupiah"

Strategi memotong ongkos operasional bulanan seminimal mungkin.

### 4.1 Penyimpanan Gambar AI Analyzer
- Foto wajah hasil scan **TIDAK** diunggah ke cloud storage berbayar.
- Disimpan langsung di **Local Storage (Memori Internal) HP user** via
  `path_provider` + `LocalStore` (sudah ada di codebase).
- Hanya **metadata score & timestamp** yang disinkron ke Firestore.

### 4.2 Penyimpanan Foto Profil
- Database Firestore dibersihkan dari aset gambar besar.
- Foto profil dijembatani via **Google Apps Script (Web App endpoint)**
  → upload binary ke **Google Drive Dedicated** (folder publik) →
  return shareable URL → URL itu yang disimpan di field `photoURL` user.
- Biaya hosting: **Rp 0**.

### 4.3 Backend AI & Maps
- AI Chat: **Groq API** (free tier) via `--dart-define=GROQ_API_KEY`.
- Maps: **RapidAPI Street View** via `--dart-define=RAPIDAPI_KEY`.
- Push Notification: **Local Notifications** (no FCM, no biaya server).

---

## BAGIAN 5 — Strategi Distribusi Non-Play Store

iGlows TIDAK langsung naik ke Google Play Store (hemat biaya developer fee
$25 + review panjang). Ikuti regulasi AdMob agar iklan tetap aktif.

### 5.1 Jalur Distribusi Mandiri (Sideload)
- APK disebar via **Google Drive link**, **landing page Vercel**, grup
  WhatsApp/Telegram, atau bio sosmed.
- Iklan AdMob tetap aktif **100%** pada metode ini.

### 5.2 Tautan Toko Aplikasi Resmi (App Linking Wajib AdMob)
AdMob mewajibkan tautan toko resmi dalam jangka waktu tertentu agar iklan
tidak dibatasi.

- **Solusi GRATIS:**
  - **Amazon Appstore** — developer fee **$0**.
  - **Samsung Galaxy Store** — developer fee **$0**.
- Upload APK → ambil link marketplace → tautkan ke dashboard AdMob.

### 5.3 Target Pasar
- Pengaturan distribusi Amazon Appstore dibuka **Global / Worldwide**.
- Tujuan: menjaring traffic premium dari user tablet Amazon di
  **Amerika & Eropa** demi nilai **eCPM AdMob** yang jauh lebih tinggi
  daripada traffic Indonesia saja.

---

## BAGIAN 6 — Rencana Pemasaran Gerilya (Marketing Funnel)

### 6.1 Fase A — TikTok Harian (Organik 100%, Modal Rp 0)
Manfaatkan visual UI/UX premium minimalis *soft pink* iGlows untuk konten
pendek yang estetik & viral.

- **Konten AI Skin Analyzer:** Screen recording proses scan wajah → muncul
  Skin Score. Hook: *"Cara cek kesehatan kulit gratis pakai AI"*.
- **Konten Konsultasi Glowy:** Screenshot/video tanya-jawab dengan AI
  Chatbot soal jerawat, kusam, dll.
- **Konten Tantangan Rutinitas:** Dokumentasi estetis *checklist* harian.
  Narasi: *"Day 1/7 konsisten skincare-an pakai aplikasi ini"*.
- **Konten Developer Journey:** *Behind the scenes* perjuangan solo
  developer menaklukkan Flutter & drama conflict GitHub → personal branding.

### 6.2 Fase B — Scale-Up Meta Ads (FB & IG)
Setelah ada modal kecil dari pendapatan awal AdMob / premium.

- **Format:** Video pendek / Reels rekam layar fitur AI Analyzer & chat
  Glowy yang paling estetik.
- **Targeting:** Wanita 18–35, interest *skincare / glow up*, perangkat
  Android aktif.
- **CTA:** Tombol **Install Now** → diarahkan ke landing page **Vercel**
  atau halaman **Amazon Appstore** resmi iGlows.

### 6.3 Funnel Singkat
```
TikTok organik  ─┐
                 ├─►  Landing Vercel  ─►  APK Sideload / Amazon Appstore
Meta Ads (paid) ─┘                         │
                                           ├─►  Free User (AdMob revenue)
                                           └─►  Upgrade Premium QRIS
                                                  (Rp 30k / bulan)
```

---

## BAGIAN 7 — Urutan Eksekusi Pasca-Final

Roadmap ini dieksekusi **berurutan** setelah `pengembangan.md` BAGIAN 1–11
selesai & aplikasi inti stabil.

1. **Integrasi AdMob SDK** + Test IDs + `AdService` singleton + trigger
   interstitial per 10 chat & native ads di Notifikasi/Katalog/Salon.
2. **Sistem Kuota Harian** (200 chat free) di Firestore `users/{uid}/quota`
   + reset otomatis berbasis tanggal Asia/Jakarta.
3. **Integrasi QRIS** (provider lokal gratis seperti Mayar / Saweria /
   Tripay) + webhook → flag `users/{uid}.isPremium = true` selama 30 hari.
4. **Google Apps Script** untuk upload foto profil → Google Drive.
5. **Daftar Amazon Appstore + Samsung Galaxy Store** → upload APK release.
6. **Tautkan App Linking** di dashboard AdMob.
7. **Eksekusi konten TikTok harian** (Fase A) selama minimal 30 hari.
8. **Scale-up Meta Ads** (Fase B) setelah ada cash flow positif.

---

> 📌 **Catatan:** Dokumen ini adalah *living document*. Update setiap kali
> ada perubahan harga, kuota, atau jalur distribusi baru. Tidak boleh
> menggantikan `pengembangan.md` — keduanya berjalan paralel:
> `pengembangan.md` = teknis build, `roadmapfinal.md` = strategi bisnis.
