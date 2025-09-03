import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const String _primaryFontFamily = 'BrittiSansVariable';
  static const String _displayFontFamily = 'Recoletta';
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _displayFontFamily,
    fontSize: 32,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _displayFontFamily,
    fontSize: 28,
    fontWeight: bold,
    height: 1.25,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: _displayFontFamily,
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 22,
    fontWeight: semiBold,
    height: 1.27,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 20,
    fontWeight: medium,
    height: 1.3,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 18,
    fontWeight: medium,
    height: 1.33,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 14,
    fontWeight: medium,
    height: 1.43,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 12,
    fontWeight: medium,
    height: 1.33,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 14,
    fontWeight: regular,
    height: 1.43,
    letterSpacing: 0.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 12,
    fontWeight: regular,
    height: 1.33,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 14,
    fontWeight: medium,
    height: 1.43,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 12,
    fontWeight: medium,
    height: 1.33,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 10,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.textTertiary,
  );

  static const TextStyle temperatureLarge = TextStyle(
    fontFamily: _displayFontFamily,
    fontSize: 72,
    fontWeight: bold,
    height: 1,
    letterSpacing: -2,
    color: AppColors.textPrimary,
  );

  static const TextStyle temperatureMedium = TextStyle(
    fontFamily: _displayFontFamily,
    fontSize: 48,
    fontWeight: semiBold,
    height: 1,
    letterSpacing: -1,
    color: AppColors.textPrimary,
  );

  static const TextStyle temperatureSmall = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle locationTitle = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.25,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle weatherCondition = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 18,
    fontWeight: medium,
    height: 1.33,
    letterSpacing: 0.15,
    color: AppColors.textSecondary,
  );

  static const TextStyle weatherDetail = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 14,
    fontWeight: regular,
    height: 1.43,
    letterSpacing: 0.25,
    color: AppColors.textSecondary,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.25,
    letterSpacing: 0.1,
    color: AppColors.backgroundPrimary,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 14,
    fontWeight: medium,
    height: 1.43,
    letterSpacing: 0.1,
    color: AppColors.backgroundPrimary,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 12,
    fontWeight: medium,
    height: 1.33,
    letterSpacing: 0.5,
    color: AppColors.backgroundPrimary,
  );
}
