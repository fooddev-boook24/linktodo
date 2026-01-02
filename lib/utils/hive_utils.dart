import 'package:hive_flutter/hive_flutter.dart';
import '../models/link.dart';
import '../models/history.dart';
import '../models/user_settings.dart';
import '../config/constants.dart';

class HiveUtils {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Adapter を登録
    Hive.registerAdapter(LinkAdapter());
    Hive.registerAdapter(HistoryAdapter());
    Hive.registerAdapter(UserSettingsAdapter());

    // Box を開く
    await Hive.openBox<Link>(AppConstants.linksBoxName);
    await Hive.openBox<History>(AppConstants.historyBoxName);
    await Hive.openBox<UserSettings>(AppConstants.settingsBoxName);
  }
}