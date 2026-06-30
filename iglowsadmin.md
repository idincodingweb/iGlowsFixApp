# 🖥️ iGlows Admin Dashboard — Web Version Architecture

Dokumen ini berisi spesifikasi teknis dan alur fitur untuk pembuatan sistem *backoffice* berbasis web yang digunakan oleh Admin (Owner) untuk mengelola data ekosistem aplikasi iGlows secara terpusat dan efisien dari browser.

---

## 1. Stack Teknologi & Deployment (Zero-Cost Infra)
Untuk mempertahankan prinsip efisiensi biaya operasional (margin maksimal), arsitektur dashboard admin ini dirancang menggunakan infrastruktur gratis:
- **Framework:** Murni HTML5 + Tailwind CSS + Vanilla JavaScript (atau React/Next.js statis) agar ringan.
- **Hosting / Deployment:** **Vercel / Netlify / GitHub Pages** (Gratis tisu, performa kencang via CDN, dan operasional Rp0).
- **Database Sync:** Terhubung langsung ke Firebase Project iGlows menggunakan **Firebase Web SDK v10+** (real-time stream).
- **Authentication:** Menggunakan Firebase Auth, dikunci menggunakan pengondisian *UID Admin* langsung di sisi aturan basis data.

---

## 2. Fitur Utama Admin Dashboard

### 🚀 A. Menu Broadcast Update Aplikasi & Notifikasi Global
Menu ini digunakan untuk memberikan pengumuman darurat atau memaksa pengguna memperbarui aplikasi mereka ketika versi APK terbaru dirilis.
- **Mekanisme Kerja:** Menulis dokumen baru ke dalam *collection* global `app_updates/{id}` di Firestore.
- **Respons Aplikasi Android:** Aplikasi Flutter pengguna yang sedang berjalan akan mendengarkan (*stream*) perubahan pada path ini. Begitu dokumen terbuat, aplikasi user akan otomatis memunculkan *pop-up* dialog modal: `"Versi terbaru telah tersedia! Silakan unduh APK terbaru iGlows versi V2 di sini ✨"`.

### 📝 B. Menu Suntik Postingan Artikel (Content Management System)
Sistem CMS mandiri untuk memperbarui tab *Articles* pada aplikasi mobile secara instan tanpa perlu melakukan rilis ulang APK.
- **Form Input Data:**
  - Judul Artikel (Text)
  - Kategori (*Dropdown Selection*: Wajah, Skincare, Diet, Make Up, Tubuh, dll.)
  - Estimasi Waktu Baca (Number, contoh: `6` min)
  - Nama Penulis (Text, contoh: `dr. Kirina Putri`)
  - URL Gambar Cover / Thumbnail (Text URL atau Base64 String)
  - Rich Text Konten (Isi utama artikel)
- **Aksi:** Menulis langsung dokumen ke *collection* `articles/`. Detik itu juga, tab *Articles* di HP pengguna akan menampilkan postingan terbaru secara real-time.

### 🛒 C. Menu Suntik Katalog Produk Skincare
Menu untuk menambah atau memperbarui rekomendasi produk kecantikan yang muncul di tab *Products*.
- **Form Input Data:**
  - Nama Produk (Text)
  - Kategori (*Dropdown Selection*: Cleanser, Toner, Serum, Moisturizer)
  - Harga (Number, dalam mata uang Rupiah)
  - Rating Awal (Number, contoh: `4.8`)
  - Deskripsi Khasiat Produk (Text)
  - Tag Jenis Kulit (*Multi-select Checkbox*: Kering, Berminyak, Kombinasi, Sensitif)
- **Aksi:** Menulis data langsung ke *collection* `products/` di Firestore.

---

## 3. Pengamanan Basis Data (Firebase Security Rules)

Agar data produksi iGlows aman dari eksploitasi pihak luar, hak akses tulis (*write*) ke koleksi global wajib dikunci menggunakan *UID Firebase* pribadi milik Owner. 

Salin dan perbarui kode berikut pada menu **Firebase Console ➔ Firestore Database ➔ Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Ruang data privat pengguna (Hanya user bersangkutan yang bisa akses)
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    
    // Katalog Produk (Semua user bisa baca, HANYA admin yang bisa tulis)
    match /products/{id} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == 'ISI_DENGAN_UID_FIREBASE_ADMIN_LU';
    }
    
    // Artikel Edukasi (Semua user bisa baca, HANYA admin yang bisa tulis)
    match /articles/{id} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == 'ISI_DENGAN_UID_FIREBASE_ADMIN_LU';
    }
    
    // Notifikasi Sistem & Update Global (Semua user bisa baca, HANYA admin yang bisa tulis)
    match /app_updates/{id} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == 'ISI_DENGAN_UID_FIREBASE_ADMIN_LU';
    }
    
    // Default Tolak Semua Akses Lainnya
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
