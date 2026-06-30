import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/theme/app_theme.dart';
import '../services/ads_service.dart';

/// M17 — Native ad card untuk diselipkan di tab Notifikasi.
/// Pakai `NativeTemplateStyle` bawaan google_mobile_ads (tanpa factory
/// native Kotlin) biar gak nyentuh `MainActivity`.
class NativeAdCard extends StatefulWidget {
  const NativeAdCard({super.key});

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard> {
  NativeAd? _ad;
  bool _loaded = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    try {
      _ad = NativeAd(
        adUnitId: AdsService.nativeNotificationsUnitId,
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (_) {
            if (!mounted) return;
            setState(() => _loaded = true);
          },
          onAdFailedToLoad: (ad, err) {
            ad.dispose();
            if (!mounted) return;
            setState(() {
              _ad = null;
              _failed = true;
            });
          },
        ),
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.medium,
          mainBackgroundColor: AppColors.surface,
          cornerRadius: 16,
          callToActionTextStyle: NativeTemplateTextStyle(
            textColor: Colors.white,
            backgroundColor: AppColors.primary,
            size: 14,
          ),
          primaryTextStyle: NativeTemplateTextStyle(
            textColor: AppColors.textPrimary,
            size: 14,
          ),
          secondaryTextStyle: NativeTemplateTextStyle(
            textColor: AppColors.textSecondary,
            size: 12,
          ),
          tertiaryTextStyle: NativeTemplateTextStyle(
            textColor: AppColors.textSecondary,
            size: 11,
          ),
        ),
      )..load();
    } catch (_) {
      _failed = true;
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return const SizedBox.shrink();
    if (!_loaded || _ad == null) {
      return const SizedBox(height: 0);
    }
    return Container(
      constraints: const BoxConstraints(minHeight: 320, maxHeight: 360),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.primarySoft.withValues(alpha: .4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: AdWidget(ad: _ad!),
    );
  }
}
