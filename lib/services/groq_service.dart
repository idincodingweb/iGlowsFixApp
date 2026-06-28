import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/chat_message.dart';
import '../models/skin_profile.dart';

class GroqException implements Exception {
  final String message;
  final int? code;
  GroqException(this.message, {this.code});
  @override
  String toString() => 'GroqException($code): $message';
}

/// Proxy URL Google Apps Script (web app /exec).
/// Default sudah di-hardcode. Bisa di-override saat build:
/// flutter build apk --dart-define=GLOWY_PROXY_URL=https://script.google.com/macros/s/XXX/exec
const String _kProxyUrl = String.fromEnvironment(
  'GLOWY_PROXY_URL',
  defaultValue:
      'https://script.google.com/macros/s/AKfycbwOxlG2c0FaZvS9L40pIiprge50r46KwKj49nuDud5wCuiFil1sVkDDWbIL2VB02YO3/exec',
);

class GroqService {
  final http.Client _client;
  GroqService({http.Client? client}) : _client = client ?? http.Client();

  void dispose() => _client.close();

  /// Sapaan awal Glowy yang ditampilkan saat layar konsultasi pertama dibuka.
  String greeting() {
    return 'Hai bestie! ✨ Aku Glowy, AI Beauty Assistant kamu. '
        'Cerita dong soal kulit kamu — mau bahas jerawat, kulit kering, '
        'kusam, atau racikan routine yang pas? Aku bantu pelan-pelan ya 💖';
  }

  /// Apps Script /exec membalas 302 redirect ke script.googleusercontent.com.
  /// http.post default follow redirect TAPI body POST hilang → harus manual.
  Future<http.Response> _postFollow(Uri uri, String body) async {
    var current = uri;
    String method = 'POST';
    String? sendBody = body;

    for (int i = 0; i < 5; i++) {
      final req = http.Request(method, current)
        ..followRedirects = false
        ..headers['Content-Type'] = 'application/json';
      if (sendBody != null) req.body = sendBody;

      final streamed = await _client.send(req);
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode == 301 ||
          resp.statusCode == 302 ||
          resp.statusCode == 303 ||
          resp.statusCode == 307 ||
          resp.statusCode == 308) {
        final loc = resp.headers['location'];
        if (loc == null) return resp;
        current = Uri.parse(loc);
        if (resp.statusCode == 302 || resp.statusCode == 303) {
          method = 'GET';
          sendBody = null;
        }
        continue;
      }
      return resp;
    }
    throw GroqException('Terlalu banyak redirect', code: 310);
  }

  /// High-level chat: terima riwayat ChatMessage + profil kulit, susun
  /// system prompt persona Glowy + konteks profil, lalu kirim ke proxy.
  Future<String> chat({
    required List<ChatMessage> history,
    SkinProfile? profile,
  }) async {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _buildSystemPrompt(profile)},
      for (final m in history)
        {
          'role': m.fromUser ? 'user' : 'assistant',
          'content': m.text,
        },
    ];
    return _sendMessages(messages);
  }

  String _buildSystemPrompt(SkinProfile? p) {
    final sb = StringBuffer()
      ..writeln(
          'Kamu adalah "Glowy", AI Beauty Assistant berbahasa Indonesia yang ramah, '
          'hangat, dan suportif seperti sahabat. Gunakan sapaan "bestie", emoji '
          'secukupnya (✨💖🌸), dan jawaban ringkas (maks 5-7 kalimat). '
          'Fokus: skincare, routine, bahan aktif, dan rekomendasi praktis. '
          'Jika menyangkut kondisi medis serius, sarankan konsultasi ke dokter kulit.');
    if (p != null) {
      sb
        ..writeln('\nKonteks pengguna:')
        ..writeln('- Nama: ${p.name ?? "-"}')
        ..writeln('- Umur: ${p.age}')
        ..writeln('- Jenis kulit: ${p.skinType}')
        ..writeln('- Concerns: ${p.concerns.isEmpty ? "-" : p.concerns.join(", ")}')
        ..writeln('- Goal: ${p.goal}');
    }
    return sb.toString();
  }

  Future<String> _sendMessages(List<Map<String, String>> messages) async {
    if (_kProxyUrl.isEmpty) {
      throw GroqException(
        'GLOWY_PROXY_URL belum di-set. Build pakai --dart-define=GLOWY_PROXY_URL=...',
        code: 0,
      );
    }

    final uri = Uri.parse(_kProxyUrl);
    final payload = jsonEncode({'messages': messages});

    http.Response resp;
    try {
      resp = await _postFollow(uri, payload);
    } catch (e) {
      throw GroqException('Gagal terhubung ke server: $e', code: -1);
    }

    if (resp.statusCode != 200) {
      throw GroqException('HTTP ${resp.statusCode}', code: resp.statusCode);
    }

    Map<String, dynamic> data;
    try {
      data = jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (_) {
      throw GroqException('Respon bukan JSON valid', code: 422);
    }

    if (data['ok'] == true && data['content'] is String) {
      return data['content'] as String;
    }
    final err = data['error']?.toString() ?? 'Unknown error';
    final code = data['code'] is int ? data['code'] as int : 500;
    throw GroqException(err, code: code);
  }
}
