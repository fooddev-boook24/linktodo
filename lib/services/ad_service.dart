import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  BannerAd? _bannerAd;
  bool _isInitialized = false;

  // テスト用広告ID
  String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Androidテスト
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOSテスト
    }
    return '';
  }

  // 本番用広告ID（リリース時に置き換え）
  // Android: ca-app-pub-1178983985791938/6808708009
  // iOS: ca-app-pub-1178983985791938/4364369887

  Future<void> init() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
  }

  BannerAd? get bannerAd => _bannerAd;

  Future<void> loadBannerAd({
    required Function(Ad) onAdLoaded,
    required Function(Ad, LoadAdError) onAdFailedToLoad,
  }) async {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onAdFailedToLoad(ad, error);
        },
      ),
    );

    await _bannerAd?.load();
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }
}