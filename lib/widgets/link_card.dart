import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/link.dart';

class LinkCard extends StatelessWidget {
  final Link link;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const LinkCard({
    super.key,
    required this.link,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isExpired = link.deadline.isBefore(now);
    final isToday = _isToday(link.deadline);

    return Dismissible(
      key: Key(link.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppTheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          '🗑️',
          style: TextStyle(fontSize: 24),
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onEdit,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isExpired
                  ? AppTheme.error.withOpacity(0.5)
                  : isToday
                  ? AppTheme.primary.withOpacity(0.5)
                  : AppTheme.border,
              width: isExpired || isToday ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // アイコン
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isExpired
                      ? AppTheme.errorLight
                      : isToday
                      ? AppTheme.warningLight
                      : AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    _getEmoji(link.title),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // コンテンツ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          isExpired ? '⚠️' : isToday ? '⏰' : '📅',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDeadline(link.deadline),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isExpired || isToday
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isExpired
                                ? AppTheme.error
                                : isToday
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 矢印
              const Text(
                '›',
                style: TextStyle(
                  fontSize: 24,
                  color: AppTheme.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getEmoji(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('電気') || lower.contains('ガス') || lower.contains('水道')) {
      return '💡';
    } else if (lower.contains('支払') || lower.contains('pay') || lower.contains('料金')) {
      return '💰';
    } else if (lower.contains('解約') || lower.contains('キャンセル')) {
      return '📱';
    } else if (lower.contains('チケット') || lower.contains('ticket') || lower.contains('ライブ')) {
      return '🎫';
    } else if (lower.contains('申請') || lower.contains('届出') || lower.contains('確定申告')) {
      return '📋';
    } else if (lower.contains('病院') || lower.contains('予約')) {
      return '🏥';
    } else if (lower.contains('契約')) {
      return '📝';
    } else {
      return '🔗';
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();

    if (deadline.isBefore(now)) {
      return '期限切れ';
    } else if (_isToday(deadline)) {
      return '今日 ${DateFormat('HH:mm').format(deadline)} まで';
    } else {
      final diff = deadline.difference(now);
      if (diff.inDays == 0) {
        return '明日 ${DateFormat('HH:mm').format(deadline)} まで';
      } else if (diff.inDays < 7) {
        return '${diff.inDays + 1}日後まで';
      } else {
        return '${DateFormat('M/d').format(deadline)} まで';
      }
    }
  }
}