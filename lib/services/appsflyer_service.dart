import 'dart:io';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

class AppsFlyerService {
  static final AppsFlyerService _instance = AppsFlyerService._internal();
  factory AppsFlyerService() => _instance;
  AppsFlyerService._internal();

  late AppsflyerSdk _appsflyerSdk;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    final options = AppsFlyerOptions(
      afDevKey: 'YOUR_APPSFLYER_DEV_KEY', // TODO: 本番キーに置き換え
      appId: Platform.isIOS ? '1234567890' : '', // TODO: iOSアプリID
      showDebug: true, // リリース時はfalse
    );

    _appsflyerSdk = AppsflyerSdk(options);
    await _appsflyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
    );

    _isInitialized = true;
  }

  // イベント送信
  Future<void> logEvent(String eventName, Map<String, dynamic>? eventValues) async {
    if (!_isInitialized) return;
    await _appsflyerSdk.logEvent(eventName, eventValues);
  }

  // リンク追加イベント
  Future<void> logLinkAdded() async {
    await logEvent('link_added', null);
  }

  // リンク削除イベント
  Future<void> logLinkDeleted() async {
    await logEvent('link_deleted', null);
  }

  // Pro購入イベント
  Future<void> logProPurchase(double price, String currency) async {
    await logEvent('af_purchase', {
      'af_revenue': price,
      'af_currency': currency,
      'af_content_type': 'subscription',
    });
  }
}