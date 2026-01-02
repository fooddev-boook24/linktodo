import 'package:flutter/material.dart';

class AppTheme {
  // カラーパレット
  static const Color primary = Color(0xFFFF8C00);
  static const Color primaryDark = Color(0xFFFF6B00);
  static const Color primaryLight = Color(0xFFFFE4CC);
  static const Color primaryBackground = Color(0xFFFFF5E6);

  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textHint = Color(0xFFBBBBBB);

  static const Color border = Color(0xFFF0F0F0);
  static const Color divider = Color(0xFFF5F5F5);

  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFF8C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color success = Color(0xFF4CAF50);

  // グラデーション
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'NotoSansJP',

      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        surface: surface,
        error: error,
      ),

      scaffoldBackgroundColor: background,

      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),

      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: border, width: 2),
          textStyle: const TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          fontFamily: 'NotoSansJP',
          color: textHint,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'NotoSansJP',
          color: textSecondary,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      dialogTheme: DialogTheme(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primaryLight,
        labelStyle: const TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: border, width: 2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.4,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.4,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontFamily: 'NotoSansJP',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
      ),
    );
  }
}