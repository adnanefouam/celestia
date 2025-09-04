import 'package:flutter/material.dart';
import '../enums/weather_condition.dart';

class WeatherIcon {
  WeatherIcon._();

  static IconData getIcon(
    WeatherCondition condition, {
    bool isDaytime = true,
    String? iconCode,
  }) {
    if (iconCode != null) {
      return _getIconFromCode(iconCode);
    }

    switch (condition) {
      case WeatherCondition.clear:
        return isDaytime ? Icons.wb_sunny : Icons.brightness_3;
      case WeatherCondition.clouds:
        return _getCloudIcon(isDaytime);
      case WeatherCondition.rain:
        return Icons.grain;
      case WeatherCondition.drizzle:
        return Icons.grain;
      case WeatherCondition.thunderstorm:
        return Icons.thunderstorm;
      case WeatherCondition.snow:
        return Icons.ac_unit;
      case WeatherCondition.mist:
      case WeatherCondition.fog:
        return Icons.foggy;
      case WeatherCondition.smoke:
      case WeatherCondition.haze:
      case WeatherCondition.dust:
      case WeatherCondition.sand:
        return Icons.blur_on;
      case WeatherCondition.ash:
        return Icons.cloud;
      case WeatherCondition.squall:
      case WeatherCondition.tornado:
        return Icons.cyclone;
      case WeatherCondition.unknown:
        return Icons.help_outline;
    }
  }

  static IconData _getIconFromCode(String iconCode) {
    switch (iconCode) {
      case '01d':
        return Icons.wb_sunny;
      case '01n':
        return Icons.brightness_3;
      case '02d':
      case '02n':
        return Icons.wb_cloudy;
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return Icons.cloud;
      case '09d':
      case '09n':
        return Icons.grain;
      case '10d':
        return Icons.wb_cloudy;
      case '10n':
        return Icons.grain;
      case '11d':
      case '11n':
        return Icons.thunderstorm;
      case '13d':
      case '13n':
        return Icons.ac_unit;
      case '50d':
      case '50n':
        return Icons.foggy;
      default:
        return Icons.wb_sunny;
    }
  }

  static IconData _getCloudIcon(bool isDaytime) {
    return isDaytime ? Icons.wb_cloudy : Icons.cloud;
  }

  static Color getIconColor(
    WeatherCondition condition, {
    bool isDaytime = true,
  }) {
    switch (condition) {
      case WeatherCondition.clear:
        return isDaytime ? const Color(0xFFFFA726) : const Color(0xFF5C6BC0);
      case WeatherCondition.clouds:
        return const Color(0xFF78909C);
      case WeatherCondition.rain:
      case WeatherCondition.drizzle:
        return const Color(0xFF42A5F5);
      case WeatherCondition.thunderstorm:
        return const Color(0xFF5C6BC0);
      case WeatherCondition.snow:
        return const Color(0xFF90CAF9);
      case WeatherCondition.mist:
      case WeatherCondition.fog:
      case WeatherCondition.smoke:
      case WeatherCondition.haze:
      case WeatherCondition.dust:
      case WeatherCondition.sand:
      case WeatherCondition.ash:
        return const Color(0xFFBDBDBD);
      case WeatherCondition.squall:
      case WeatherCondition.tornado:
        return const Color(0xFF757575);
      case WeatherCondition.unknown:
        return const Color(0xFF9E9E9E);
    }
  }

  static String getIconUrl(String iconCode, {String size = '2x'}) {
    return 'https://openweathermap.org/img/wn/$iconCode@$size.png';
  }

  static List<String> getSupportedSizes() {
    return ['1x', '2x', '4x'];
  }

  static bool isNightIcon(String iconCode) {
    return iconCode.endsWith('n');
  }

  static bool isDayIcon(String iconCode) {
    return iconCode.endsWith('d');
  }

  static String getIconDescription(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return 'Clear sky';
      case WeatherCondition.clouds:
        return 'Cloudy';
      case WeatherCondition.rain:
        return 'Rain';
      case WeatherCondition.drizzle:
        return 'Light rain';
      case WeatherCondition.thunderstorm:
        return 'Thunderstorm';
      case WeatherCondition.snow:
        return 'Snow';
      case WeatherCondition.mist:
        return 'Mist';
      case WeatherCondition.fog:
        return 'Fog';
      case WeatherCondition.smoke:
        return 'Smoke';
      case WeatherCondition.haze:
        return 'Haze';
      case WeatherCondition.dust:
        return 'Dust';
      case WeatherCondition.sand:
        return 'Sand';
      case WeatherCondition.ash:
        return 'Volcanic ash';
      case WeatherCondition.squall:
        return 'Squalls';
      case WeatherCondition.tornado:
        return 'Tornado';
      case WeatherCondition.unknown:
        return 'Unknown';
    }
  }

  static Widget buildWeatherIcon(
    WeatherCondition condition, {
    bool isDaytime = true,
    String? iconCode,
    double size = 24.0,
    Color? color,
  }) {
    final iconData =
        getIcon(condition, isDaytime: isDaytime, iconCode: iconCode);
    final iconColor = color ?? getIconColor(condition, isDaytime: isDaytime);

    return Icon(
      iconData,
      size: size,
      color: iconColor,
    );
  }

  static Widget buildNetworkWeatherIcon(
    String iconCode, {
    double size = 48.0,
    String iconSize = '2x',
  }) {
    return Image.network(
      getIconUrl(iconCode, size: iconSize),
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          _getIconFromCode(iconCode),
          size: size,
          color: Colors.grey,
        );
      },
    );
  }
}
