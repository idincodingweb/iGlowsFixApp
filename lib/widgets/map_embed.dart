import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_theme.dart';

/// Widget peta yang nge-render preview map dari OpenStreetMap tiles langsung
/// (`https://tile.openstreetmap.org/{z}/{x}/{y}.png`) — gratis, publik, tanpa
/// API key. Tiap tile di-load via [Image.network] (cache otomatis), disusun
/// grid yang ditengahin ke koordinat target, plus pin merah di tengah.
///
/// Kalau semua tile gagal load (offline), widget jatuh ke fallback aman
/// dengan tombol "Buka di Google Maps".
///
/// API publik (`MapEmbed.coords` / `MapEmbed.query`) DIPERTAHANKAN sama
/// persis biar pemanggil gak perlu diubah.
class MapEmbed extends StatefulWidget {
  final double? lat;
  final double? lng;
  final String? query;
  final int zoom;
  final double height;
  final BorderRadius borderRadius;

  const MapEmbed._({
    this.lat,
    this.lng,
    this.query,
    required this.zoom,
    required this.height,
    required this.borderRadius,
  });

  factory MapEmbed.coords({
    Key? key,
    required double lat,
    required double lng,
    int zoom = 15,
    double height = 200,
    BorderRadius? borderRadius,
  }) {
    return MapEmbed._(
      lat: lat,
      lng: lng,
      zoom: zoom,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(20),
    );
  }

  factory MapEmbed.query({
    Key? key,
    required String query,
    int zoom = 14,
    double height = 200,
    BorderRadius? borderRadius,
  }) {
    return MapEmbed._(
      query: query,
      zoom: zoom,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(20),
    );
  }

  @override
  State<MapEmbed> createState() => _MapEmbedState();
}

class _MapEmbedState extends State<MapEmbed> {
  // Fallback default Jakarta (Monas) untuk mode "query".
  static const double _fallbackLat = -6.1751;
  static const double _fallbackLng = 106.8650;
  static const double _tileSize = 256.0;

  int _tileErrors = 0;
  int _tileTotal = 0;
  bool get _allFailed => _tileTotal > 0 && _tileErrors >= _tileTotal;

  double get _lat => widget.lat ?? _fallbackLat;
  double get _lng => widget.lng ?? _fallbackLng;
  int get _z => widget.zoom.clamp(2, 19);

  /// Web Mercator: konversi (lat,lng) → fractional tile (x,y) di zoom z.
  ({double x, double y}) _latLngToTile(double lat, double lng, int z) {
    final n = math.pow(2, z).toDouble();
    final x = (lng + 180.0) / 360.0 * n;
    final latRad = lat * math.pi / 180.0;
    final y = (1.0 -
            math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) /
        2.0 *
        n;
    return (x: x, y: y);
  }

  Future<void> _openExternal() async {
    final q = widget.lat != null && widget.lng != null
        ? '${widget.lat},${widget.lng}'
        : (widget.query ?? '');
    if (q.isEmpty) return;
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(q)}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth.isFinite ? c.maxWidth : 360.0;
            final h = widget.height;
            return _allFailed
                ? _MapFallback(onOpen: _openExternal)
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: const Color(0xFFE8E0D8)),
                      _buildTileGrid(w, h),
                      // Pin tengah
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 18),
                          child: Icon(Icons.location_on,
                              color: AppColors.primary,
                              size: 36,
                              shadows: [
                                Shadow(
                                    color: Colors.black38,
                                    blurRadius: 4,
                                    offset: Offset(0, 2))
                              ]),
                        ),
                      ),
                      // Attribution OSM (wajib)
                      Positioned(
                        left: 6,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          color: Colors.white.withValues(alpha: .75),
                          child: const Text('© OpenStreetMap',
                              style: TextStyle(
                                  fontSize: 9, color: Colors.black87)),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Material(
                          color: Colors.white.withValues(alpha: .92),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: _openExternal,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.open_in_new,
                                      size: 14, color: AppColors.primary),
                                  SizedBox(width: 4),
                                  Text('Maps',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildTileGrid(double width, double height) {
    final z = _z;
    final center = _latLngToTile(_lat, _lng, z);
    final centerPxX = center.x * _tileSize;
    final centerPxY = center.y * _tileSize;

    // Berapa tile di kiri/kanan/atas/bawah biar nutup canvas + 1 tile buffer.
    final cols = (width / _tileSize).ceil() + 2;
    final rows = (height / _tileSize).ceil() + 2;
    final startTileX = center.x.floor() - (cols ~/ 2);
    final startTileY = center.y.floor() - (rows ~/ 2);

    // Offset piksel: gambar tile (startTileX,startTileY) di posisi top-left
    // sedemikian rupa sehingga (centerPxX,centerPxY) jatuh di tengah canvas.
    final originPxX = width / 2 - (centerPxX - startTileX * _tileSize);
    final originPxY = height / 2 - (centerPxY - startTileY * _tileSize);

    final maxTile = math.pow(2, z).toInt();
    final tiles = <Widget>[];
    var total = 0;
    for (var i = 0; i < cols; i++) {
      for (var j = 0; j < rows; j++) {
        final tx = startTileX + i;
        final ty = startTileY + j;
        if (ty < 0 || ty >= maxTile) continue;
        final wrappedTx = ((tx % maxTile) + maxTile) % maxTile;
        total++;
        // Sub-domain rotation buat ngehindarin throttling per-host.
        final sub = ['a', 'b', 'c'][(tx + ty).abs() % 3];
        final url =
            'https://$sub.tile.openstreetmap.org/$z/$wrappedTx/$ty.png';
        tiles.add(Positioned(
          left: originPxX + i * _tileSize,
          top: originPxY + j * _tileSize,
          width: _tileSize,
          height: _tileSize,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() => _tileErrors++);
              });
              return const SizedBox.shrink();
            },
          ),
        ));
      }
    }
    if (_tileTotal != total) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _tileTotal = total);
      });
    }
    return Stack(children: tiles);
  }
}

class _MapFallback extends StatelessWidget {
  final VoidCallback? onOpen;
  const _MapFallback({this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cream,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, color: AppColors.primary, size: 36),
          const SizedBox(height: 6),
          const Text('Preview map belum tersedia',
              style: TextStyle(color: AppColors.textSecondary)),
          if (onOpen != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Buka di Google Maps'),
            ),
          ],
        ],
      ),
    );
  }
}
