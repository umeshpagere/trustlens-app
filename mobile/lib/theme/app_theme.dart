import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF667EEA);
  static const Color primaryDark = Color(0xFF764BA2);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const Color riskLow = Color(0xFF059669);
  static const Color riskLowBg = Color(0xFFD1FAE5);
  static const Color riskMedium = Color(0xFFF59E0B);
  static const Color riskMediumBg = Color(0xFFFEF3C7);
  static const Color riskHigh = Color(0xFFDC2626);
  static const Color riskHighBg = Color(0xFFFEE2E2);

  static const Color aiPurple = Color(0xFF6366F1);

  static Color riskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
        return riskLow;
      case 'high':
        return riskHigh;
      default:
        return riskMedium;
    }
  }

  static Color riskBgColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
        return riskLowBg;
      case 'high':
        return riskHighBg;
      default:
        return riskMediumBg;
    }
  }
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: '.SF Pro Text',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          foregroundColor: AppColors.textPrimary,
        ),
      );
}
