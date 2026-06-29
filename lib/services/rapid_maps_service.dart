import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service singleton untuk integrasi RapidAPI Google Map Places (Street View).
///
/// Endpoint: `https://google-map-places.p.rapidapi.com/maps/api/streetview`
/// Mengembalikan image (PNG/JPEG) berdasarkan `location` (bisa "lat,lng"
/// atau query teks alamat / nama tempat).
///
/// API key DIINJECT saat build via `--dart-define=RAPIDAPI_KEY=...`
/// (sumbernya GitHub Secret di workflow), sama pola seperti `GROQ_API_KEY_*`.
/// Tidak boleh di-hardcode di source.
class RapidMapsService {
  RapidMapsService._();
  static final RapidMapsService instance = RapidMapsService._();

  static const String _host = 'google-map-places.p.rapidapi.com';
  static const String _baseUrl =
      'https://google-map-places.p.rapidapi.com/maps/api/streetview';

  /// Dibaca dari `--dart-define=RAPIDAPI_KEY=...`. Default kosong supaya
  /// build tetep jalan; UI bakal fallback aman saat key belum di-set.
  static const String _apiKey =
      String.fromEnvironment('RAPIDAPI_KEY', defaultValue: '');

  bool get hasKey => _apiKey.isNotEmpty;

  /// Cache in-memory biar gak hit API berulang utk lokasi yg sama.
  final Map<String, Uint8List> _cache = <String, Uint8List>{};

  /// Ambil street view berdasar koordinat.
  Future<Uint8List?> fetchStreetViewByCoords({
    required double lat,
    required double lng,
    int width = 600,
    int height = 400,
  }) {
    return _fetch(location: '$lat,$lng', width: width, height: height);
  }

  /// Ambil street view berdasar query teks (nama tempat / alamat).
  Future<Uint8List?> fetchStreetViewByQuery({
    required String query,
    int width = 600,
    int height = 400,
  }) {
    final q = query.trim().isEmpty ? 'salon' : query.trim();
    return _fetch(location: q, width: width, height: height);
  }

  Future<Uint8List?> _fetch({
    required String location,
    required int width,
    required int height,
  }) async {
    if (!hasKey) {
      // Key belum di-inject saat build — biarin UI pakai fallback.
      return null;
    }

    final size = '${width}x$height';
    final cacheKey = '$size|$location';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'size': size,
      'source': 'default',
      'return_error_code': 'true',
      'location': location,
    });

    try {
      final res = await http.get(uri, headers: {
        'x-rapidapi-key': _apiKey,
        'x-rapidapi-host': _host,
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
        final bytes = res.bodyBytes;
        _cache[cacheKey] = bytes;
        return bytes;
      }
      debugPrint('RapidMaps non-200: ${res.statusCode}');
      return null;
    } catch (e) {
      debugPrint('RapidMaps fetch error: $e');
      return null;
    }
  }
}
