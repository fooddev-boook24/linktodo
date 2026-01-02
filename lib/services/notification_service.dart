import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/link.dart';
import '../config/constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // タイムゾーン初期化
    tz_data.initializeTimeZones();

    // Android設定
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS設定
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  // 通知権限をリクエスト
  Future<bool> requestPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  // 期限当日の通知をスケジュール（9:00）
  Future<void> scheduleDayOfNotification(Link link) async {
    final scheduledDate = DateTime(
      link.deadline.year,
      link.deadline.month,
      link.deadline.day,
      AppConstants.defaultNotificationHour,
      AppConstants.defaultNotificationMinute,
    );

    // 過去の日時ならスキップ
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _scheduleNotification(
      id: link.id.hashCode,
      title: '📌 今日が期限です',
      body: '「${link.title}」を忘れずに確認しましょう',
      scheduledDate: scheduledDate,
    );
  }

  // 期限1日前の通知をスケジュール（Pro機能）
  Future<void> scheduleDayBeforeNotification(
      Link link,
      int hour,
      int minute,
      ) async {
    final scheduledDate = DateTime(
      link.deadline.year,
      link.deadline.month,
      link.deadline.day - 1,
      hour,
      minute,
    );

    // 過去の日時ならスキップ
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _scheduleNotification(
      id: link.id.hashCode + 1000000,
      title: '⏰ 明日が期限です',
      body: '「${link.title}」の期限が明日までです',
      scheduledDate: scheduledDate,
    );
  }

  // 通知をスケジュール
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'linktodo_channel',
      'LinkTodo通知',
      channelDescription: 'リンクの期限通知',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 特定のリンクの通知をキャンセル
  Future<void> cancelNotification(String linkId) async {
    await _plugin.cancel(linkId.hashCode);
    await _plugin.cancel(linkId.hashCode + 1000000);
  }

  // 全ての通知をキャンセル
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  // 全リンクの通知を再スケジュール
  Future<void> rescheduleAllNotifications(
      List<Link> links, {
        bool isPro = false,
        int? proNotifyHour,
        int? proNotifyMinute,
      }) async {
    await cancelAllNotifications();

    for (final link in links) {
      if (isPro) {
        await scheduleDayOfNotification(link);
        if (proNotifyHour != null && proNotifyMinute != null) {
          await scheduleDayBeforeNotification(
            link,
            proNotifyHour,
            proNotifyMinute,
          );
        }
      }
    }
  }
}