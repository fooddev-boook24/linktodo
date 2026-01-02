import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_settings.dart';
import '../repositories/settings_repository.dart';
import '../services/iap_service.dart';

final settingsProvider =
StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  final repository = SettingsRepository();
  return SettingsNotifier(repository);
});

class SettingsNotifier extends StateNotifier<UserSettings> {
  final SettingsRepository _repository;
  final IAPService _iapService = IAPService();

  SettingsNotifier(this._repository) : super(_repository.getSettings()) {
    _initIAP();
  }

  void _initIAP() {
    _iapService.onPurchaseComplete = (success) async {
      if (success) {
        await _setPro(true);
      }
    };
  }

  // Pro状態を更新
  Future<void> _setPro(bool isPro) async {
    await _repository.setPro(isPro);
    state = _repository.getSettings();
  }

  // Pro購入
  Future<bool> purchasePro() async {
    return await _iapService.purchasePro();
  }

  // 購入を復元
  Future<void> restorePurchases() async {
    await _iapService.restorePurchases();
  }

  // 初回起動完了
  Future<void> completeFirstLaunch() async {
    await _repository.setFirstLaunch(false);
    state = _repository.getSettings();
  }

  // チュートリアル完了
  Future<void> completeTutorial() async {
    await _repository.setHasSeenTutorial(true);
    state = _repository.getSettings();
  }

  // Pro版の通知時刻を設定
  Future<void> setProNotifyTime(int hour, int minute) async {
    await _repository.setProNotifyTime(hour, minute);
    state = _repository.getSettings();
  }

  // Pro版の通知時刻をクリア
  Future<void> clearProNotifyTime() async {
    await _repository.clearProNotifyTime();
    state = _repository.getSettings();
  }
}