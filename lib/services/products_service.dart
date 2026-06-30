import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

/// Fetcher produk dari Admin Dashboard iGlows (deploy di Vercel).
///
/// Endpoint publik: `https://iglowsadmin.vercel.app/api/public/products`
/// Fail-safe: kalau request gagal / koneksi putus, return `[]`.
/// Caller (ProductsScreen) menggabungkan hasil ini DI DEPAN `sampleProducts`
/// — dummy products tetap dipertahankan sementara untuk mempercantik UI.
class ProductsService {
  ProductsService._();
  static final ProductsService instance = ProductsService._();

  static const String _endpoint =
      'https://iglowsadmin.vercel.app/api/public/products';
  static const Duration _timeout = Duration(seconds: 15);

  Future<List<Product>> fetchProducts() async {
    try {
      final res = await http
          .get(Uri.parse(_endpoint),
              headers: const {'Accept': 'application/json'})
          .timeout(_timeout);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        return const <Product>[];
      }
      final decoded = jsonDecode(res.body);
      final List<dynamic> raw = _extractList(decoded);

      final out = <Product>[];
      for (final item in raw) {
        if (item is Map) {
          try {
            out.add(_fromJson(Map<String, dynamic>.from(item)));
          } catch (_) {/* skip rusak */}
        }
      }
      return out;
    } catch (_) {
      return const <Product>[];
    }
  }

  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map) {
      for (final k in const ['products', 'data', 'items', 'result']) {
        final v = decoded[k];
        if (v is List) return v;
      }
    }
    return const <dynamic>[];
  }

  Product _fromJson(Map<String, dynamic> j) {
    String s(dynamic v, [String fb = '']) => v == null ? fb : v.toString();
    double d(dynamic v, [double fb = 0]) {
      if (v == null) return fb;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? fb;
    }

    final goodForRaw = j['skin_types'] ?? j['goodFor'] ?? j['good_for'];
    final goodFor = <String>[];
    if (goodForRaw is List) {
      for (final t in goodForRaw) {
        final str = s(t);
        if (str.isNotEmpty) goodFor.add(str);
      }
    }
    final category = s(j['category'], 'Serum');
    return Product(
      id: s(j['id'], s(j['_id'])),
      name: s(j['name'], 'Produk Tanpa Nama'),
      brand: s(j['brand'], 'iGlows'),
      category: category,
      description: s(j['description'], s(j['desc'])),
      price: d(j['price']),
      rating: d(j['rating'], 4.5),
      goodFor: goodFor,
      emoji: _emojiFor(category),
      imageUrl: s(j['image_url'], s(j['imageUrl'])),
    );
  }

  String _emojiFor(String cat) {
    switch (cat.toLowerCase()) {
      case 'cleanser':
        return '🫧';
      case 'toner':
        return '🌹';
      case 'serum':
        return '✨';
      case 'moisturizer':
        return '💧';
      case 'sunscreen':
        return '☀️';
      case 'mask':
        return '🌙';
      case 'treatment':
        return '🧪';
      default:
        return '💖';
    }
  }
}
