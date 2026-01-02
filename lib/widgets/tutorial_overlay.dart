import 'package:flutter/material.dart';
import '../config/theme.dart';

class TutorialOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const TutorialOverlay({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '使い方',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                _buildTip('👆', 'タップ', 'リンクを開く'),
                const SizedBox(height: 24),
                _buildTip('👆👆', '長押し', 'リンクを編集'),
                const SizedBox(height: 24),
                _buildTip('👈', '左スワイプ', 'リンクを削除'),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'タップして閉じる',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String emoji, String action, String description) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              action,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}