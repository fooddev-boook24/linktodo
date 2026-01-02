import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/settings_provider.dart';
import 'history_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
        title: const Text(
          '設定',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppTheme.border, height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // プランセクション
          _buildPlanCard(context, ref, settings.isPro),

          const SizedBox(height: 24),

          // 機能セクション
          _buildSectionTitle('機能'),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            ref,
            settings,
          ),

          const SizedBox(height: 24),

          // アプリ情報
          _buildSectionTitle('アプリ情報'),
          const SizedBox(height: 12),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, WidgetRef ref, bool isPro) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isPro
            ? const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isPro ? null : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: isPro ? null : Border.all(color: AppTheme.border),
        boxShadow: isPro
            ? [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isPro ? Colors.white.withOpacity(0.3) : AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPro ? '👑' : '🔓',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPro ? 'Pro プラン' : 'Free プラン',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isPro ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPro
                          ? '全ての機能が使えます'
                          : '${AppConstants.freeLinkLimit}件まで保存可能',
                      style: TextStyle(
                        fontSize: 13,
                        color: isPro ? Colors.white.withOpacity(0.9) : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isPro) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryDark.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => _showProUpgrade(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Proにアップグレード',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text('✨', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context,
      WidgetRef ref,
      dynamic settings,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          // 通知設定
          _buildFeatureItem(
            emoji: '🔔',
            title: '期限1日前に通知',
            subtitle: settings.isPro
                ? (settings.proDayBeforeNotifyHour != null
                ? '${settings.proDayBeforeNotifyHour}:${settings.proDayBeforeNotifyMinute.toString().padLeft(2, '0')} に通知'
                : 'オフ')
                : 'Pro限定機能',
            trailing: settings.isPro
                ? Switch(
              value: settings.proDayBeforeNotifyHour != null,
              activeColor: AppTheme.primary,
              onChanged: (value) {
                if (value) {
                  _selectNotifyTime(context, ref);
                } else {
                  ref.read(settingsProvider.notifier).clearProNotifyTime();
                }
              },
            )
                : Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('🔒', style: TextStyle(fontSize: 16)),
            ),
            onTap: settings.isPro && settings.proDayBeforeNotifyHour != null
                ? () => _selectNotifyTime(context, ref)
                : null,
          ),

          Container(height: 1, color: AppTheme.border, margin: const EdgeInsets.symmetric(horizontal: 16)),

          // 履歴
          _buildFeatureItem(
            emoji: '📚',
            title: '削除済みリンク',
            subtitle: settings.isPro ? '過去90日分の履歴' : 'Pro限定機能',
            trailing: settings.isPro
                ? const Icon(Icons.chevron_right_rounded, color: AppTheme.textHint)
                : Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('🔒', style: TextStyle(fontSize: 16)),
            ),
            onTap: settings.isPro
                ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required String emoji,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _buildInfoItem('📱', 'バージョン', '1.0.0'),
          Container(height: 1, color: AppTheme.border, margin: const EdgeInsets.symmetric(horizontal: 16)),
          _buildInfoItem('💬', 'お問い合わせ', 'サポートへ連絡'),
          Container(height: 1, color: AppTheme.border, margin: const EdgeInsets.symmetric(horizontal: 16)),
          _buildInfoItem('📄', '利用規約', ''),
          Container(height: 1, color: AppTheme.border, margin: const EdgeInsets.symmetric(horizontal: 16)),
          _buildInfoItem('🔒', 'プライバシーポリシー', ''),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String emoji, String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            )
          else
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textHint),
        ],
      ),
    );
  }

  void _showProUpgrade(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ハンドル
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // アイコン
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('👑', style: TextStyle(fontSize: 40)),
            ),

            const SizedBox(height: 20),

            const Text(
              'Pro にアップグレード',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 24),

            _buildProFeatureRow('📦', '無制限のリンク保存'),
            const SizedBox(height: 12),
            _buildProFeatureRow('🔔', '期限前通知'),
            const SizedBox(height: 12),
            _buildProFeatureRow('📚', '履歴保存（90日）'),

            const SizedBox(height: 32),

            // 価格
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '¥360 / 月',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 購入ボタン
// 購入ボタン
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryDark.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final success = await ref.read(settingsProvider.notifier).purchasePro();
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('購入処理を開始できませんでした'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '今すぐ始める',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

// 復元ボタン
            TextButton(
              onPressed: () async {
                await ref.read(settingsProvider.notifier).restorePurchases();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('購入の復元を確認しています...'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                '購入を復元',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'あとで',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProFeatureRow(String emoji, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Future<void> _selectNotifyTime(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(settingsProvider);
    final initialTime = TimeOfDay(
      hour: settings.proDayBeforeNotifyHour ?? 9,
      minute: settings.proDayBeforeNotifyMinute ?? 0,
    );

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.surface,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      await ref.read(settingsProvider.notifier).setProNotifyTime(
        time.hour,
        time.minute,
      );
    }
  }
}