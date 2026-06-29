import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_theme.dart';
import '../services/rapid_maps_service.dart';

/// Widget peta yang nge-render Street View dari RapidAPI
/// `google-map-places.p.rapidapi.com/maps/api/streetview`.
///
/// API key dibaca dari `--dart-define=RAPIDAPI_KEY=...` (di-inject GitHub
/// Actions dari GitHub Secret saat build). Kalau key belum ada / request
/// gagal, widget jatuh ke fallback aman + tombol "Buka di Google Maps"
/// supaya UX tetep jalan.
///
/// API publik widget (`MapEmbed.coords` / `MapEmbed.query`) DIPERTAHANKAN
/// sama persis biar pemanggil (salon screen / detail) gak perlu diubah.
class MapEmbed extends StatefulWidget {
  final String? coordsLocation; // "lat,lng" untuk RapidAPI
  final String? queryLocation;  // teks bebas
  final double? lat;
  final double? lng;
  final String? query;
  final double height;
  final BorderRadius borderRadius;

  const MapEmbed._({
    this.coordsLocation,
    this.queryLocation,
    this.lat,
    this.lng,
    this.query,
    required this.height,
    required this.borderRadius,
  });

  factory MapEmbed.coords({
    Key? key,
    required double lat,
    required double lng,
    int zoom = 15, // dipertahankan utk kompat — tidak dipakai RapidAPI.
    double height = 200,
    BorderRadius? borderRadius,
  }) {
    return MapEmbed._(
      coordsLocation: '$lat,$lng',
      lat: lat,
      lng: lng,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(20),
    );
  }

  factory MapEmbed.query({
    Key? key,
    required String query,
    int zoom = 14, // kompat — tidak dipakai RapidAPI.
    double height = 200,
    BorderRadius? borderRadius,
  }) {
    return MapEmbed._(
      queryLocation: query,
      query: query,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(20),
    );
  }

  @override
  State<MapEmbed> createState() => _MapEmbedState();
}

class _MapEmbedState extends State<MapEmbed> {
  Uint8List? _bytes;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // Pixel size mengikuti tinggi widget supaya proporsional di layar.
      final h = widget.height.round().clamp(200, 640);
      final w = (h * 1.6).round().clamp(320, 960);

      Uint8List? bytes;
      if (widget.coordsLocation != null) {
        bytes = await RapidMapsService.instance.fetchStreetViewByCoords(
          lat: widget.lat ?? 0,
          lng: widget.lng ?? 0,
          width: w,
          height: h,
        );
      } else {
        bytes = await RapidMapsService.instance.fetchStreetViewByQuery(
          query: widget.query ?? '',
          width: w,
          height: h,
        );
      }

      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _failed = bytes == null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  Future<void> _openExternal() async {
    final q = widget.coordsLocation ?? widget.query ?? '';
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
            if (_bytes != null && !_failed)
              Image.memory(_bytes!, fit: BoxFit.cover, gaplessPlayback: true)
            else
              _MapFallback(onOpen: _openExternal),
            if (_loading)
              const ColoredBox(
                color: Color(0x11FF8FB1),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
            if (_bytes != null && !_failed)
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
          const Icon(Icons.map_outlined,
              color: AppColors.primary, size: 36),
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
