import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history.dart';
import '../repositories/history_repository.dart';
import 'link_provider.dart';

final historyProvider = StateNotifierProvider<HistoryNotifier, List<History>>((ref) {
  final historyRepository = ref.watch(historyRepositoryProvider);
  return HistoryNotifier(historyRepository);
});

class HistoryNotifier extends StateNotifier<List<History>> {
  final HistoryRepository _repository;

  HistoryNotifier(this._repository) : super(_repository.getAll());

  // 履歴削除
  Future<void> delete(String id) async {
    await _repository.delete(id);
    state = _repository.getAll();
  }

  // 90日経過した履歴を削除
  Future<void> cleanupOldHistory() async {
    await _repository.cleanupOldHistory();
    state = _repository.getAll();
  }

  // 状態を再読み込み
  void refresh() {
    state = _repository.getAll();
  }
}