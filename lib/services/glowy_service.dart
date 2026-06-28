import 'dart:math';

/// AI beauty advisor offline (canned response). Bisa diganti backend nanti
/// tanpa ubah UI.
class GlowyService {
  static const _greeting = [
    'Hai cantik! Aku Glowy, asisten skincare kamu ✨ Cerita masalah kulit kamu yuk!',
    'Halo! Lagi pengen konsultasi soal skincare apa hari ini? 💕',
  ];

  String reply(String userMsg) {
    final m = userMsg.toLowerCase();

    if (m.contains('jerawat') || m.contains('acne') || m.contains('breakout')) {
      return 'Aduh, jerawat memang bikin nggak pede 🥺 Coba rutinitas ini:\n\n'
          '• Cleanse: pakai cleanser dengan salicylic acid 2x sehari\n'
          '• Treat: serum niacinamide untuk redain inflamasi & kontrol minyak\n'
          '• Moisturize: pelembap ringan non-comedogenic\n'
          '• Protect: selalu SPF 30+ di pagi hari\n\n'
          'Konsistensi kunci utama ya 💕';
    }
    if (m.contains('kering') || m.contains('dry') || m.contains('hidrasi') || m.contains('hydra')) {
      return 'Untuk kulit kering, fokus ke hidrasi 💧\n\n'
          '• Hindari cleanser foaming yg keras\n'
          '• Layering: hydrating toner → serum hyaluronic acid → moisturizer rich\n'
          '• Tambahkan facial oil di malam hari\n'
          '• Minum air min. 2 liter/hari ya!';
    }
    if (m.contains('berminyak') || m.contains('oily') || m.contains('pori') || m.contains('pore')) {
      return 'Kulit berminyak butuh keseimbangan, bukan dikeringkan total ✨\n\n'
          '• Gentle cleanser pagi & malam\n'
          '• Toner BHA 1-2x/minggu\n'
          '• Serum niacinamide untuk minimize pores\n'
          '• Gel moisturizer + SPF non-comedogenic';
    }
    if (m.contains('sensitif') || m.contains('sensitive') || m.contains('merah')) {
      return 'Kulit sensitif perlu produk minimalis & soothing 🌸\n\n'
          '• Hindari fragrance & essential oil\n'
          '• Cari kandungan: centella, panthenol, ceramide\n'
          '• Patch test selalu sebelum coba produk baru';
    }
    if (m.contains('aging') || m.contains('kerut') || m.contains('wrinkle') || m.contains('anti-aging') || m.contains('anti aging')) {
      return 'Untuk anti-aging, mulai pelan-pelan 💖\n\n'
          '• Pagi: Vitamin C + SPF 50\n'
          '• Malam: Retinol low-dose 2-3x/minggu\n'
          '• Peptide & ceramide cream untuk barrier\n'
          '• Cukup tidur & jangan lupa sunscreen!';
    }
    if (m.contains('kusam') || m.contains('dull') || m.contains('cerah') || m.contains('glow')) {
      return 'Glow alami datang dari hidrasi + exfoliate seimbang ✨\n\n'
          '• Exfoliate kimia (AHA) 1-2x/minggu\n'
          '• Serum Vitamin C tiap pagi\n'
          '• Hydrating mask 2x/minggu\n'
          '• SPF wajib biar nggak sia-sia!';
    }
    if (m.contains('halo') || m.contains('hai') || m.contains('hi') || m.contains('hello')) {
      return _greeting[Random().nextInt(_greeting.length)];
    }

    return 'Catatan kamu udah aku dengarkan 💕 Coba ceritakan lebih detail: '
        'jenis kulit kamu apa, dan keluhan utamanya (jerawat, kering, kusam, sensitif, atau aging)? '
        'Nanti aku kasih rekomendasi rutinitas yang pas.';
  }

  String greeting() => _greeting[Random().nextInt(_greeting.length)];
}
