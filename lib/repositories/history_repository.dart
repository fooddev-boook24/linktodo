import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/link.dart';
import '../models/history.dart';
import '../config/constants.dart';

class HistoryRepository {
  Box<History> get _box => Hive.box<History>(AppConstants.historyBoxName);
  final _uuid = const Uuid();

  // 全履歴取得（削除日が新しい順）
  List<History> getAll() {
    final histories = _box.values.toList();
    histories.sort((a, b) => b.deletedAt.compareTo(a.deletedAt));
    return histories;
  }

  // Linkから履歴を追加
  Future<History> addFromLink(Link link) async {
    final history = History(
      id: _uuid.v4(),
      url: link.url,
      title: link.title,
      deadline: link.deadline,
      deletedAt: DateTime.now(),
    );
    await _box.put(history.id, history);
    return history;
  }

  // 履歴削除
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  // 90日経過した履歴を削除
  Future<void> cleanupOldHistory() async {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: AppConstants.historyRetentionDays));

    final toDelete = _box.values
        .where((h) => h.deletedAt.isBefore(cutoff))
        .map((h) => h.id)
        .toList();

    for (final id in toDelete) {
      await _box.delete(id);
    }
  }
}