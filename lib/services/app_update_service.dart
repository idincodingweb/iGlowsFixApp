import 'dart:convert';

import 'package:http/http.dart' as http;

/// Versi aplikasi saat ini. Update manual setiap release supaya dialog update
/// muncul saat admin dashboard broadcast versi yang lebih baru.
/// Sinkron dengan `version:` di pubspec.yaml (tanpa build number).
const String kAppVersion = '0.1.0';

/// Payload broadcast update dari admin dashboard.
class AppUpdateInfo {
  final String latestVersion;
  final String downloadUrl;
  final String message;
  final bool forceUpdate;

  const AppUpdateInfo({
    required this.latestVersion,
    required this.downloadUrl,
    required this.message,
    required this.forceUpdate,
  });

  /// True kalau `latestVersion` > versi aplikasi saat ini.
  bool get isNewer => _isNewerThan(latestVersion, kAppVersion);
}

bool _isNewerThan(String remote, String local) {
  final r = _parse(remote);
  final l = _parse(local);
  final len = r.length > l.length ? r.length : l.length;
  for (var i = 0; i < len; i++) {
    final a = i < r.length ? r[i] : 0;
    final b = i < l.length ? l[i] : 0;
    if (a > b) return true;
    if (a < b) return false;
  }
  return false;
}

List<int> _parse(String v) {
  final clean = v.split('+').first.split('-').first;
  return clean
      .split('.')
      .map((s) => int.tryParse(s.trim()) ?? 0)
      .toList(growable: false);
}

/// Service ambil broadcast update terbaru dari admin dashboard (Vercel).
class AppUpdateService {
  AppUpdateService._();
  static final AppUpdateService instance = AppUpdateService._();

  static const String _endpoint =
      'https://iglowsadmin.vercel.app/api/public/app-update';
  static const Duration _timeout = Duration(seconds: 10);

  /// Return `null` kalau tidak ada broadcast / error / koneksi gagal.
  Future<AppUpdateInfo?> fetchLatest() async {
    try {
      final res = await http
          .get(Uri.parse(_endpoint),
              headers: const {'Accept': 'application/json'})
          .timeout(_timeout);
      if (res.statusCode < 200 || res.statusCode >= 300) return null;
      final decoded = jsonDecode(res.body);
      if (decoded is! Map) return null;
      if (decoded['available'] == false) return null;
      final v = (decoded['latest_version'] ?? '').toString().trim();
      final url = (decoded['download_url'] ?? '').toString().trim();
      if (v.isEmpty || url.isEmpty) return null;
      return AppUpdateInfo(
        latestVersion: v,
        downloadUrl: url,
        message: (decoded['message'] ?? '').toString(),
        forceUpdate: decoded['force_update'] == true,
      );
    } catch (_) {
      return null;
    }
  }
}
