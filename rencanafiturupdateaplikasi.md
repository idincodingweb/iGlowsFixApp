# Arsitektur & Spesifikasi Integrasi Dashboard Admin — iGlows

Dokumen ini menjelaskan rancangan sistem Dashboard Admin mandiri berbasis *Zero-Cost Cloud* untuk menyuntikkan data pembaruan (*in-app update*) dan konten berita/tips harian secara dinamis ke aplikasi iGlows.

---

## 1. Alur Kerja Sistem (Data Flow)
Sistem ini menggunakan arsitektur *serverless* gratisan dengan memanfaatkan Google Sheets sebagai database dan Google Apps Script sebagai jembatan API (REST API).

    [ Dashboard Admin (Web) ] 
              │
              ▼ (HTTP POST / Kirim Data)
    [ Google Apps Script (API) ]
              │
              ▼ (Simpan/Tulis Data)
    [ Google Sheets (Database) ]
              │
              ▲ (HTTP GET / Ambil Data Saat App Terbuka)
    [ Aplikasi iGlows (Flutter) ]

---

## 2. Struktur Data Database (Google Sheets)

Untuk mendukung fitur injeksi data dari Admin ke Aplikasi, dibuat dua tabel (sheet) utama dengan struktur kolom sebagai berikut:

### Tabel A: app_config (Untuk Sistem Update)
Tabel ini hanya berisi satu baris data aktif untuk memantau versi aplikasi terbaru.
*   `latest_version` (String): Versi aplikasi terbaru di server (contoh: "1.0.3").
*   `download_url` (String): Link unduhan file APK terbaru (Amazon Appstore / Vercel Storage).
*   `force_update` (Boolean): Nilai TRUE jika user wajib *update* sebelum masuk aplikasi, FALSE jika opsional.

### Tabel B: news_feed (Untuk Suntik Berita & Tips)
Tabel ini menampung daftar berita atau tips harian yang disuntikkan secara dinamis.
*   `id` (Integer): ID unik berita.
*   `title` (String): Judul berita/tips (contoh: "Tips Glowing Minggu Ini ✨").
*   `content` (String): Isi pesan atau artikel singkat.
*   `action_url` (String, Optional): Link eksternal jika ada (misal link artikel/produk).
*   `created_at` (Timestamp): Tanggal berita dibuat.

---

## 3. Fitur Utama Dashboard Admin
Dashboard Admin dibuat menggunakan *framework* web sederhana yang dideploy secara gratis (misal via Vercel/Netlify) dengan fungsi utama:

1.  **Form Injeksi Update Aplikasi:** Input khusus untuk mengubah `latest_version`, memperbarui `download_url`, dan mencentang opsi `force_update`.
2.  **Form Suntik Berita & Pengumuman:** Input formulir untuk menulis judul, isi tips harian, dan tautan luar. Data yang di-submit akan langsung terkirim dan menambah baris baru di tabel `news_feed`.

---

## 4. Penanganan di Sisi Aplikasi Flutter (Client-Side)
Setiap kali aplikasi iGlows dibuka oleh pengguna (*App Launch*), Flutter akan mengeksekusi fungsi *Fetch Global Config* ke API Apps Script:

*   **Pengecekan Modul Update:** Flutter membaca data dari `app_config`. Jika versi lokal di HP user lebih rendah dari `latest_version` dan `force_update` bernilai TRUE, aplikasi langsung menampilkan *Pop-Up Dialog* penguncian yang memaksa user mengklik link `download_url`.
*   **Pengecekan Modul Berita:** Flutter membaca data terbaru dari `news_feed`. Data berita yang disuntikkan admin akan otomatis dirender di halaman *Home Dashboard* pada seksi *Daily Tip* atau komponen *News Banner* tanpa perlu *re-build* ulang APK.
