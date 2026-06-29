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
const String _kGroqApiKey1 = String.fromEnvironment('GROQ_API_KEY_1');
const String _kGroqApiKey2 = String.fromEnvironment('GROQ_API_KEY_2');

/// Model teks default. Override via --dart-define=GROQ_MODEL=...
const String _kGroqModel = String.fromEnvironment(
  'GROQ_MODEL',
  defaultValue: 'llama-3.3-70b-versatile',
);

/// Model VISION default (multimodal). Override via --dart-define=GROQ_VISION_MODEL=...
/// Groq saat ini support `meta-llama/llama-4-scout-17b-16e-instruct`
/// dan `meta-llama/llama-4-maverick-17b-128e-instruct` untuk vision.
const String _kGroqVisionModel = String.fromEnvironment(
  'GROQ_VISION_MODEL',
  defaultValue: 'meta-llama/llama-4-scout-17b-16e-instruct',
);

const String _kGroqEndpoint = 'https://api.groq.com/openai/v1/chat/completions';

class GroqService {
  final http.Client _client;
  GroqService({http.Client? client}) : _client = client ?? http.Client();

  void dispose() => _client.close();

  String greeting() {
    return 'Hai bestie! ✨ Aku Glowy, AI Beauty Assistant kamu. '
        'Cerita dong soal kulit kamu — mau bahas jerawat, kulit kering, '
        'kusam, atau racikan routine yang pas? Kamu juga bisa kirim foto '
        'wajah biar aku cek visualnya 📸💖';
  }

  /// Chat teks (atau multimodal kalau ada [ChatMessage.imageBase64]).
  /// Otomatis pakai model vision saat ada gambar di salah satu pesan user.
  Future<String> chat({
    required List<ChatMessage> history,
    SkinProfile? profile,
  }) async {
    final hasImage = history.any((m) => m.fromUser && m.hasImage);

    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': _buildSystemPrompt(profile)},
    ];

    for (final m in history) {
      if (m.fromUser && m.hasImage) {
        messages.add({
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': m.text.isEmpty
                  ? 'Tolong analisa foto wajahku ya bestie.'
                  : m.text,
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:${m.imageMime ?? 'image/jpeg'};base64,${m.imageBase64}',
              },
            },
          ],
        });
      } else {
        messages.add({
          'role': m.fromUser ? 'user' : 'assistant',
          'content': m.text,
        });
      }
    }

    return _send(messages,
        model: hasImage ? _kGroqVisionModel : _kGroqModel);
  }

  /// Analisa skin via Groq Vision. Balikin Map JSON terstruktur:
  /// { skinType, hydration, oiliness, acne, darkSpots, wrinkles,
  ///   overallScore, recommendations: [..] }
  Future<Map<String, dynamic>> analyzeSkin({
    required String imageBase64,
    String mime = 'image/jpeg',
    SkinProfile? profile,
  }) async {
    final ctx = profile == null
        ? ''
        : 'Konteks user: skinType=${profile.skinType}, age=${profile.age}, '
            'concerns=${profile.concerns.join(",")}, goal=${profile.goal}. ';

    final sys =
        'Kamu adalah AI Skin Analyzer profesional. Analisa foto wajah dan '
        'balas HANYA JSON valid (tanpa markdown, tanpa code fence) dengan '
        'schema: {"skinType": "Normal|Kering|Berminyak|Kombinasi|Sensitif", '
        '"hydration": 0-100, "oiliness": 0-100, "acne": 0-100, '
        '"darkSpots": 0-100, "wrinkles": 0-100, "overallScore": 0-100, '
        '"recommendations": ["..3-6 saran singkat berbahasa Indonesia.."]}. '
        'hydration tinggi = bagus. oiliness/acne/darkSpots/wrinkles tinggi = '
        'masalah lebih besar. overallScore dihitung holistik. '
        'Jika foto bukan wajah, balikin overallScore=0 dan '
        'recommendations=["Foto tidak terdeteksi sebagai wajah, coba ulang."].';

    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': sys},
      {
        'role': 'user',
        'content': [
          {
            'type': 'text',
            'text': '${ctx}Analisa kulit wajah pada foto ini. Balas JSON saja.',
          },
          {
            'type': 'image_url',
            'image_url': {'url': 'data:$mime;base64,$imageBase64'},
          },
        ],
      },
    ];

    final raw = await _send(messages,
        model: _kGroqVisionModel,
        temperature: 0.2,
        maxTokens: 700,
        jsonMode: true);

    return _parseJson(raw);
  }

  Map<String, dynamic> _parseJson(String raw) {
    var s = raw.trim();
    // Buang code fence kalau model nakal nempelin ```json
    if (s.startsWith('```')) {
      final end = s.lastIndexOf('```');
      final firstNl = s.indexOf('\n');
      if (firstNl > 0 && end > firstNl) {
        s = s.substring(firstNl + 1, end).trim();
      }
    }
    // Ambil substring antara { pertama dan } terakhir
    final lb = s.indexOf('{');
    final rb = s.lastIndexOf('}');
    if (lb >= 0 && rb > lb) s = s.substring(lb, rb + 1);
    try {
      final d = jsonDecode(s);
      if (d is Map<String, dynamic>) return d;
    } catch (_) {}
    throw GroqException('Respon AI tidak terbaca sebagai JSON', code: 422);
  }

  String _buildSystemPrompt(SkinProfile? p) {
    final sb = StringBuffer()
      ..writeln(
          'Kamu adalah "Glowy", AI Beauty Assistant berbahasa Indonesia yang ramah, '
          'hangat, dan suportif seperti sahabat. Gunakan sapaan "bestie", emoji '
          'secukupnya (✨💖🌸), dan jawaban ringkas (maks 5-7 kalimat). '
          'Fokus: skincare, routine, bahan aktif, dan rekomendasi praktis. '
          'Jika user kirim foto wajah, beri observasi visual (kondisi kulit, '
          'tanda jerawat/kusam/dehidrasi) lalu saran konkret. '
          'Untuk kondisi medis serius, sarankan konsultasi dokter kulit.');
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

  Future<String> _send(
    List<Map<String, dynamic>> messages, {
    required String model,
    double temperature = 0.7,
    int maxTokens = 800,
    bool jsonMode = false,
  }) async {
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
      'model': model,
      'messages': messages,
      'temperature': temperature,
      'max_tokens': maxTokens,
      if (jsonMode) 'response_format': {'type': 'json_object'},
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
