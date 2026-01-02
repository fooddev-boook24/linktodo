import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/link.dart';
import '../config/constants.dart';

class LinkRepository {
  Box<Link> get _box => Hive.box<Link>(AppConstants.linksBoxName);
  final _uuid = const Uuid();

  // 全リンク取得（期限が近い順）
  List<Link> getAll() {
    final links = _box.values.toList();
    links.sort((a, b) => a.deadline.compareTo(b.deadline));
    return links;
  }

  // リンク追加
  Future<Link> add({
    required String url,
    required String title,
    required DateTime deadline,
  }) async {
    final link = Link(
      id: _uuid.v4(),
      url: url,
      title: title,
      deadline: deadline,
      createdAt: DateTime.now(),
    );
    await _box.put(link.id, link);
    return link;
  }

  // リンク更新
  Future<void> update(Link link) async {
    await link.save();
  }

  // リンク削除
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  // リンク件数取得
  int count() {
    return _box.length;
  }

  // IDでリンク取得
  Link? getById(String id) {
    return _box.get(id);
  }
}