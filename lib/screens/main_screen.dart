import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/theme.dart';
import '../providers/link_provider.dart';
import '../providers/settings_provider.dart';
import '../models/link.dart';
import '../widgets/link_card.dart';
import '../widgets/add_link_modal.dart';
import '../widgets/empty_state.dart';
import '../services/ad_service.dart';
import 'settings_screen.dart';
import '../widgets/dashboard_summary.dart';
import '../widgets/tutorial_overlay.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  final AdService _adService = AdService();
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _loadAd();
  }

  void _loadAd() {
    final settings = ref.read(settingsProvider);
    if (!settings.isPro) {
      _adService.loadBannerAd(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          setState(() {
            _isAdLoaded = false;
          });
        },
      );
    }
  }

  @override
  void dispose() {
    _fabController.dispose();
    _adService.disposeBannerAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final links = ref.watch(linkProvider);
    final canAddLink = ref.watch(canAddLinkProvider);
    final settings = ref.watch(settingsProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppTheme.background,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              // ダッシュボード（リンクがある場合のみ表示）
              if (links.isNotEmpty) const DashboardSummary(),

              Expanded(
                child: links.isEmpty
                    ? const EmptyState()
                    : _buildLinkList(links),
              ),

              // Free版のみバナー広告を表示
              if (!settings.isPro && _isAdLoaded && _adService.bannerAd != null)
                Container(
                  color: AppTheme.surface,
                  width: double.infinity,
                  height: _adService.bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _adService.bannerAd!),
                ),
            ],
          ),
          floatingActionButton: _buildFAB(canAddLink),
        ),

        // チュートリアル（未表示かつリンクがある場合）
        if (!settings.hasSeenTutorial && links.isNotEmpty)
          TutorialOverlay(
            onDismiss: () {
              ref.read(settingsProvider.notifier).completeTutorial();
            },
          ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('🔐', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          const Text(
            'LinkTodo',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: () => _openSettings(),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Text('⚙️', style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppTheme.border,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildLinkList(List<Link> links) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: links.length,
      itemBuilder: (context, index) {
        final link = links[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 100)),
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
            child: LinkCard(
              link: link,
              onTap: () => _openUrl(link.url),
              onDelete: () => _deleteLink(link),
              onEdit: () => _editLink(link),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFAB(bool canAddLink) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryDark.withOpacity(0.35),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            if (canAddLink) {
              _showAddLinkModal();
            } else {
              _showProUpsell();
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, size: 32),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
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

  Future<void> _deleteLink(Link link) async {
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
            const Text('削除確認'),
          ],
        ),
        content: Text(
          '「${link.title}」を削除しますか？\n削除したリンクは履歴に保存されます。',
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
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(linkProvider.notifier).delete(link.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('リンクを削除しました'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _editLink(Link link) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddLinkModal(editLink: link),
    );
  }

  void _showAddLinkModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddLinkModal(),
    );
  }

  void _showProUpsell() {
    showDialog(
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
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('⭐', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            const Text('保存上限に達しました'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Free版では20件まで保存できます。',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Proにアップグレードすると：',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildProFeature('📦', '無制限のリンク保存'),
            _buildProFeature('🔔', '期限前通知'),
            _buildProFeature('📚', '履歴保存（90日）'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Pro購入処理
            },
            child: const Text('Proにアップグレード'),
          ),
        ],
      ),
    );
  }

  Widget _buildProFeature(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}