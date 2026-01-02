import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/link.dart';
import '../repositories/link_repository.dart';
import '../repositories/history_repository.dart';
import '../services/notification_service.dart';
import '../services/appsflyer_service.dart';
import '../config/constants.dart';
import 'settings_provider.dart';

final linkRepositoryProvider = Provider((ref) => LinkRepository());
final historyRepositoryProvider = Provider((ref) => HistoryRepository());

final linkProvider = StateNotifierProvider<LinkNotifier, List<Link>>((ref) {
  final linkRepository = ref.watch(linkRepositoryProvider);
  final historyRepository = ref.watch(historyRepositoryProvider);
  final settings = ref.watch(settingsProvider);
  return LinkNotifier(linkRepository, historyRepository, settings);
});

// 保存可能かどうか（Free版は20件まで）
final canAddLinkProvider = Provider((ref) {
  final links = ref.watch(linkProvider);
  final settings = ref.watch(settingsProvider);
  if (settings.isPro) return true;
  return links.length < AppConstants.freeLinkLimit;
});

// 期限切れリンク
final expiredLinksProvider = Provider((ref) {
  final links = ref.watch(linkProvider);
  final now = DateTime.now();
  return links.where((link) => link.deadline.isBefore(now)).toList();
});

// 本日期限のリンク
final todayLinksProvider = Provider((ref) {
  final links = ref.watch(linkProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  return links.where((link) =>
  link.deadline.isAfter(today) && link.deadline.isBefore(tomorrow)
  ).toList();
});

class LinkNotifier extends StateNotifier<List<Link>> {
  final LinkRepository _linkRepository;
  final HistoryRepository _historyRepository;
  final _notificationService = NotificationService();
  final _appsFlyerService = AppsFlyerService();
  final dynamic _settings;

  LinkNotifier(this._linkRepository, this._historyRepository, this._settings)
      : super(_linkRepository.getAll());

  // リンク追加
  Future<Link> add({
    required String url,
    required String title,
    required DateTime deadline,
  }) async {
    final link = await _linkRepository.add(
      url: url,
      title: title,
      deadline: deadline,
    );

    // Pro版なら通知をスケジュール
    if (_settings.isPro) {
      await _notificationService.scheduleDayOfNotification(link);
      if (_settings.proDayBeforeNotifyHour != null) {
        await _notificationService.scheduleDayBeforeNotification(
          link,
          _settings.proDayBeforeNotifyHour!,
          _settings.proDayBeforeNotifyMinute!,
        );
      }
    }

    // AppsFlyerイベント送信
    await _appsFlyerService.logLinkAdded();

    state = _linkRepository.getAll();
    return link;
  }

  // リンク更新
  Future<void> update(Link link) async {
    await _linkRepository.update(link);

    // 通知を再スケジュール
    if (_settings.isPro) {
      await _notificationService.cancelNotification(link.id);
      await _notificationService.scheduleDayOfNotification(link);
      if (_settings.proDayBeforeNotifyHour != null) {
        await _notificationService.scheduleDayBeforeNotification(
          link,
          _settings.proDayBeforeNotifyHour!,
          _settings.proDayBeforeNotifyMinute!,
        );
      }
    }

    state = _linkRepository.getAll();
  }

  // リンク削除（履歴に移動）
  Future<void> delete(String id, {bool addToHistory = true}) async {
    if (addToHistory) {
      final link = _linkRepository.getById(id);
      if (link != null) {
        await _historyRepository.addFromLink(link);
      }
    }

    // 通知をキャンセル
    await _notificationService.cancelNotification(id);

    // AppsFlyerイベント送信
    await _appsFlyerService.logLinkDeleted();

    await _linkRepository.delete(id);
    state = _linkRepository.getAll();
  }

  // 状態を再読み込み
  void refresh() {
    state = _linkRepository.getAll();
  }
}