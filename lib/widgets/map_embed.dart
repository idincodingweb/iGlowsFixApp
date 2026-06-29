import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/theme/app_theme.dart';

/// Widget embed Google Maps tanpa API key.
///
/// Pakai endpoint publik `https://maps.google.com/maps?...&output=embed`
/// yang nge-render mini map interaktif via WebView. Sesuai SOP M9:
/// gak butuh Google Cloud billing / API key Maps.
///
/// Dua mode:
/// - [MapEmbed.coords] kalau punya lat/lng pasti.
/// - [MapEmbed.query]  kalau cuma punya nama tempat/alamat.
class MapEmbed extends StatefulWidget {
  final String url;
  final double height;
  final BorderRadius borderRadius;

  const MapEmbed._({
    required this.url,
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
    final url =
        'https://maps.google.com/maps?q=$lat,$lng&z=$zoom&hl=id&output=embed';
    return MapEmbed._(
      url: url,
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
    final q = Uri.encodeComponent(query.trim().isEmpty ? 'salon' : query);
    final url = 'https://maps.google.com/maps?q=$q&z=$zoom&hl=id&output=embed';
    return MapEmbed._(
      url: url,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(20),
    );
  }

  @override
  State<MapEmbed> createState() => _MapEmbedState();
}

class _MapEmbedState extends State<MapEmbed> {
  WebViewController? _controller;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    try {
      final c = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(AppColors.cream)
        ..setNavigationDelegate(NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (_) {
            if (mounted) {
              setState(() {
                _failed = true;
                _loading = false;
              });
            }
          },
        ))
        ..loadRequest(Uri.parse(widget.url));
      _controller = c;
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            if (_controller != null && !_failed)
              Positioned.fill(child: WebViewWidget(controller: _controller!))
            else
              const _MapFallback(),
            if (_loading && !_failed)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x11FF8FB1),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
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
  const _MapFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cream,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, color: AppColors.primary, size: 36),
          SizedBox(height: 6),
          Text('Map gak bisa dimuat',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
