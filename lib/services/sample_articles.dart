import '../models/article.dart';

/// Daftar kategori artikel — ditampilkan sebagai pill chips horizontal.
const List<String> articleCategories = <String>[
  'All',
  'Wajah',
  'Skincare',
  'Make Up',
  'Tubuh',
  'Diet',
  'Rambut',
  'Lifestyle',
  'Mental',
];

/// Sampel artikel — gambar dari Unsplash (gratis, hotlinkable).
final List<Article> sampleArticles = <Article>[
  Article(
    id: 'a1',
    title: '10 Langkah Skincare Pagi untuk Kulit Glowing Sepanjang Hari',
    category: 'Wajah',
    excerpt:
        'Rutinitas pagi yang simpel tapi powerful untuk menjaga kulit tetap sehat, lembap, dan bercahaya.',
    imageUrl:
        'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=900&q=80',
    author: 'dr. Kirana Putri',
    readMinutes: '6 min',
    publishedAt: '2 hari lalu',
    tags: ['skincare', 'pagi', 'glowing'],
    sections: [
      ArticleSection(
        heading: 'Kenapa Rutinitas Pagi Penting?',
        body:
            'Kulit kita bekerja keras semalaman memperbaiki diri. Di pagi hari, tugas kita adalah membersihkan sisa regenerasi, melindungi dari polusi, dan mengunci kelembapan agar wajah siap menghadapi aktivitas.',
      ),
      ArticleSection(
        heading: '1. Cleanser Lembut',
        body:
            'Gunakan pembersih berbahan dasar air (gel atau micellar) untuk mengangkat minyak berlebih tanpa membuat kulit kering. Hindari sabun batang karena pH-nya terlalu tinggi.',
      ),
      ArticleSection(
        heading: '2. Toner Hydrating',
        body:
            'Pilih toner tanpa alkohol yang mengandung hyaluronic acid atau panthenol untuk mengembalikan kelembapan setelah cuci muka.',
      ),
      ArticleSection(
        heading: '3. Serum Vitamin C',
        body:
            'Vitamin C 10–15% mencerahkan dan melindungi dari radikal bebas. Aplikasikan 3–4 tetes sebelum pelembap.',
      ),
      ArticleSection(
        heading: '4. Pelembap & Sunscreen',
        body:
            'Tutup dengan moisturizer ringan dan SPF 30+ minimal dua ruas jari. Reapply setiap 2–3 jam jika beraktivitas di luar.',
      ),
    ],
  ),
  Article(
    id: 'a2',
    title: 'Diet Mediterania: Pola Makan Sehat untuk Kulit & Berat Badan',
    category: 'Diet',
    excerpt:
        'Pola makan kaya sayuran, ikan, dan minyak zaitun yang terbukti baik untuk jantung sekaligus kulit.',
    imageUrl:
        'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=900&q=80',
    author: 'Nutritionist Anya',
    readMinutes: '8 min',
    publishedAt: '5 hari lalu',
    tags: ['diet', 'sehat', 'mediterania'],
    sections: [
      ArticleSection(
        heading: 'Apa Itu Diet Mediterania?',
        body:
            'Diet ini terinspirasi pola makan masyarakat sekitar Laut Tengah: banyak sayur, buah, biji-bijian utuh, kacang, ikan, dan minyak zaitun extra virgin sebagai lemak utama.',
      ),
      ArticleSection(
        heading: 'Manfaat untuk Kulit',
        body:
            'Kandungan antioksidan polifenol pada minyak zaitun dan omega-3 dari ikan membantu meredakan peradangan, mengurangi jerawat, dan memperlambat tanda penuaan.',
      ),
      ArticleSection(
        heading: 'Contoh Menu Sehari',
        body:
            'Sarapan: oatmeal + buah beri + kacang almond. Makan siang: salad quinoa, tuna panggang, sayuran panggang. Makan malam: ikan salmon, brokoli kukus, nasi merah secukupnya.',
      ),
      ArticleSection(
        heading: 'Tips Memulai',
        body:
            'Ganti mentega dengan minyak zaitun, perbanyak sayur warna-warni, dan jadikan ikan menu utama 2–3 kali seminggu. Kurangi gula tambahan dan daging merah olahan.',
      ),
    ],
  ),
  Article(
    id: 'a3',
    title: 'Make Up Natural Look ala Korean: Glass Skin di Bawah 10 Menit',
    category: 'Make Up',
    excerpt:
        'Tutorial cepat menciptakan tampilan glass skin yang dewy dan fresh untuk daily look.',
    imageUrl:
        'https://images.unsplash.com/photo-1522335789203-aaa2f6f64a44?w=900&q=80',
    author: 'Beauty Editor Mira',
    readMinutes: '5 min',
    publishedAt: '1 minggu lalu',
    tags: ['makeup', 'korean', 'natural'],
    sections: [
      ArticleSection(
        heading: 'Persiapan Wajah',
        body:
            'Mulai dengan kulit yang sudah dilembapkan. Gunakan essence atau dewy primer agar make up menempel rata dan terlihat menyatu dengan kulit.',
      ),
      ArticleSection(
        heading: 'Base Tipis',
        body:
            'Aplikasikan cushion atau BB cream dengan finish dewy menggunakan jari atau beauty blender. Jangan terlalu tebal — biarkan tekstur kulit terlihat.',
      ),
      ArticleSection(
        heading: 'Sentuhan Warna',
        body:
            'Gradient lip dengan tint merah muda di bagian tengah bibir, blush peach di pipi, dan sentuhan highlighter di hidung serta cupid bow.',
      ),
    ],
  ),
  Article(
    id: 'a4',
    title: 'Workout Pemula: 20 Menit di Rumah Tanpa Alat',
    category: 'Tubuh',
    excerpt:
        'Rangkaian gerakan sederhana untuk membakar kalori dan menjaga postur tubuh tetap sehat.',
    imageUrl:
        'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=900&q=80',
    author: 'Coach Reza',
    readMinutes: '7 min',
    publishedAt: '3 hari lalu',
    tags: ['workout', 'rumah', 'pemula'],
    sections: [
      ArticleSection(
        heading: 'Pemanasan 3 Menit',
        body:
            'Jumping jack 60 detik, arm circle 30 detik tiap arah, high knees 60 detik. Tujuannya menaikkan denyut jantung secara bertahap.',
      ),
      ArticleSection(
        heading: 'Sirkuit Utama (3 Putaran)',
        body:
            'Squat 15x, push up modifikasi 10x, lunges 10x tiap kaki, plank 30 detik, glute bridge 15x. Istirahat 45 detik antar putaran.',
      ),
      ArticleSection(
        heading: 'Pendinginan',
        body:
            'Lakukan stretching seluruh tubuh selama 3–5 menit. Fokus pada paha belakang, betis, dan punggung bawah agar tidak pegal esok hari.',
      ),
    ],
  ),
  Article(
    id: 'a5',
    title: 'Atasi Rambut Rontok dengan Bahan Alami di Dapur',
    category: 'Rambut',
    excerpt:
        'Masker rambut DIY dari bahan dapur yang efektif mengurangi kerontokan dan menebalkan helai rambut.',
    imageUrl:
        'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=900&q=80',
    author: 'dr. Linda Hartanto',
    readMinutes: '6 min',
    publishedAt: '4 hari lalu',
    tags: ['rambut', 'rontok', 'natural'],
    sections: [
      ArticleSection(
        heading: 'Penyebab Rambut Rontok',
        body:
            'Stres, kurang protein, perawatan kimia berlebihan, dan kekurangan vitamin (terutama biotin, zinc, dan zat besi) adalah pemicu utama.',
      ),
      ArticleSection(
        heading: 'Masker Pisang & Madu',
        body:
            'Haluskan 1 pisang, campur 1 sdm madu dan 1 sdm minyak zaitun. Oleskan ke rambut & kulit kepala, diamkan 30 menit, lalu bilas dengan shampoo lembut.',
      ),
      ArticleSection(
        heading: 'Pijat Kulit Kepala',
        body:
            'Pijat 5 menit setiap malam dengan minyak kemiri atau kelapa untuk melancarkan sirkulasi dan menguatkan folikel rambut.',
      ),
    ],
  ),
  Article(
    id: 'a6',
    title: 'Self Care Sunday: 7 Ritual untuk Reset Pikiran',
    category: 'Mental',
    excerpt:
        'Cara sederhana menjadwalkan waktu untuk diri sendiri agar minggu berikutnya terasa lebih ringan.',
    imageUrl:
        'https://images.unsplash.com/photo-1545205597-3d9d02c29597?w=900&q=80',
    author: 'Psikolog Nadia',
    readMinutes: '5 min',
    publishedAt: '6 hari lalu',
    tags: ['mental', 'self care', 'lifestyle'],
    sections: [
      ArticleSection(
        heading: 'Kenapa Self Care Penting?',
        body:
            'Bukan kemewahan — self care adalah investasi kesehatan mental. Otak butuh jeda untuk memproses emosi dan kembali fokus.',
      ),
      ArticleSection(
        heading: 'Ritual Sederhana',
        body:
            'Mandi air hangat panjang, journaling 10 menit, masker wajah, jalan kaki tanpa HP, baca novel ringan, masak makanan favorit, dan tidur lebih awal.',
      ),
    ],
  ),
  Article(
    id: 'a7',
    title: 'Hydration 101: Berapa Banyak Air yang Sebenarnya Kamu Butuhkan?',
    category: 'Lifestyle',
    excerpt:
        'Mitos & fakta soal minum 8 gelas sehari, plus tanda dehidrasi yang sering tidak disadari.',
    imageUrl:
        'https://images.unsplash.com/photo-1502740479091-635887520276?w=900&q=80',
    author: 'Nutritionist Anya',
    readMinutes: '4 min',
    publishedAt: '1 hari lalu',
    tags: ['hidrasi', 'air', 'kesehatan'],
    sections: [
      ArticleSection(
        heading: 'Rumus Praktis',
        body:
            'Kebutuhan ideal: 30–35 ml per kg berat badan. Untuk wanita 55 kg, sekitar 1,7–1,9 liter sehari, ditambah jika berolahraga atau cuaca panas.',
      ),
      ArticleSection(
        heading: 'Tanda Dehidrasi',
        body:
            'Sering pusing, urin gelap, bibir pecah, kulit kering & kusam, sulit konsentrasi. Bawa botol air dan minum bertahap setiap 30 menit.',
      ),
    ],
  ),
  Article(
    id: 'a8',
    title: 'Mengenal Skin Barrier dan Cara Memperbaikinya',
    category: 'Skincare',
    excerpt:
        'Skin barrier rusak bikin kulit gampang merah, perih, dan breakout. Ini cara memperbaikinya.',
    imageUrl:
        'https://images.unsplash.com/photo-1612817288484-6f916006741a?w=900&q=80',
    author: 'dr. Kirana Putri',
    readMinutes: '6 min',
    publishedAt: '8 hari lalu',
    tags: ['skin barrier', 'skincare', 'sensitif'],
    sections: [
      ArticleSection(
        heading: 'Apa Itu Skin Barrier?',
        body:
            'Lapisan terluar kulit yang melindungi dari iritan dan menjaga kelembapan. Kalau rusak, semua produk yang kamu pakai bisa terasa perih.',
      ),
      ArticleSection(
        heading: 'Penyebab Kerusakan',
        body:
            'Over-exfoliating, pakai retinol terlalu sering, sabun kasar, cuaca ekstrem, dan stres berlebihan.',
      ),
      ArticleSection(
        heading: 'Cara Memperbaiki',
        body:
            'Stop dulu semua active ingredient. Pakai cleanser lembut, moisturizer dengan ceramide & niacinamide, dan sunscreen setiap hari. Beri waktu 2–4 minggu.',
      ),
    ],
  ),
  Article(
    id: 'a9',
    title: 'Tips Diet Sehat Tanpa Tersiksa: Kalori Defisit yang Realistis',
    category: 'Diet',
    excerpt:
        'Cara turun berat badan secara berkelanjutan tanpa harus kelaparan atau menyiksa diri.',
    imageUrl:
        'https://images.unsplash.com/photo-1466637574441-749b8f19452f?w=900&q=80',
    author: 'Coach Reza',
    readMinutes: '7 min',
    publishedAt: '10 hari lalu',
    tags: ['diet', 'kalori', 'turun berat badan'],
    sections: [
      ArticleSection(
        heading: 'Hitung TDEE Dulu',
        body:
            'TDEE = total kalori yang kamu bakar dalam sehari. Defisit sehat: kurangi 300–500 kalori dari TDEE. Lebih dari itu, metabolisme bisa melambat.',
      ),
      ArticleSection(
        heading: 'Prioritaskan Protein',
        body:
            'Target 1,6–2 gram protein per kg berat badan. Protein bikin kenyang lebih lama dan mempertahankan massa otot saat defisit.',
      ),
      ArticleSection(
        heading: 'Cheat Meal Boleh!',
        body:
            'Sekali seminggu nikmati makanan favorit tanpa merasa bersalah. Diet yang terlalu kaku justru sering gagal di tengah jalan.',
      ),
    ],
  ),
  Article(
    id: 'a10',
    title: 'Mengatasi Mata Panda dengan Eye Cream & Lifestyle',
    category: 'Wajah',
    excerpt:
        'Lingkaran hitam di bawah mata? Ini kombinasi treatment dan kebiasaan yang efektif.',
    imageUrl:
        'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=900&q=80',
    author: 'Beauty Editor Mira',
    readMinutes: '5 min',
    publishedAt: '12 hari lalu',
    tags: ['mata panda', 'eye cream', 'wajah'],
    sections: [
      ArticleSection(
        heading: 'Penyebab Utama',
        body:
            'Kurang tidur, genetik, alergi, dan paparan layar berlebihan. Kulit di sekitar mata 5x lebih tipis sehingga pembuluh darah lebih terlihat.',
      ),
      ArticleSection(
        heading: 'Bahan Aktif yang Membantu',
        body:
            'Caffeine (mengurangi bengkak), vitamin K (memudarkan warna gelap), peptide (menguatkan kulit), dan retinol dosis rendah untuk jangka panjang.',
      ),
      ArticleSection(
        heading: 'Kebiasaan Pendukung',
        body:
            'Tidur 7–8 jam, kompres dingin pagi hari, kurangi garam, dan jangan menggosok mata. Pakai sunscreen di area mata juga!',
      ),
    ],
  ),
  Article(
    id: 'a11',
    title: 'Daily Habits untuk Mood Booster: Kecil tapi Berdampak Besar',
    category: 'Lifestyle',
    excerpt:
        'Kebiasaan harian sederhana yang bisa meningkatkan mood dan produktivitas tanpa effort besar.',
    imageUrl:
        'https://images.unsplash.com/photo-1499728603263-13726abce5fd?w=900&q=80',
    author: 'Psikolog Nadia',
    readMinutes: '4 min',
    publishedAt: '14 hari lalu',
    tags: ['lifestyle', 'habit', 'mood'],
    sections: [
      ArticleSection(
        heading: 'Mulai Pagi dengan Sinar Matahari',
        body:
            'Paparan cahaya alami 10 menit setelah bangun membantu mengatur ritme sirkadian dan meningkatkan produksi serotonin.',
      ),
      ArticleSection(
        heading: 'Gerakan Kecil Sepanjang Hari',
        body:
            'Setiap 1 jam, berdiri & stretching 2 menit. Aktivitas ringan mencegah kelelahan mental dan menjaga sirkulasi darah.',
      ),
      ArticleSection(
        heading: 'Gratitude Sebelum Tidur',
        body:
            'Tulis 3 hal yang kamu syukuri hari ini. Riset menunjukkan kebiasaan ini menurunkan kecemasan dan memperbaiki kualitas tidur.',
      ),
    ],
  ),
  Article(
    id: 'a12',
    title: 'Body Care Routine: Kulit Tubuh Selembut Wajah',
    category: 'Tubuh',
    excerpt:
        'Sering fokus ke wajah dan lupa tubuh? Ini rutinitas body care yang bikin kulit halus merata.',
    imageUrl:
        'https://images.unsplash.com/photo-1570194065650-d99fb4bedf0a?w=900&q=80',
    author: 'dr. Linda Hartanto',
    readMinutes: '5 min',
    publishedAt: '9 hari lalu',
    tags: ['body care', 'tubuh', 'kulit halus'],
    sections: [
      ArticleSection(
        heading: 'Exfoliating 2x Seminggu',
        body:
            'Gunakan body scrub dengan butiran halus atau chemical exfoliant (AHA/BHA) untuk mengangkat sel kulit mati. Fokus di siku, lutut, dan tumit.',
      ),
      ArticleSection(
        heading: 'Lock In Moisture',
        body:
            'Setelah mandi, kulit masih lembap — segera aplikasikan body lotion atau body butter. Lebih efektif dibanding setelah kulit kering.',
      ),
      ArticleSection(
        heading: 'Sunscreen untuk Tubuh',
        body:
            'Area yang sering terpapar (tangan, leher, dada) butuh perlindungan SPF juga. Cegah belang dan tanda penuaan dini.',
      ),
    ],
  ),
];
