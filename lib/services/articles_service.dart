import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/article.dart';

/// Fetcher artikel dari Admin Dashboard iGlows (deploy di Vercel).
///
/// Endpoint publik (no auth): `https://iglowsadmin.vercel.app/api/public/articles`
/// Response yang diharapkan: array JSON objek artikel — atau objek dengan
/// field `articles`/`data`/`items` yang berisi array.
///
/// Service ini fail-safe: kalau request gagal / parsing error / koneksi
/// putus, return `[]` (UI menampilkan empty state, tidak crash). Sesuai
/// SOP pengembangan.md (try/catch + fallback aman, no dummy data).
class ArticlesService {
  ArticlesService._();
  static final ArticlesService instance = ArticlesService._();

  static const String _endpoint =
      'https://iglowsadmin.vercel.app/api/public/articles';
  static const Duration _timeout = Duration(seconds: 15);

  /// Ambil daftar artikel dari admin dashboard.
  /// Selalu return list (kosong kalau gagal) — caller tidak perlu try/catch.
  Future<List<Article>> fetchArticles() async {
    try {
      final res = await http
          .get(Uri.parse(_endpoint), headers: const {
            'Accept': 'application/json',
          })
          .timeout(_timeout);

      if (res.statusCode < 200 || res.statusCode >= 300) {
        return const <Article>[];
      }

      final decoded = jsonDecode(res.body);
      final List<dynamic> raw = _extractList(decoded);

      final articles = <Article>[];
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          try {
            articles.add(Article.fromJson(item));
          } catch (_) {
            // skip item rusak, jangan ganggu yang lain
          }
        } else if (item is Map) {
          try {
            articles.add(Article.fromJson(Map<String, dynamic>.from(item)));
          } catch (_) {}
        }
      }
      return articles;
    } catch (_) {
      return const <Article>[];
    }
  }

  /// Admin dashboard boleh return array langsung atau dibungkus objek.
  /// Toleransi 3 bentuk umum: `[...]`, `{"articles":[...]}`, `{"data":[...]}`,
  /// `{"items":[...]}`.
  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map) {
      for (final key in const ['articles', 'data', 'items', 'result']) {
        final v = decoded[key];
        if (v is List) return v;
      }
    }
    return const <dynamic>[];
  }
}
