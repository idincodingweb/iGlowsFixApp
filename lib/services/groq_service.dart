import 'dart:convert';
import 'package:http/http.dart' as http;

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
        // 303 & 302 (umum di Apps Script) → ikuti pakai GET tanpa body
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

  Future<String> chat(List<Map<String, String>> messages) async {
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
