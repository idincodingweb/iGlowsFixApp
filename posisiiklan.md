# 🚀 Rencana Monetisasi & Arsitektur Iklan - iGlows App

Dokumen ini berisi draf strategi monetisasi *hybrid* (AdMob + Premium QRIS) serta regulasi limitasi kuota untuk menjaga keseimbangan antara pendapatan, keamanan akun, biaya server AI, dan pengalaman pengguna (UI/UX).

---

## 1. Skema Akses Pengguna (Free vs Premium)

Aplikasi akan dibagi menjadi dua jalur akses berdasarkan kontribusi monetisasi:

### A. Versi Gratis (Free Tier)
*   **Monetisasi:** Ditopang sepenuhnya oleh iklan Google AdMob.
*   **Limitasi Chat AI:** Maksimal **200 chat per hari** per pengguna (sistem akan mereset kuota harian secara otomatis setiap hari).
*   **Aturan Kemunculan Iklan:** Iklan *full screen* wajib muncul **setiap 10 obrolan chat selesai**.

### B. Versi Premium (Premium Tier)
*   **Monetisasi:** Pembayaran langsung melalui Payment Gateway QRIS Lokal.
*   **Harga Langganan:** **Rp 30.000 / bulan** (Sekali bayar, akses 30 hari).
*   **Benefit Pengguna:** 
    *   **Bebas Iklan (Ad-Free):** Seluruh format iklan AdMob dinonaktifkan untuk akun premium.
    *   **Unlimited Akses:** Tidak ada batasan kuota chat harian ke AI Beauty Assistant.

---

## 2. Arsitektur & Penempatan Format Iklan AdMob (Free User Only)

Penempatan iklan dirancang agar tetap mematuhi kebijakan Google AdMob (*Policy Compliance*) untuk menghindari risiko *invalid traffic* atau *banned*.

### A. Interstitial Ads (Iklan Video/Gambar Full Layar)
*   **Penempatan:** Di dalam halaman AI Chat obrolan dengan *Glowy*.
*   **Logika Pemicu (Trigger):** `if (userChatCount % 10 == 0) { showInterstitialAd(); }`
*   **Tujuan:** Mengamankan biaya API server AI sekaligus memberikan *break* alami yang bisa diprediksi oleh pengguna saat berkonsultasi.

### B. Native Ads / Banner Ads (Iklan Sejajar Konten)
*   **Penempatan:** Tab Notifikasi Aplikasi.
*   **Layouting:** Iklan diposisikan **di bagian paling bawah dari daftar notifikasi** secara sejajar (mengikuti *flow* visual aplikasi).
*   **Tujuan:** Mendapatkan impresi yang stabil dan organik tanpa merusak estetika UI utama aplikasi yang sudah bersih dan rapi.

---

## 3. Strategi Pengamanan Sistem & Keuntungan Bisnis

*   **Keamanan Akun AdMob:** Batasan per 10 chat mencegah adanya *accidental clicks* (klik tidak sengaja) yang dibenci Google, karena kemunculan iklan terstruktur dan tidak tiba-tiba di tengah ketikan user.
*   **Kontrol Biaya Operasional:** Batasan 200 chat harian berfungsi sebagai pengaman finansial (*kill-switch*) agar penggunaan token API AI oleh satu *user* gratisan tidak membengkak melebihi pendapatan iklan yang mereka hasilkan.
*   **Optimalisasi Arus Kas (Cash Flow):** Menggunakan QRIS gratisan/lokal memangkas biaya potongan toko aplikasi pihak ketiga (15%-30%), sehingga dana Rp 30.000 dari *user* premium bisa masuk hampir 100% utuh untuk modal memutar iklan akuisisi pengguna baru (User Acquisition via FB Ads).
