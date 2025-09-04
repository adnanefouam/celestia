import '../models/weather_data.dart';
import '../models/forecast_data.dart';
import '../models/location.dart';
import '../http/base_http_client.dart';
import 'api_response.dart';
import 'endpoints.dart';

class WeatherApi {
  final BaseHttpClient _httpClient;
  final String apiKey;

  WeatherApi({
    required this.apiKey,
    BaseHttpClient? httpClient,
    Map<String, dynamic>? defaultQueryParameters,
    Map<String, String>? headers,
  }) : _httpClient = httpClient ??
            _createHttpClient(apiKey, defaultQueryParameters, headers);

  static BaseHttpClient _createHttpClient(
    String apiKey,
    Map<String, dynamic>? defaultQueryParameters,
    Map<String, String>? headers,
  ) {
    return BaseHttpClient.api(
      baseUrl: ApiEndpoints.baseUrl,
      apiKey: apiKey,
      defaultQueryParameters: defaultQueryParameters,
      headers: headers,
    );
  }

  Future<ApiResponse<WeatherData>> getCurrentWeather({
    required double lat,
    required double lon,
    String units = ApiQueryParams.unitsMetric,
    String lang = ApiQueryParams.langEnglish,
  }) async {
    final response = await _httpClient.get<Map<String, dynamic>>(
      ApiEndpoints.currentWeather,
      queryParameters: {
        ApiQueryParams.lat: lat,
        ApiQueryParams.lon: lon,
        ApiQueryParams.units: units,
        ApiQueryParams.lang: lang,
      },
    );

    return response.fold(
      (message, statusCode) => ApiError(
        message: message,
        statusCode: statusCode,
      ),
      (data) {
        try {
          final weatherData = _parseCurrentWeatherResponse(data);
          return ApiSuccess(
            data: weatherData,
            statusCode: response.statusCode,
          );
        } catch (e, stackTrace) {
          return ApiError(
            message: 'Failed to parse weather data: $e',
            originalError: e,
            stackTrace: stackTrace,
          );
        }
      },
    );
  }

  Future<ApiResponse<ForecastData>> getOneCallWeather({
    required double lat,
    required double lon,
    String units = ApiQueryParams.unitsMetric,
    String lang = ApiQueryParams.langEnglish,
    List<String> exclude = const [],
  }) async {
    final queryParams = <String, dynamic>{
      ApiQueryParams.lat: lat,
      ApiQueryParams.lon: lon,
      ApiQueryParams.units: units,
      ApiQueryParams.lang: lang,
    };

    if (exclude.isNotEmpty) {
      queryParams[ApiQueryParams.exclude] = exclude.join(',');
    }

    final response = await _httpClient.get<Map<String, dynamic>>(
      ApiEndpoints.oneCall,
      queryParameters: queryParams,
    );

    return response.fold(
      (message, statusCode) => ApiError(
        message: message,
        statusCode: statusCode,
      ),
      (data) {
        try {
          final forecastData = ForecastData.fromJson(data);
          return ApiSuccess(
            data: forecastData,
            statusCode: response.statusCode,
          );
        } catch (e, stackTrace) {
          return ApiError(
            message: 'Failed to parse forecast data: $e',
            originalError: e,
            stackTrace: stackTrace,
          );
        }
      },
    );
  }

  Future<ApiResponse<List<Location>>> searchLocations({
    required String query,
    int limit = 5,
  }) async {
    final response = await _httpClient.get<List<dynamic>>(
      ApiEndpoints.geocodingDirect,
      queryParameters: {
        ApiQueryParams.query: query,
        ApiQueryParams.limit: limit,
      },
    );

    return response.fold(
      (message, statusCode) => ApiError(
        message: message,
        statusCode: statusCode,
      ),
      (data) {
        try {
          final locations = data
              .map((item) => Location.fromJson(item as Map<String, dynamic>))
              .toList();
          return ApiSuccess(
            data: locations,
            statusCode: response.statusCode,
          );
        } catch (e, stackTrace) {
          return ApiError(
            message: 'Failed to parse locations: $e',
            originalError: e,
            stackTrace: stackTrace,
          );
        }
      },
    );
  }

