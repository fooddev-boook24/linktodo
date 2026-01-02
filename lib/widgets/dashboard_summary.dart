import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/link_provider.dart';

class DashboardSummary extends ConsumerWidget {
  const DashboardSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(linkProvider);
    final expiredLinks = ref.watch(expiredLinksProvider);
    final todayLinks = ref.watch(todayLinksProvider);

    final todayCount = todayLinks.length;
    final expiredCount = expiredLinks.length;
    final totalCount = links.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          _buildStat(todayCount, '今日', isAlert: todayCount > 0),
          _buildDivider(),
          _buildStat(expiredCount, '期限切れ', isDanger: expiredCount > 0),
          _buildDivider(),
          _buildStat(totalCount, '保存中'),
        ],
      ),
    );
  }

  Widget _buildStat(int count, String label, {bool isAlert = false, bool isDanger = false}) {
    Color numColor = AppTheme.textPrimary;
    if (isDanger && count > 0) {
      numColor = AppTheme.error;
    } else if (isAlert && count > 0) {
      numColor = AppTheme.primary;
    }

    return Row(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: numColor,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: 1,
      height: 24,
      color: AppTheme.border,
    );
  }
}