import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      cardTheme: _cardTheme,
      chipTheme: _chipTheme,
      inputDecorationTheme: _inputDecorationTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      tabBarTheme: _tabBarTheme,
      dividerTheme: _dividerTheme,
      scaffoldBackgroundColor: AppColors.backgroundPrimary,
      splashColor: AppColors.primaryBlue.withOpacity(0.1),
      highlightColor: AppColors.primaryBlue.withOpacity(0.05),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      textTheme: _textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
    );
  }

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryBlue,
    onPrimary: AppColors.backgroundPrimary,
    secondary: AppColors.primaryOrange,
    onSecondary: AppColors.backgroundPrimary,
    tertiary: AppColors.primaryOrangeLight,
    onTertiary: AppColors.backgroundPrimary,
    error: AppColors.error,
    onError: AppColors.backgroundPrimary,
    surface: AppColors.backgroundPrimary,
    onSurface: AppColors.textPrimary,
    background: AppColors.backgroundPrimary,
    onBackground: AppColors.textPrimary,
    surfaceVariant: AppColors.backgroundSecondary,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.cardShadow,
    outlineVariant: AppColors.backgroundTertiary,
    shadow: AppColors.cardShadow,
    scrim: Color(0x800F172A),
    inverseSurface: AppColors.textPrimary,
    onInverseSurface: AppColors.backgroundPrimary,
    inversePrimary: AppColors.primaryBlueLight,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryBlueLight,
    onPrimary: Color(0xFF0F172A),
    secondary: AppColors.primaryOrangeLight,
    onSecondary: Color(0xFF0F172A),
    tertiary: AppColors.primaryOrange,
    onTertiary: Color(0xFF0F172A),
    error: AppColors.error,
    onError: Color(0xFF0F172A),
    surface: Color(0xFF0F172A),
    onSurface: Colors.white,
    background: Color(0xFF0F172A),
    onBackground: Colors.white,
    surfaceVariant: Color(0xFF1E293B),
    onSurfaceVariant: Color(0xFF94A3B8),
    outline: Color(0xFF475569),
    outlineVariant: Color(0xFF334155),
    shadow: Colors.black,
    scrim: Color(0x80000000),
    inverseSurface: Colors.white,
    onInverseSurface: Color(0xFF0F172A),
    inversePrimary: AppColors.primaryBlue,
  );

  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: AppTypography.displayLarge,
      displayMedium: AppTypography.displayMedium,
      displaySmall: AppTypography.displaySmall,
      headlineLarge: AppTypography.headlineLarge,
      headlineMedium: AppTypography.headlineMedium,
      headlineSmall: AppTypography.headlineSmall,
      titleLarge: AppTypography.titleLarge,
      titleMedium: AppTypography.titleMedium,
      titleSmall: AppTypography.titleSmall,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,
      labelLarge: AppTypography.labelLarge,
      labelMedium: AppTypography.labelMedium,
      labelSmall: AppTypography.labelSmall,
    );
  }

  static AppBarTheme get _appBarTheme {
    return AppBarTheme(
      backgroundColor: AppColors.backgroundPrimary,
      foregroundColor: AppColors.textPrimary,
      elevation: AppElevation.none,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: AppTypography.headlineMedium,
      toolbarTextStyle: AppTypography.bodyMedium,
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.backgroundPrimary,
        elevation: AppElevation.sm,
        shadowColor: AppColors.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLG,
        ),
        padding:
            AppSpacing.paddingHorizontalXL.add(AppSpacing.paddingVerticalMD),
        textStyle: AppTypography.buttonMedium,
        minimumSize: const Size(64, 40),
      ),
    );
  }

  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLG,
        ),
        padding:
            AppSpacing.paddingHorizontalXL.add(AppSpacing.paddingVerticalMD),
        textStyle: AppTypography.buttonMedium,
        minimumSize: const Size(64, 40),
      ),
    );
  }

  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        padding:
            AppSpacing.paddingHorizontalLG.add(AppSpacing.paddingVerticalSM),
        textStyle: AppTypography.buttonMedium,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLG,
        ),
      ),
    );
  }

  static CardTheme get _cardTheme {
    return CardTheme(
      color: AppColors.cardBackground,
      shadowColor: AppColors.cardShadow,
      elevation: AppElevation.sm,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLG,
      ),
      margin: AppSpacing.marginMD,
    );
  }

  static ChipThemeData get _chipTheme {
    return ChipThemeData(
      backgroundColor: AppColors.backgroundSecondary,
      selectedColor: AppColors.primaryBlue,
      disabledColor: AppColors.backgroundTertiary,
      labelStyle: AppTypography.labelMedium,
      secondaryLabelStyle: AppTypography.labelMedium.copyWith(
        color: AppColors.backgroundPrimary,
      ),
      padding: AppSpacing.paddingHorizontalMD.add(AppSpacing.paddingVerticalXS),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusXXL,
      ),
    );
  }

  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundSecondary,
      border: OutlineInputBorder(
        borderRadius: AppRadius.radiusLG,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusLG,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusLG,
        borderSide: const BorderSide(
          color: AppColors.primaryBlue,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusLG,
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusLG,
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      contentPadding: AppSpacing.paddingLG,
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textTertiary,
      ),
      labelStyle: AppTypography.labelLarge.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  static BottomNavigationBarThemeData get _bottomNavigationBarTheme {
    return BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundPrimary,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: AppElevation.md,
      selectedLabelStyle: AppTypography.labelSmall,
      unselectedLabelStyle: AppTypography.labelSmall,
    );
  }

  static TabBarTheme get _tabBarTheme {
    return TabBarTheme(
      labelColor: AppColors.primaryBlue,
      unselectedLabelColor: AppColors.textTertiary,
      indicatorColor: AppColors.primaryBlue,
      labelStyle: AppTypography.labelLarge,
      unselectedLabelStyle: AppTypography.labelLarge,
      indicatorSize: TabBarIndicatorSize.tab,
    );
  }

  static DividerThemeData get _dividerTheme {
    return const DividerThemeData(
      color: AppColors.backgroundTertiary,
      thickness: 1,
      space: 1,
    );
  }
}
