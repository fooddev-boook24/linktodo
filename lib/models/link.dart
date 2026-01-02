import 'package:hive/hive.dart';

part 'link.g.dart';

@HiveType(typeId: 0)
class Link extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String url;

  @HiveField(2)
  String title;

  @HiveField(3)
  DateTime deadline;

  @HiveField(4)
  final DateTime createdAt;

  Link({
    required this.id,
    required this.url,
    required this.title,
    required this.deadline,
    required this.createdAt,
  });
}