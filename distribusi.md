# Peta Jalan Strategis & Rencana Eksekusi iGlows

Dokumen ini merangkum strategi arsitektur, monetisasi, dan pemasaran gerilya hemat biaya untuk peluncuran aplikasi iGlows tanpa menggunakan Google Play Store pada tahap awal.

---

## 1. Arsitektur Infrastruktur "Nol Rupiah" (Zero-Cost Cloud)
Strategi khusus untuk memotong ongkos operasional bulanan (*operational cost*) seminimal mungkin dengan memanfaatkan penyimpanan lokal dan ekosistem gratis Google.

*   **Penyimpanan Gambar AI Analyzer:** Seluruh foto wajah yang diunggah oleh pengguna untuk keperluan *scan* AI tidak akan dikirim ke *cloud storage* berbayar. Foto tersebut diproses lalu disimpan langsung di dalam **Local Storage (Memori Internal) HP User** masing-masing.
*   **Penyimpanan Foto Profil:** Database utama dibersihkan dari aset gambar besar. Foto profil pengguna akan dijembatani menggunakan **Google Apps Script** dan disimpan secara gratis di dalam **Google Drive Dedicated** sebagai *hosting* aset.

---

## 2. Strategi Distribusi & Keamanan Monetisasi AdMob
Rencana pengamanan akun AdMob dari risiko *banned* akibat pembatasan trafik, serta jalur *hosting* resmi alternatif yang gratis.

*   **Jalur Distribusi Mandiri (Sideload):** Aplikasi disebarkan dalam bentuk file APK secara mandiri melalui *link* Google Drive, landing page Vercel, atau pesan instan. Iklan AdMob dipastikan tetap aktif 100% pada metode ini.
*   **Tautan Toko Aplikasi Resmi (App Linking):** Memenuhi syarat AdMob wajib tautan toko resmi menggunakan **Amazon Appstore** (Akun Developer **100% Gratis**). APK akan diunggah ke Amazon dan tautannya dihubungkan ke dashboard AdMob agar iklan aman dari pemblokiran *Invalid Traffic*.
*   **Target Pasar (Targeting):** Pengaturan distribusi di Amazon Appstore dibuka secara **Global (Worldwide)** untuk menjaring *traffic* premium dari pengguna tablet/gadget Amazon di Amerika/Eropa demi mendapatkan nilai eCPM AdMob yang jauh lebih tinggi.

---

## 3. Rencana Pemasaran Gerilya (Marketing Funnel)
Strategi mendatangkan ribuan pengguna aktif harian secara organik dan semi-organik setelah aplikasi dinyatakan final.

### Fase A: Optimasi Konten TikTok Harian (Organik 100%)
Memanfaatkan visual UI/UX premium minimalis (*soft pink*) dari iGlows untuk menciptakan konten video pendek yang estetik dan berpotensi viral.
*   **Konten AI Skin Analyzer:** Video rekam layar proses pemindaian wajah hingga munculnya *Skin Score*. Fokus pada *hook*: *"Cara cek kesehatan kulit gratis pakai AI"*.
*   **Konten Konsultasi "Glowy":** Tangkapan layar (*screenshot*) atau video interaksi tanya-jawab menarik dan informatif dengan AI Chatbot mengenai masalah kulit (misal: solusi jerawat).
*   **Konten Tantangan Rutinitas:** Dokumentasi estetis penggunaan *checklist* harian aplikasi. Narasi video: *"Day 1/7 konsisten skincare-an pakai aplikasi ini"*.
*   **Konten Developer Journey:** Cerita di balik layar (*behind the scenes*) perjuangan *solo developer* menaklukkan kode Flutter dan drama *conflict* GitHub untuk membangun personal *branding*.

### Fase B: Scale-Up Meta Ads (Facebook & Instagram Ads)
Dilakukan jika sudah memiliki modal kecil dari pendapatan awal AdMob untuk mempercepat ledakan jumlah *download*.
*   **Format Iklan:** Menggunakan video pendek/Reels hasil rekam layar fitur AI Analyzer atau chat Glowy yang paling estetik.
*   **Targeting Spesifik:** Mengincar demografi wanita, ketertarikan pada *skincare/glow up*, serta pengguna aktif perangkat Android.
*   **Call to Action (CTA):** Tombol "Install Now" diarahkan langsung ke *landing page* download Vercel atau halaman Amazon Appstore resmi milik iGlows.
