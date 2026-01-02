import 'package:hive/hive.dart';

part 'history.g.dart';

@HiveType(typeId: 1)
class History extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String url;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final DateTime deadline;

  @HiveField(4)
  final DateTime deletedAt;

  History({
    required this.id,
    required this.url,
    required this.title,
    required this.deadline,
    required this.deletedAt,
  });
}