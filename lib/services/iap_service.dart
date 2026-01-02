import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'appsflyer_service.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final _appsFlyerService = AppsFlyerService();

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];

  // 商品ID
  static const String _proMonthlyId = 'pro_monthly';
  static final Set<String> _productIds = {_proMonthlyId};

  // コールバック
  Function(bool success)? onPurchaseComplete;

  List<ProductDetails> get products => _products;

  Future<void> init() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    // 購入ストリームを監視
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        // エラー処理
      },
    );

    // 商品情報を取得
    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails(_productIds);
    if (response.notFoundIDs.isNotEmpty) {
      // 商品が見つからない場合のログ
    }
    _products = response.productDetails;
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
        // 処理中
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _verifyAndDeliverPurchase(purchase);
          break;
        case PurchaseStatus.error:
          _handleError(purchase);
          break;
        case PurchaseStatus.canceled:
          onPurchaseComplete?.call(false);
          break;
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _verifyAndDeliverPurchase(PurchaseDetails purchase) async {
    // TODO: サーバーサイドでレシート検証を行う場合はここで実装
    // 今回はローカルで処理

    if (purchase.productID == _proMonthlyId) {
      // AppsFlyerに購入イベントを送信
      final price = _getProductPrice(_proMonthlyId);
      await _appsFlyerService.logProPurchase(price, 'JPY');

      onPurchaseComplete?.call(true);
    }
  }

  double _getProductPrice(String productId) {
    final product = _products.firstWhere(
          (p) => p.id == productId,
      orElse: () => _products.first,
    );
    // rawPriceから取得、なければデフォルト値
    return product.rawPrice;
  }

  void _handleError(PurchaseDetails purchase) {
    onPurchaseComplete?.call(false);
  }

  // Pro版を購入
  Future<bool> purchasePro() async {
    if (_products.isEmpty) {
      await _loadProducts();
    }

    final product = _products.firstWhere(
          (p) => p.id == _proMonthlyId,
      orElse: () => throw Exception('Product not found'),
    );

    final purchaseParam = PurchaseParam(productDetails: product);

    try {
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      return false;
    }
  }

  // 購入を復元
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
  }
}