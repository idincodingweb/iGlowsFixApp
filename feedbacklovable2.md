Cukup paham state-nya. Gw kasih feedback jujur sesuai progres terbaru lo.

---

🔥 Feedback Lovable v2 — Post M13 + Settings Pages + Launcher Icon

✅ Yang Naik Level dari Feedback Sebelumnya

1. Lo eksekusi cepet & bersih.
Dari feedback v1 ke sekarang lo udah ngerjain: M12 (Salon → Articles), M13 (reminder wording + exact alarm), 4 settings pages (Notifikasi/Privasi/Bantuan/Tentang), dan launcher icon adaptive full-bleed. Itu 4 milestone dalam waktu singkat tanpa nambah dependency — disiplin lo ke "zero-cost, zero-bloat" tetep konsisten. Banyak dev di posisi lo udah mulai `pub add` random.

2. Keputusan ganti Salon → Articles itu jenius secara product.
Map tile OSM emang sering throttle, dan salon dummy gak punya retention value. Articles = konten yang user buka tiap hari = DAU naik tanpa biaya server. Lo trade fitur "wow tapi mati" jadi fitur "boring tapi hidup". Ini thinking PM senior, bukan dev.

3. M13 (exact alarm + timezone auto-detect) itu fix yang banyak app gede aja masih bocor.
- `exactAllowWhileIdle` + `requestExactAlarmsPermission()` di Android 12+ → reminder lo bakal jalan pas user butuh, bukan random 30 menit telat.
- Auto-detect WIB/WITA/WIT dari `timeZoneOffset` → user Makassar/Jayapura gak ketrigger jam Jakarta. Detail kecil yang bikin retensi naik diem-diem.
- Wording "Pengingat iGlows aktif ✨" >>> "Test reminder ✨" — kelar masalah trust.

4. Settings pages lo gak template-an.
Privacy page lo nyebut eksplisit: data apa dikumpulin, di-host di mana (Firebase + lokal), AI pihak ketiga (Groq), lokasi (RapidAPI), hak hapus data + kontak email dev. Itu udah mendekati standar GDPR/UU PDP Indonesia — Play Store reviewer happy. About page dengan link LinkedIn + IG via `launchUrl(externalApplication)` clean, bukan webview jorok.

5. Adaptive icon full-bleed tanpa nambah `flutter_launcher_icons` plugin.
Lo manual edit `mipmap-anydpi-v26/ic_launcher.xml` set foreground transparan + background = bitmap. Hasil: ikon edge-to-edge mirip Instagram tanpa dependency build-time. Senior move.

---

⚠️ Yang Mulai Jadi Risiko di Skala Berikutnya

1. `sample_articles.dart` (383 baris) = hardcoded di binary.
Sekarang 12 artikel masih oke, tapi:
- Tiap nambah/edit artikel = release versi baru ke Play Store (review 1-3 hari).
- User di versi lama gak pernah liat artikel baru → konten lo "mati" buat mereka.
- Saran: pindahin ke Firestore collection `articles/` (lo udah pakai Firestore). Cache lokal via `LocalStore` biar offline-first. Cost-nya nol (Firestore free tier 50K reads/day cukup banget buat 1000 DAU × 10 artikel = 10K reads).
- Bonus: bisa A/B test judul, track which article paling dibaca → data buat scaling konten.

2. `Image.network` di list artikel tanpa caching disk.
Lo udah handle loader + fallback, tapi tiap scroll user re-download dari Unsplash. Boros kuota user + Unsplash bisa rate-limit kalo viral. Fix: ganti ke `cached_network_image` (3KB dependency, worth it) — disk cache otomatis, satu line ganti widget.

3. Folder `lib/features/salon/` masih ada tapi dead code.
Lo bilang "tidak dihapus, mungkin dipakai lagi". Realita: 6 bulan lagi lo lupa, dependency-nya rot, kena warning analyzer terus. Saran: kalau emang mau retain → pindah ke branch `feature/salon-archive` di git, hapus dari main. YAGNI principle.

4. Settings notifikasi pakai `SharedPreferences` (`notif_*`), tapi `reminder_service` baca dari mana?
Worth dicek: kalau user toggle "Reminder skincare = off" di settings, apakah `reminder_service.fire*()` bener-bener respect flag itu? Kalau cuma disimpen tanpa dibaca = settings palsu = trust user rusak. Wajib end-to-end test toggle ini.

5. About page social icon — LinkedIn lo bikin custom widget "in".
Niat zero-deps gw appreciate, tapi `font_awesome_flutter` itu 1 dependency yang nyumbang puluhan icon brand resmi (LinkedIn, IG, TikTok, YouTube, X) — sekali install, semua sosmed future-proof. Trade-off: +200KB APK. Untuk app yang udah pakai split ABI, masih reasonable. Lo decide aja.

6. Belum ada Crashlytics / error reporting.
Lo udah pakai Firebase, tinggal `firebase_crashlytics` 1 line aktivasi. Tanpa ini lo blind di production — user crash diem-diem, uninstall, lo gak tau kenapa. Ini bukan optional buat app yang mau scaling.

---

🎯 Prioritas Next Sprint (Versi Gw)

| # | Task | Effort | Impact |
|---|------|--------|--------|
| 1 | Crashlytics integration | 30 menit | 🔥🔥🔥 |
| 2 | Articles → Firestore (CMS-able) | 3 jam | 🔥🔥🔥 |
| 3 | Verify settings notif toggle benar-benar dipakai reminder_service | 1 jam | 🔥🔥 |
| 4 | `cached_network_image` swap | 15 menit | 🔥🔥 |
| 5 | Hapus `lib/features/salon/` (arsipkan ke branch) | 10 menit | 🔥 |
| 6 | Tambah Privacy Policy page dengan URL publik (wajib Play Store) | 1 jam | 🔥🔥🔥 |

#6 itu yang sering bikin app ke-reject Play Store — kalau lo nge-collect email + foto, Play Store wajib ada link Privacy Policy yang publicly accessible (bukan in-app aja). Bisa host gratis di GitHub Pages atau Notion public page.

---

🧠 Overall Verdict

Lo udah cross dari "indie dev coba-coba" ke "solo founder yang siap launch". Arsitektur solid, UX makin polished, technical debt masih manageable. Bottleneck lo sekarang bukan teknis lagi — tapi distribusi & konten:

- Siapa tau soal iGlows? (marketing)
- Kalo udah tau, apa alasannya buka tiap hari? (artikel + reminder = lo udah on track)
- Kalo udah harian, kenapa upgrade ke premium? (clear value prop di paywall — belum gw liat detailnya)

Push terus, bro. Lo udah lebih jauh dari 90% indie dev yang gw liat. 🚀
