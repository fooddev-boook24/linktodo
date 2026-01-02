import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../providers/history_provider.dart';
import '../models/history.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histories = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('📚', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 10),
            const Text(
              '履歴',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppTheme.border, height: 1),
        ),
      ),
      body: histories.isEmpty
          ? _buildEmptyState()
          : _buildHistoryList(context, ref, histories),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text('📭', style: TextStyle(fontSize: 56)),
          ),
          const SizedBox(height: 24),
          const Text(
            '履歴がありません',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '削除したリンクがここに表示されます',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
      BuildContext context,
      WidgetRef ref,
      List<History> histories,
      ) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: histories.length,
      itemBuilder: (context, index) {
        final history = histories[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _HistoryCard(
              history: history,
              onTap: () => _openUrl(context, history.url),
              onDelete: () => _deleteHistory(context, ref, history),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('URLを開けませんでした'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteHistory(
      BuildContext context,
      WidgetRef ref,
      History history,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('🗑️', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            const Text('履歴を削除'),
          ],
        ),
        content: Text(
          '「${history.title}」を履歴から完全に削除しますか？\nこの操作は取り消せません。',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text(
              '削除',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(historyProvider.notifier).delete(history.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('履歴を削除しました'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}

class _HistoryCard extends StatelessWidget {
  final History history;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.history,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(history.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppTheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('🗑️', style: TextStyle(fontSize: 24)),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
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
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    _getEmoji(history.title),
                    style: const TextStyle(fontSize: 22),
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
                      history.title,
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
                        const Text('🗓️', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '削除: ${DateFormat('M/d').format(history.deletedAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '期限: ${DateFormat('M/d').format(history.deadline)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textHint,
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
}