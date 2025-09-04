import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueLight = Color(0xFF3B82F6);
  static const Color primaryBlueDark = Color(0xFF1D4ED8);

  static const Color primaryOrange = Color(0xFFEA580C);
  static const Color primaryOrangeLight = Color(0xFFFB923C);
  static const Color primaryOrangeDark = Color(0xFFC2410C);

  static const Color temperatureCold = Color(0xFF3B82F6);
  static const Color temperatureWarm = Color(0xFFFB923C);
  static const Color temperatureHot = Color(0xFFDC2626);

  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF8FAFC);
  static const Color backgroundTertiary = Color(0xFFFAF9F7);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);

  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0xFFE2E8F0);

  static const Color sunColor = Color(0xFFFCD34D);
  static const Color cloudColor = Color(0xFFCBD5E1);
  static const Color rainColor = Color(0xFF60A5FA);
  static const Color stormColor = Color(0xFF64748B);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const LinearGradient temperatureGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryBlue,
      primaryOrangeLight,
    ],
  );

  static const LinearGradient sunnyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryOrangeLight,
      primaryOrange,
    ],
  );

  static const LinearGradient cloudyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryBlueLight,
      primaryBlue,
    ],
  );

  static Color getTemperatureColor(double temperature) {
    if (temperature <= 10) {
      return temperatureCold;
    } else if (temperature <= 25) {
      return temperatureWarm;
    } else {
      return temperatureHot;
    }
  }

  static Color getWeatherConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return sunColor;
      case 'cloudy':
      case 'partly cloudy':
        return cloudColor;
      case 'rainy':
      case 'rain':
      case 'showers':
        return rainColor;
      case 'stormy':
      case 'thunderstorm':
        return stormColor;
      default:
        return primaryBlue;
    }
  }
}
