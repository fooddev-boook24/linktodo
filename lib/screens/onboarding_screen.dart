import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/settings_provider.dart';
import 'main_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 浮遊アニメーション
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // フェードインアニメーション
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 1),

                // イラスト部分
                _buildIllustration(),

                const SizedBox(height: 48),

                // タイトル
                Text(
                  'このリンク、\n忘れたら損するなら、\nここに入れとけ。',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 24),

                // タグ
                _buildTags(),

                const Spacer(flex: 2),

                // ボタン
                _buildButton(),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      width: 240,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 金庫アイコン
          Container(
            width: 140,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🔐',
                style: TextStyle(fontSize: 48),
              ),
            ),
          ),

          // 浮遊するリンクカード
          _buildFloatingCard(
            top: 0,
            right: 10,
            delay: 0,
            emoji: '🔗',
            label: '支払い',
          ),
          _buildFloatingCard(
            bottom: 10,
            left: 0,
            delay: 0.33,
            emoji: '📄',
            label: '解約',
          ),
          _buildFloatingCard(
            top: 50,
            left: 10,
            delay: 0.66,
            emoji: '🎫',
            label: 'チケット',
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCard({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double delay,
    required String emoji,
    required String label,
  }) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final value = Curves.easeInOut.transform(
          ((_floatController.value + delay) % 1.0),
        );
        final offset = (value - 0.5) * 16;

        return Positioned(
          top: top != null ? top + offset : null,
          bottom: bottom != null ? bottom - offset : null,
          left: left,
          right: right,
          child: child!,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags() {
    final tags = [
      ('💰', '支払い'),
      ('📝', '解約'),
      ('📋', '申請'),
      ('🎫', 'チケット'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tag.$1, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                tag.$2,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: DecoratedBox(
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
          onPressed: _onStart,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '今すぐ入れる',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8),
              Text('✨', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onStart() async {
    await ref.read(settingsProvider.notifier).completeFirstLaunch();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
          const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }
}