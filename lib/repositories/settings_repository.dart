import 'package:hive/hive.dart';
import '../models/user_settings.dart';
import '../config/constants.dart';

class SettingsRepository {
  Box<UserSettings> get _box => Hive.box<UserSettings>(AppConstants.settingsBoxName);

  // 設定を取得（なければデフォルト作成）
  UserSettings getSettings() {
    final existing = _box.get('settings');
    if (existing == null) {
      final settings = UserSettings();
      _box.put('settings', settings);
      return settings;
    }
    return existing;
  }

  // Pro状態を更新
  Future<void> setPro(bool isPro) async {
    final settings = getSettings();
    settings.isPro = isPro;
    await settings.save();
  }

  // 初回起動フラグを更新
  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    final settings = getSettings();
    settings.isFirstLaunch = isFirstLaunch;
    await settings.save();
  }

  // チュートリアル完了フラグを更新
  Future<void> setHasSeenTutorial(bool hasSeen) async {
    final settings = getSettings();
    settings.hasSeenTutorial = hasSeen;
    await settings.save();
  }

  // Pro版の通知時刻を設定
  Future<void> setProNotifyTime(int hour, int minute) async {
    final settings = getSettings();
    settings.proDayBeforeNotifyHour = hour;
    settings.proDayBeforeNotifyMinute = minute;
    await settings.save();
  }

  // Pro版の通知時刻をクリア
  Future<void> clearProNotifyTime() async {
    final settings = getSettings();
    settings.proDayBeforeNotifyHour = null;
    settings.proDayBeforeNotifyMinute = null;
    await settings.save();
  }
}