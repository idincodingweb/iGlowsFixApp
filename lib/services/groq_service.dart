import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';
import '../models/skin_profile.dart';

/// Klien Glowy AI yang berkomunikasi via proxy Google Apps Script.
///
/// Tidak ada API key disimpan di sisi aplikasi. Semua key Groq
/// disimpan di Script Properties pada Apps Script (server-side),
/// dan rotasi key dilakukan oleh server.
///
/// URL proxy diberikan saat build:
///   flutter build apk --dart-define=GLOWY_PROXY_URL=https://script.google.com/macros/s/XXX/exec
class GroqService {
  GroqService({
    String? proxyUrl,
    this.timeout = const Duration(seconds: 30),
    http.Client? client,
  })  : proxyUrl = proxyUrl ?? _envProxyUrl,
        _client = client ?? http.Client();

<<<<<<< HEAD
  static const String _envProxyUrl =
      String.fromEnvironment('GLOWY_PROXY_URL', defaultValue: '');
=======
<<<<<<< HEAD
  static const String _envProxyUrl = String.fromEnvironment(
    'GLOWY_PROXY_URL',
    defaultValue:
        'https://script.google.com/macros/s/AKfycbwOxlG2c0FaZvS9L40pIiprge50r46KwKj49nuDud5wCuiFil1sVkDDWbIL2VB02YO3/exec',
  );
=======
  static const String _envProxyUrl =
      String.fromEnvironment('GLOWY_PROXY_URL', defaultValue: '');
>>>>>>> 7f505d2 (memek memek memek)
>>>>>>> b3a4fe5 (hehehe)

  final String proxyUrl;
  final Duration timeout;
  final http.Client _client;

  static const String _systemPrompt =
      "Kamu adalah 'Glowy', sahabat virtual (virtual beauty bestie) dan ahli "
      "skincare di aplikasi iGlows. Tugasmu membantu pengguna perempuan "
      "merawat kulit mereka. Gunakan gaya bahasa Indonesia yang santai, ramah, "
      "dan penuh empati ala perempuan milenial/Gen Z (gunakan sapaan 'aku', "
      "'kamu', atau 'Bestie'). Berikan jawaban yang singkat, praktis, dan "
      "mudah dibaca di layar HP. Jangan terlalu kaku, dan selalu sisipkan "
      "beberapa emoji estetik (seperti ✨, 🧴, 💖, atau 🌸) agar percakapan "
      "terasa hangat.";

  String greeting() =>
      'Hai cantik! Aku Glowy, asisten skincare kamu ✨ Cerita masalah kulit kamu yuk!';

  Future<String> chat({
    required List<ChatMessage> history,
    SkinProfile? profile,
  }) async {
    if (proxyUrl.isEmpty) {
      return 'Glowy belum dikonfigurasi. Mohon set GLOWY_PROXY_URL saat build aplikasi ya, Bestie 💖';
    }

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _systemPrompt},
      if (profile != null)
        {'role': 'system', 'content': _profileContext(profile)},
      ...history.map((m) => {
            'role': m.fromUser ? 'user' : 'assistant',
            'content': m.text,
          }),
    ];

    try {
      final res = await _client
          .post(
            Uri.parse(proxyUrl),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'messages': messages}),
          )
          .timeout(timeout);

      if (res.statusCode != 200) {
        return 'Yahh, Glowy lagi ngambek nih (kode ${res.statusCode}). Coba lagi sebentar ya 🌸';
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['ok'] == true && data['content'] is String) {
        return (data['content'] as String).trim();
      }
      final err = data['error']?.toString() ?? 'unknown';
      return 'Glowy belum bisa jawab sekarang ($err). Coba lagi ya, Bestie 💖';
    } on TimeoutException {
      return 'Koneksi ke Glowy timeout. Coba cek internet kamu ya ✨';
    } catch (_) {
      return 'Ups, ada error di koneksi Glowy. Coba lagi sebentar ya 🌸';
    }
  }

  String _profileContext(SkinProfile p) {
    return 'Konteks pengguna — Tipe kulit: ${p.skinType}. '
        'Concern: ${p.concerns.join(", ")}. '
        'Goal: ${p.goal}. Usia: ${p.age}.';
  }
}
