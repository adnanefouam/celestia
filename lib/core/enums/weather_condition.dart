import 'package:json_annotation/json_annotation.dart';

enum WeatherCondition {
  @JsonValue('clear')
  clear,

  @JsonValue('clouds')
  clouds,

  @JsonValue('rain')
  rain,

  @JsonValue('drizzle')
  drizzle,

  @JsonValue('thunderstorm')
  thunderstorm,

  @JsonValue('snow')
  snow,

  @JsonValue('mist')
  mist,

  @JsonValue('smoke')
  smoke,

  @JsonValue('haze')
  haze,

  @JsonValue('dust')
  dust,

  @JsonValue('fog')
  fog,

  @JsonValue('sand')
  sand,

  @JsonValue('ash')
  ash,

  @JsonValue('squall')
  squall,

  @JsonValue('tornado')
  tornado,

  @JsonValue('unknown')
  unknown;

  static WeatherCondition fromString(String value) {
    switch (value.toLowerCase()) {
      case 'clear':
        return WeatherCondition.clear;
      case 'clouds':
        return WeatherCondition.clouds;
      case 'rain':
        return WeatherCondition.rain;
      case 'drizzle':
        return WeatherCondition.drizzle;
      case 'thunderstorm':
        return WeatherCondition.thunderstorm;
      case 'snow':
        return WeatherCondition.snow;
      case 'mist':
        return WeatherCondition.mist;
      case 'smoke':
        return WeatherCondition.smoke;
      case 'haze':
        return WeatherCondition.haze;
      case 'dust':
        return WeatherCondition.dust;
      case 'fog':
        return WeatherCondition.fog;
      case 'sand':
        return WeatherCondition.sand;
      case 'ash':
        return WeatherCondition.ash;
      case 'squall':
        return WeatherCondition.squall;
      case 'tornado':
        return WeatherCondition.tornado;
      default:
        return WeatherCondition.unknown;
    }
  }

  // Convert OpenWeatherMap condition ID to our enum
  static WeatherCondition fromOpenWeatherMap(int id) {
    if (id >= 200 && id < 300) return WeatherCondition.thunderstorm;
    if (id >= 300 && id < 400) return WeatherCondition.drizzle;
    if (id >= 500 && id < 600) return WeatherCondition.rain;
    if (id >= 600 && id < 700) return WeatherCondition.snow;
    if (id >= 700 && id < 800) {
      switch (id) {
        case 701:
          return WeatherCondition.mist;
        case 711:
          return WeatherCondition.smoke;
        case 721:
          return WeatherCondition.haze;
        case 731:
          return WeatherCondition.dust;
        case 741:
          return WeatherCondition.fog;
        case 751:
          return WeatherCondition.sand;
        case 761:
          return WeatherCondition.dust;
        case 762:
          return WeatherCondition.ash;
        case 771:
          return WeatherCondition.squall;
        case 781:
          return WeatherCondition.tornado;
        default:
          return WeatherCondition.mist;
      }
    }
    if (id == 800) return WeatherCondition.clear;
    if (id > 800 && id < 900) return WeatherCondition.clouds;
    return WeatherCondition.unknown;
  }

  String get displayName {
    switch (this) {
      case WeatherCondition.clear:
        return 'Clear';
      case WeatherCondition.clouds:
        return 'Cloudy';
      case WeatherCondition.rain:
        return 'Rain';
      case WeatherCondition.drizzle:
        return 'Drizzle';
      case WeatherCondition.thunderstorm:
        return 'Thunderstorm';
      case WeatherCondition.snow:
        return 'Snow';
      case WeatherCondition.mist:
        return 'Mist';
      case WeatherCondition.smoke:
        return 'Smoke';
      case WeatherCondition.haze:
        return 'Haze';
      case WeatherCondition.dust:
        return 'Dust';
      case WeatherCondition.fog:
        return 'Fog';
      case WeatherCondition.sand:
        return 'Sand';
      case WeatherCondition.ash:
        return 'Ash';
      case WeatherCondition.squall:
        return 'Squall';
      case WeatherCondition.tornado:
        return 'Tornado';
      case WeatherCondition.unknown:
        return 'Unknown';
    }
  }

  bool get isExtreme {
    return this == WeatherCondition.thunderstorm ||
        this == WeatherCondition.tornado ||
        this == WeatherCondition.squall ||
        this == WeatherCondition.ash;
  }

  bool get isPrecipitation {
    return this == WeatherCondition.rain ||
        this == WeatherCondition.drizzle ||
        this == WeatherCondition.snow ||
        this == WeatherCondition.thunderstorm;
  }
}
