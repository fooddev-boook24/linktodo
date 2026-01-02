import 'package:flutter/material.dart';
import '../config/theme.dart';

class EmptyState extends StatefulWidget {
  const EmptyState({super.key});

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _bounceController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // イラスト
            _buildIllustration(),

            const SizedBox(height: 32),

            // タイトル
            const Text(
              'まだリンクがありません',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            // サブテキスト
            Text(
              '忘れたくないリンクを\n下のボタンから追加しましょう',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      width: 200,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // キラキラ
          _buildSparkle(top: 20, right: 30, delay: 0),
          _buildSparkle(top: 60, left: 20, delay: 0.33),
          _buildSparkle(bottom: 40, right: 40, delay: 0.66),

          // メインの箱
          AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              final value = Curves.easeInOut.transform(_bounceController.value);
              return Transform.translate(
                offset: Offset(0, value * 8 - 4),
                child: child,
              );
            },
            child: Container(
              width: 120,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade300,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '📭',
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSparkle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        final value = ((_sparkleController.value + delay) % 1.0);
        final opacity = (value < 0.5)
            ? value * 2
            : 2 - value * 2;
        final scale = 0.8 + opacity * 0.4;

        return Positioned(
          top: top,
          bottom: bottom,
          left: left,
          right: right,
          child: Opacity(
            opacity: opacity * 0.8 + 0.2,
            child: Transform.scale(
              scale: scale,
              child: const Text(
                '✨',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        );
      },
    );
  }
}