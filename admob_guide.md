# Panduan Keamanan & Integrasi AdMob — iGlows

Dokumen ini berisi aturan wajib untuk pemasangan Google AdMob guna menghindari *Invalid Traffic* (Trafik Tidak Valid) yang bisa menyebabkan akun *banned* permanen selama masa pengembangan aplikasi.

---

## 1. Daftar ID Iklan Uji Coba (Test Ad Unit IDs)
**WAJIB** menggunakan ID di bawah ini selama aplikasi dalam tahap *development*, *testing*, atau saat dijalankan di emulator/HP pribadi tanpa *test device setup*. Jangan pernah menggunakan *Live Production ID* di tahap ini.

*   **Banner Ads:** `ca-app-pub-3940256099942544/6300978111`
*   **Interstitial Ads:** `ca-app-pub-3940256099942544/1033173712`
*   **Rewarded Video Ads:** `ca-app-pub-3940256099942544/5224354917`
*   **Native Advanced Ads:** `ca-app-pub-3940256099942544/2247696110`

---

## 2. Cara Mendaftarkan Perangkat Uji Coba (Test Device)
Jika terpaksa menguji aplikasi menggunakan *Live Production ID*, perangkat yang digunakan harus didaftarkan terlebih dahulu ke dashboard AdMob agar Google hanya mengirimkan "Test Ads".

### Langkah-langkah:
1. Hubungkan HP ke laptop/komputer dan jalankan aplikasi iGlows yang sudah terintegrasi AdMob SDK.
2. Buka terminal/konsol log Flutter (atau gunakan perintah `adb logcat`).
3. Cari pesan dari log AdMob yang berbunyi seperti ini:
   > *`Use RequestConfiguration.Builder().setTestDeviceIds(Arrays.asList("KODE_UNIK_PERANGKAT_ANDA")) to get test ads on this device.`*
4. Salin `KODE_UNIK_PERANGKAT_ANDA` dari log tersebut.
5. Buka **Dashboard Google AdMob** di browser.
6. Pergi ke menu **Settings** > **Test Devices** > klik **Add Test Device**.
7. Masukkan nama perangkat (misal: *HP Utama Idin*) dan tempel (*paste*) kode unik yang sudah disalin tadi.
8. Pilih platform (**Android**) lalu klik **Save**.

---

## 3. Strategi Format & Penempatan Iklan Premium
Untuk menjaga estetika UI/UX premium minimalis iGlows, ikuti aturan penempatan berikut:

| Format Iklan | Lokasi Penempatan | Alasan & Keuntungan |
| :--- | :--- | :--- |
| **Rewarded Video** | Akses tambahan kuota kupon harian untuk *AI Skin Analyzer* atau *AI Chatbot*. | *Value-exchange* tinggi, disukai user, dan nilai *eCPM* paling mahal. |
| **Native Advanced** | Diselipkan di dalam *scroll list* Katalog Skincare atau *Nearby Salons*. | Dapat dikustomisasi warna & *font*-nya agar menyatu sempurna dengan UI aplikasi. |
| **Interstitial** | Muncul sesaat setelah user menyelesaikan *Daily Routine Checklist* dan menekan tombol kembali ke Home. | Diletakkan pada *natural break point* (jeda alami) sehingga tidak mengganggu aktivitas aktif user. |

> ⚠️ **PANTANGAN BESAR:** Hindari penggunaan *Standard Banner Ads* yang menempel permanen di atas *Bottom Navigation* karena akan merusak estetika desain premium dan mempersempit ruang layar aplikasi.

---

## 4. Taktik Distribusi Non-Play Store (Hemat Modal)
Karena iGlows tidak langsung diunggah ke Google Play Store untuk menghemat biaya awal, ikuti regulasi kebijakan AdMob berikut agar iklan tetap aktif:

1. **Jalur Sideload Tetap Berjalan:** Iklan AdMob akan tetap muncul 100% pada APK yang disebarkan secara manual via Drive, media sosial, atau grup pesan.
2. **Kewajiban Tautan Toko Resmi (App Linking):** AdMob mewajibkan aplikasi ditautkan ke toko aplikasi resmi yang diakui Google dalam jangka waktu tertentu guna menghindari pembatasan iklan.
3. **Solusi Gratis Toko Pihak Ketiga:** Gunakan **Amazon Appstore** atau **Samsung Galaxy Store**. Pendaftaran akun developer di platform tersebut **100% Gratis**. Unggah APK ke sana, lalu tautkan *link* marketplace tersebut ke dashboard Google AdMob Anda.
