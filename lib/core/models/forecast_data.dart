import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../enums/weather_condition.dart';
import 'weather_data.dart';

part 'forecast_data.g.dart';

@JsonSerializable()
class ForecastData extends Equatable {
  @JsonKey(name: 'list')
  final List<HourlyForecast> forecasts;
  final CityInfo city;

  const ForecastData({
    required this.forecasts,
    required this.city,
  });

  factory ForecastData.fromJson(Map<String, dynamic> json) =>
      _$ForecastDataFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastDataToJson(this);

  @override
  List<Object?> get props => [forecasts, city];

  // Get next 24 hours of forecasts (5-day forecast with 3-hour intervals = 40 entries)
  List<HourlyForecast> get next24Hours {
    final now = DateTime.now();
    final cutoff = now.add(const Duration(hours: 24));
    return forecasts
        .where((forecast) => forecast.dateTime.isBefore(cutoff))
        .take(8) // 8 x 3 hours = 24 hours
        .toList();
  }
}

// Simplified hourly forecast from OpenWeatherMap 5-day forecast
@JsonSerializable()
class HourlyForecast extends Equatable {
  @JsonKey(name: 'dt')
  final int timestamp;
  @JsonKey(name: 'main')
  final TemperatureData temperature;
  @JsonKey(name: 'weather')
  final List<WeatherInfo> weather;
  @JsonKey(name: 'rain')
  final PrecipitationData? rain;
  @JsonKey(name: 'pop')
  final double? probabilityOfPrecipitation;

  const HourlyForecast({
    required this.timestamp,
    required this.temperature,
    required this.weather,
    this.rain,
    this.probabilityOfPrecipitation,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) =>
      _$HourlyForecastFromJson(json);

  Map<String, dynamic> toJson() => _$HourlyForecastToJson(this);

  @override
  List<Object?> get props =>
      [timestamp, temperature, weather, rain, probabilityOfPrecipitation];

  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  int get temp => temperature.temp.round();
  WeatherInfo get weatherInfo => weather.first;
  String get icon => weatherInfo.icon;
  WeatherCondition get condition => weatherInfo.condition;
}

// City info from OpenWeatherMap forecast response
@JsonSerializable()
class CityInfo extends Equatable {
  final int id;
  final String name;
  final String country;
  @JsonKey(name: 'coord')
  final Coordinates coordinates;

  const CityInfo({
    required this.id,
    required this.name,
    required this.country,
    required this.coordinates,
  });

  factory CityInfo.fromJson(Map<String, dynamic> json) =>
      _$CityInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CityInfoToJson(this);

  @override
  List<Object?> get props => [id, name, country, coordinates];

  String get fullName => '$name, $country';
}

// Coordinates from OpenWeatherMap
@JsonSerializable()
class Coordinates extends Equatable {
  @JsonKey(name: 'lat')
  final double latitude;
  @JsonKey(name: 'lon')
  final double longitude;

  const Coordinates({
    required this.latitude,
    required this.longitude,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesFromJson(json);

  Map<String, dynamic> toJson() => _$CoordinatesToJson(this);

  @override
  List<Object?> get props => [latitude, longitude];
}

// Precipitation data from OpenWeatherMap "rain" object
@JsonSerializable()
class PrecipitationData extends Equatable {
  @JsonKey(name: '1h')
  final double? oneHour;
  @JsonKey(name: '3h')
  final double? threeHour;

  const PrecipitationData({
    this.oneHour,
    this.threeHour,
  });

  factory PrecipitationData.fromJson(Map<String, dynamic> json) =>
      _$PrecipitationDataFromJson(json);

  Map<String, dynamic> toJson() => _$PrecipitationDataToJson(this);

  @override
  List<Object?> get props => [oneHour, threeHour];

  // Get the most relevant precipitation value
  double get precipitation {
    return oneHour ?? threeHour ?? 0.0;
  }
}
