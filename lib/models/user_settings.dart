import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 2)
class UserSettings extends HiveObject {
  @HiveField(0)
  bool isPro;

  @HiveField(1)
  bool isFirstLaunch;

  @HiveField(2)
  int? proDayBeforeNotifyHour;

  @HiveField(3)
  int? proDayBeforeNotifyMinute;

  @HiveField(4)
  bool hasSeenTutorial;

  UserSettings({
    this.isPro = false,
    this.isFirstLaunch = true,
    this.proDayBeforeNotifyHour,
    this.proDayBeforeNotifyMinute,
    this.hasSeenTutorial = false,
  });
}