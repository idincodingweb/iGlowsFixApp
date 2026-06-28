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

/// API key Groq di-inject saat build:
/// flutter build apk --dart-define=GROQ_API_KEY_1=xxx --dart-define=GROQ_API_KEY_2=yyy
/// Key kedua dipakai sebagai fallback rotasi kalau key pertama kena rate limit / invalid.
const String _kGroqApiKey1 = String.fromEnvironment('GROQ_API_KEY_1');
const String _kGroqApiKey2 = String.fromEnvironment('GROQ_API_KEY_2');

/// Model default Groq. Bisa di-override via --dart-define=GROQ_MODEL=...
const String _kGroqModel = String.fromEnvironment(
  'GROQ_MODEL',
  defaultValue: 'llama-3.3-70b-versatile',
);

const String _kGroqEndpoint = 'https://api.groq.com/openai/v1/chat/completions';

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

  /// High-level chat: terima riwayat ChatMessage + profil kulit, susun
  /// system prompt persona Glowy + konteks profil, lalu kirim ke Groq.
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
    final keys = <String>[
      if (_kGroqApiKey1.isNotEmpty) _kGroqApiKey1,
      if (_kGroqApiKey2.isNotEmpty) _kGroqApiKey2,
    ];

    if (keys.isEmpty) {
      throw GroqException(
        'GROQ_API_KEY belum di-set. Build pakai '
        '--dart-define=GROQ_API_KEY_1=... (dan optional GROQ_API_KEY_2=...)',
        code: 0,
      );
    }

    final uri = Uri.parse(_kGroqEndpoint);
    final payload = jsonEncode({
      'model': _kGroqModel,
      'messages': messages,
      'temperature': 0.7,
      'max_tokens': 800,
    });

    GroqException? lastError;
    for (var i = 0; i < keys.length; i++) {
      final key = keys[i];
      http.Response resp;
      try {
        resp = await _client.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $key',
          },
          body: payload,
        );
      } catch (e) {
        lastError = GroqException('Gagal terhubung ke Groq: $e', code: -1);
        continue;
      }

      // Rotasi ke key berikut kalau auth / rate-limit
      if (resp.statusCode == 401 ||
          resp.statusCode == 403 ||
          resp.statusCode == 429) {
        lastError = GroqException(
          'Key #${i + 1} ditolak (HTTP ${resp.statusCode})',
          code: resp.statusCode,
        );
        continue;
      }

      if (resp.statusCode != 200) {
        throw GroqException(
          'Groq error HTTP ${resp.statusCode}: ${resp.body}',
          code: resp.statusCode,
        );
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(resp.body) as Map<String, dynamic>;
      } catch (_) {
        throw GroqException('Respon Groq bukan JSON valid', code: 422);
      }

      final choices = data['choices'];
      if (choices is List && choices.isNotEmpty) {
        final msg = choices.first['message'];
        if (msg is Map && msg['content'] is String) {
          return (msg['content'] as String).trim();
        }
      }
      throw GroqException('Format respon Groq tidak dikenali', code: 422);
    }

    throw lastError ??
        GroqException('Semua API key gagal dipakai', code: 500);
  }
}
