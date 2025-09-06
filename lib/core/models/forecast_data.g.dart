// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForecastData _$ForecastDataFromJson(Map<String, dynamic> json) => ForecastData(
      forecasts: (json['list'] as List<dynamic>)
          .map((e) => HourlyForecast.fromJson(e as Map<String, dynamic>))
          .toList(),
      city: CityInfo.fromJson(json['city'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ForecastDataToJson(ForecastData instance) =>
    <String, dynamic>{
      'list': instance.forecasts,
      'city': instance.city,
    };

HourlyForecast _$HourlyForecastFromJson(Map<String, dynamic> json) =>
    HourlyForecast(
      timestamp: (json['dt'] as num).toInt(),
      temperature:
          TemperatureData.fromJson(json['main'] as Map<String, dynamic>),
      weather: (json['weather'] as List<dynamic>)
          .map((e) => WeatherInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      rain: json['rain'] == null
          ? null
          : PrecipitationData.fromJson(json['rain'] as Map<String, dynamic>),
      probabilityOfPrecipitation: (json['pop'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$HourlyForecastToJson(HourlyForecast instance) =>
    <String, dynamic>{
      'dt': instance.timestamp,
      'main': instance.temperature,
      'weather': instance.weather,
      'rain': instance.rain,
      'pop': instance.probabilityOfPrecipitation,
    };

CityInfo _$CityInfoFromJson(Map<String, dynamic> json) => CityInfo(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      country: json['country'] as String,
      coordinates: Coordinates.fromJson(json['coord'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CityInfoToJson(CityInfo instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'country': instance.country,
      'coord': instance.coordinates,
    };

Coordinates _$CoordinatesFromJson(Map<String, dynamic> json) => Coordinates(
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lon'] as num).toDouble(),
    );

Map<String, dynamic> _$CoordinatesToJson(Coordinates instance) =>
    <String, dynamic>{
      'lat': instance.latitude,
      'lon': instance.longitude,
    };

PrecipitationData _$PrecipitationDataFromJson(Map<String, dynamic> json) =>
    PrecipitationData(
      oneHour: (json['1h'] as num?)?.toDouble(),
      threeHour: (json['3h'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PrecipitationDataToJson(PrecipitationData instance) =>
    <String, dynamic>{
      '1h': instance.oneHour,
      '3h': instance.threeHour,
    };
