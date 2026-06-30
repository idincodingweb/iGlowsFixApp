import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// M17 — AdMob singleton.
///
/// Tiga placement:
/// 1. Interstitial @ Skin Analyst → setiap 3x analisa selesai.
/// 2. Rewarded   @ Konsultasi Chat → muncul tiap user kirim pesan ke-5
///    (5, 10, 15, ...).
/// 3. Native     @ Tab Notifikasi   → diselipkan di list notifikasi.
///
/// Counter in-memory per sesi app. AdMob init dilakukan dari `main.dart`.
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  // --- Ad unit IDs (production) ---
  static const String interstitialAnalyzerUnitId =
      'ca-app-pub-4040764940734722/9846311837';
  static const String rewardedConsultUnitId =
      'ca-app-pub-4040764940734722/7807874225';
  static const String nativeNotificationsUnitId =
      'ca-app-pub-4040764940734722/7958515094';

  // --- Trigger thresholds ---
  static const int analyzerInterstitialEvery = 3;
  static const int consultRewardedEvery = 5;

  bool _initialized = false;
  Future<void> init() async {
    if (_initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
    } catch (e) {
      debugPrint('AdsService init error: $e');
    }
  }

  // ---------------- Interstitial (Skin Analyst) ----------------

  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;
  int _analyzerCount = 0;

  void preloadInterstitial() {
    if (_interstitial != null || _loadingInterstitial) return;
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: interstitialAnalyzerUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (err) {
          debugPrint('Interstitial failed: $err');
          _interstitial = null;
          _loadingInterstitial = false;
        },
      ),
    );
  }

  /// Dipanggil setiap kali Skin Analyst selesai 1 analisa.
  /// Tampilkan interstitial tiap kelipatan [analyzerInterstitialEvery].
  Future<void> onAnalyzerCompleted() async {
    _analyzerCount++;
    if (_analyzerCount % analyzerInterstitialEvery != 0) {
      preloadInterstitial();
      return;
    }
    final ad = _interstitial;
    if (ad == null) {
      preloadInterstitial();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _interstitial = null;
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (a, err) {
        a.dispose();
        _interstitial = null;
        preloadInterstitial();
      },
    );
    await ad.show();
    _interstitial = null;
  }

  // ---------------- Rewarded (Konsultasi Chat) ----------------

  RewardedAd? _rewarded;
  bool _loadingRewarded = false;
  int _chatSendCount = 0;

  void preloadRewarded() {
    if (_rewarded != null || _loadingRewarded) return;
    _loadingRewarded = true;
    RewardedAd.load(
      adUnitId: rewardedConsultUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _loadingRewarded = false;
        },
        onAdFailedToLoad: (err) {
          debugPrint('Rewarded failed: $err');
          _rewarded = null;
          _loadingRewarded = false;
        },
      ),
    );
  }

  /// Dipanggil setiap user mengirim 1 pesan ke konsultan.
  /// Iklan rewarded muncul pertama kali di kiriman ke-5, lalu setiap
  /// kelipatan 5 (10, 15, 20, ...).
  Future<void> onConsultMessageSent() async {
    _chatSendCount++;
    if (_chatSendCount % consultRewardedEvery != 0) {
      preloadRewarded();
      return;
    }
    final ad = _rewarded;
    if (ad == null) {
      preloadRewarded();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _rewarded = null;
        preloadRewarded();
      },
      onAdFailedToShowFullScreenContent: (a, err) {
        a.dispose();
        _rewarded = null;
        preloadRewarded();
      },
    );
    await ad.show(onUserEarnedReward: (_, __) {});
    _rewarded = null;
  }
}
