import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_theme.dart';

/// Widget peta yang nge-render static map dari OpenStreetMap (tanpa API key).
///
/// Sumber tile: `https://staticmap.openstreetmap.de/staticmap.php` — gratis,
/// publik, gak butuh key. Kalau request gagal (offline / 5xx), widget jatuh
/// ke fallback aman + tombol "Buka di Google Maps".
///
/// API publik widget (`MapEmbed.coords` / `MapEmbed.query`) DIPERTAHANKAN
/// sama persis biar pemanggil (salon screen / detail) gak perlu diubah.
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
  // Fallback default Jakarta (Monas) untuk mode "query" — OSM staticmap butuh
  // koordinat, jadi query teks tidak bisa langsung dipakai. Lebih aman center
  // ke Jakarta supaya tetap jalan offline-friendly.
  static const double _fallbackLat = -6.1751;
  static const double _fallbackLng = 106.8650;

  late final String _imageUrl = _buildUrl();
  bool _failed = false;

  String _buildUrl() {
    final h = widget.height.round().clamp(180, 640);
    final w = (h * 1.8).round().clamp(320, 900);
    final lat = widget.lat ?? _fallbackLat;
    final lng = widget.lng ?? _fallbackLng;
    final marker = '$lat,$lng,red-pushpin';
    return 'https://staticmap.openstreetmap.de/staticmap.php'
        '?center=$lat,$lng'
        '&zoom=${widget.zoom}'
        '&size=${w}x$h'
        '&maptype=mapnik'
        '&markers=$marker';
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!_failed)
              Image.network(
                _imageUrl,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: AppColors.primarySoft.withValues(alpha: .25),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  );
                },
                errorBuilder: (_, __, ___) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _failed = true);
                  });
                  return _MapFallback(onOpen: _openExternal);
                },
              )
            else
              _MapFallback(onOpen: _openExternal),
            if (!_failed)
              Positioned(
                right: 8,
                bottom: 8,
                child: Material(
                  color: Colors.white.withValues(alpha: .9),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _openExternal,
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
        ),
      ),
    );
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