  Future<ApiResponse<List<Location>>> reverseGeocode({
    required double lat,
    required double lon,
    int limit = 1,
  }) async {
    final response = await _httpClient.get<List<dynamic>>(
      ApiEndpoints.geocodingReverse,
      queryParameters: {
        ApiQueryParams.lat: lat,
        ApiQueryParams.lon: lon,
        ApiQueryParams.limit: limit,
      },
    );

    return response.fold(
      (message, statusCode) => ApiError(
        message: message,
        statusCode: statusCode,
      ),
      (data) {
        try {
          final locations = data
              .map((item) => Location.fromJson(item as Map<String, dynamic>))
              .toList();
          return ApiSuccess(
            data: locations,
            statusCode: response.statusCode,
          );
        } catch (e, stackTrace) {
          return ApiError(
            message: 'Failed to parse locations: $e',
            originalError: e,
            stackTrace: stackTrace,
          );
        }
      },
    );
  }

  Future<ApiResponse<List<Location>>> geocodeByZip({
    required String zipCode,
    String? countryCode,
  }) async {
    final zip = countryCode != null ? '$zipCode,$countryCode' : zipCode;

    final response = await _httpClient.get<Map<String, dynamic>>(
      ApiEndpoints.geocodingZip,
      queryParameters: {
        ApiQueryParams.zipCode: zip,
      },
    );

    return response.fold(
      (message, statusCode) => ApiError(
        message: message,
        statusCode: statusCode,
      ),
      (data) {
        try {
          final location = Location.fromJson(data);
          return ApiSuccess(
            data: [location],
            statusCode: response.statusCode,
          );
        } catch (e, stackTrace) {
          return ApiError(
            message: 'Failed to parse location: $e',
            originalError: e,
            stackTrace: stackTrace,
          );
        }
      },
    );
  }

  Future<ApiResponse<WeatherData>> getHistoricalWeather({
    required double lat,
    required double lon,
    required DateTime timestamp,
    String units = ApiQueryParams.unitsMetric,
    String lang = ApiQueryParams.langEnglish,
  }) async {
    final response = await _httpClient.get<Map<String, dynamic>>(
      ApiEndpoints.oneCallTimestamp,
      queryParameters: {
        ApiQueryParams.lat: lat,
        ApiQueryParams.lon: lon,
        ApiQueryParams.dt: timestamp.millisecondsSinceEpoch ~/ 1000,
        ApiQueryParams.units: units,
        ApiQueryParams.lang: lang,
      },
    );

    return response.fold(
      (message, statusCode) => ApiError(
        message: message,
        statusCode: statusCode,
      ),
      (data) {
        try {
          final weatherData = _parseCurrentWeatherResponse(data['current']);
          return ApiSuccess(
            data: weatherData,
            statusCode: response.statusCode,
          );
        } catch (e, stackTrace) {
          return ApiError(
            message: 'Failed to parse historical weather: $e',
            originalError: e,
            stackTrace: stackTrace,
          );
        }
      },
    );
  }

  WeatherData _parseCurrentWeatherResponse(Map<String, dynamic> data) {
    final location = Location(
      lat: data['coord']['lat'].toDouble(),
      lon: data['coord']['lon'].toDouble(),
      name: data['name'] ?? '',
      country: data['sys']?['country'],
    );

    final main = data['main'];
    final weather = data['weather'][0];

    return WeatherData(
      location: location,
      temperature: TemperatureData(
        temp: main['temp'].toDouble(),
        feelsLike: main['feels_like'].toDouble(),
        tempMin: main['temp_min'].toDouble(),
        tempMax: main['temp_max'].toDouble(),
      ),
      weather: [
        WeatherInfo(
          id: weather['id'],
          main: weather['main'] ?? '',
          description: weather['description'] ?? '',
          icon: weather['icon'] ?? '',
        ),
      ],
      timestamp: data['dt'],
    );
  }

  String getIconUrl(String iconCode, {String size = '2x'}) {
    return ApiEndpoints.getIconUrl(iconCode, size: size);
  }

  String getMapTileUrl(String layer, int zoom, int x, int y) {
    return ApiEndpoints.getMapTileUrl(layer, zoom, x, y, apiKey);
  }

  void cancelRequests([String? reason]) {
    _httpClient.cancelRequests(reason);
  }

  void dispose() {
    _httpClient.dispose();
  }
}
