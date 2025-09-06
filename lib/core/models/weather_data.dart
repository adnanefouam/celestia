import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../enums/weather_condition.dart';
import 'location.dart';

part 'weather_data.g.dart';

@JsonSerializable()
class WeatherData extends Equatable {
  final Location location;
  @JsonKey(name: 'main')
  final TemperatureData temperature;
  @JsonKey(name: 'weather')
  final List<WeatherInfo> weather;
  @JsonKey(name: 'wind')
  final WindData? wind;
  @JsonKey(name: 'dt')
  final int timestamp;

  const WeatherData({
    required this.location,
    required this.temperature,
    required this.weather,
    this.wind,
    required this.timestamp,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) =>
      _$WeatherDataFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherDataToJson(this);

  @override
  List<Object?> get props => [
        location,
        temperature,
        weather,
        wind,
        timestamp,
      ];

  WeatherData copyWith({
    Location? location,
    TemperatureData? temperature,
    List<WeatherInfo>? weather,
    WindData? wind,
    int? timestamp,
  }) {
    return WeatherData(
      location: location ?? this.location,
      temperature: temperature ?? this.temperature,
      weather: weather ?? this.weather,
      wind: wind ?? this.wind,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Convenient getters for UI
  int get currentTemp => temperature.temp.round();
  int get minTemp => temperature.tempMin.round();
  int get maxTemp => temperature.tempMax.round();

  String get temperatureRange => '$maxTemp°/$minTemp°';

  WeatherInfo get currentWeather => weather.first;
  String get description => currentWeather.description;
  String get icon => currentWeather.icon;
  WeatherCondition get condition => currentWeather.condition;

  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
}

// Temperature data from OpenWeatherMap "main" object
@JsonSerializable()
class TemperatureData extends Equatable {
  final double temp;
  @JsonKey(name: 'feels_like')
  final double feelsLike;
  @JsonKey(name: 'temp_min')
  final double tempMin;
  @JsonKey(name: 'temp_max')
  final double tempMax;

  const TemperatureData({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
  });

  factory TemperatureData.fromJson(Map<String, dynamic> json) =>
      _$TemperatureDataFromJson(json);

  Map<String, dynamic> toJson() => _$TemperatureDataToJson(this);

  @override
  List<Object?> get props => [temp, feelsLike, tempMin, tempMax];
}

// Weather info from OpenWeatherMap "weather" array
@JsonSerializable()
class WeatherInfo extends Equatable {
  final int id;
  final String main;
  final String description;
  final String icon;

  const WeatherInfo({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) =>
      _$WeatherInfoFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherInfoToJson(this);

  @override
  List<Object?> get props => [id, main, description, icon];

  // Convert to our custom enum
  WeatherCondition get condition => WeatherCondition.fromOpenWeatherMap(id);
}

// Wind data from OpenWeatherMap "wind" object
@JsonSerializable()
class WindData extends Equatable {
  final double speed;
  final int deg;
  final double? gust;

  const WindData({
    required this.speed,
    required this.deg,
    this.gust,
  });

  factory WindData.fromJson(Map<String, dynamic> json) =>
      _$WindDataFromJson(json);

  Map<String, dynamic> toJson() => _$WindDataToJson(this);

  @override
  List<Object?> get props => [speed, deg, gust];

  // Helper methods for UI
  String get direction {
    if (deg >= 337.5 || deg < 22.5) return 'N';
    if (deg >= 22.5 && deg < 67.5) return 'NE';
    if (deg >= 67.5 && deg < 112.5) return 'E';
    if (deg >= 112.5 && deg < 157.5) return 'SE';
    if (deg >= 157.5 && deg < 202.5) return 'S';
    if (deg >= 202.5 && deg < 247.5) return 'SW';
    if (deg >= 247.5 && deg < 292.5) return 'W';
    if (deg >= 292.5 && deg < 337.5) return 'NW';
    return 'N';
  }

  String get speedFormatted => '${speed.toStringAsFixed(1)} m/s';
  String get gustFormatted =>
      gust != null ? '${gust!.toStringAsFixed(1)} m/s' : '';
}
