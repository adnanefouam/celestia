import '../models/weather_data.dart';
import '../models/forecast_data.dart';
import '../models/location.dart';
import 'api_response.dart';
import 'weather_api.dart';
import 'api_config.dart';
import 'endpoints.dart';

class WeatherService {
  late final WeatherApi _weatherApi;
  static WeatherService? _instance;

  WeatherService._({
    required String apiKey,
    Map<String, dynamic>? defaultQueryParameters,
    Map<String, String>? headers,
  }) {
    _weatherApi = WeatherApi(
      apiKey: apiKey,
      defaultQueryParameters: defaultQueryParameters,
      headers: headers,
    );
  }

  static void initialize({
    required String apiKey,
    Environment environment = Environment.development,
    Map<String, dynamic>? defaultQueryParameters,
    Map<String, String>? headers,
  }) {
    EnvironmentConfig.setEnvironment(environment);
    _instance = WeatherService._(
      apiKey: apiKey,
      defaultQueryParameters: defaultQueryParameters,
      headers: headers,
    );
  }

  static WeatherService get instance {
    if (_instance == null) {
      throw Exception(
        'WeatherService not initialized. Call WeatherService.initialize() first.',
      );
    }
    return _instance!;
  }

  // Current weather methods
  Future<ApiResponse<WeatherData>> getCurrentWeatherByCoordinates({
    required double lat,
    required double lon,
    String units = ApiQueryParams.unitsMetric,
    String lang = ApiQueryParams.langEnglish,
  }) {
    return _weatherApi.getCurrentWeather(
      lat: lat,
      lon: lon,
      units: units,
      lang: lang,
    );
  }

  Future<ApiResponse<WeatherData>> getCurrentWeatherByLocation({
    required Location location,
    String units = ApiQueryParams.unitsMetric,
    String lang = ApiQueryParams.langEnglish,
  }) {
    return getCurrentWeatherByCoordinates(
      lat: location.lat,
      lon: location.lon,
      units: units,
      lang: lang,
    );
  }

  // Forecast methods
  Future<ApiResponse<ForecastData>> getDetailedForecast({
    required double lat,
    required double lon,
    String units = ApiQueryParams.unitsMetric,
    String lang = ApiQueryParams.langEnglish,
    List<String> exclude = const [],
  }) {
    return _weatherApi.getOneCallWeather(
      lat: lat,
      lon: lon,
      units: units,
      lang: lang,
      exclude: exclude,
    );
  }

  Future<ApiResponse<ForecastData>> getHourlyForecast({
    required double lat,
    required double lon,
    String units = ApiQueryParams.unitsMetric,
    String lang = ApiQueryParams.langEnglish,
  }) {
    return getDetailedForecast(
      lat: lat,
      lon: lon,
      units: units,
      lang: lang,
      exclude: [
        ApiQueryParams.excludeDaily,
        ApiQueryParams.excludeMinutely,
        ApiQueryParams.excludeAlerts,
      ],
    );
  }

  Future<ApiResponse<ForecastData>> getDailyForecast({
    required double lat,
    required double lon,
    String units = ApiQueryParams.unitsMetric,
    String lang = ApiQueryParams.langEnglish,
  }) {
    return getDetailedForecast(
      lat: lat,
      lon: lon,
      units: units,
      lang: lang,
      exclude: [
        ApiQueryParams.excludeHourly,
        ApiQueryParams.excludeMinutely,
        ApiQueryParams.excludeAlerts,
      ],
    );
  }

  // Location methods
  Future<ApiResponse<List<Location>>> searchLocationsByName({
    required String query,
    int limit = 5,
  }) {
    return _weatherApi.searchLocations(
      query: query,
      limit: limit,
    );
  }

  Future<ApiResponse<List<Location>>> getLocationByCoordinates({
    required double lat,
    required double lon,
    int limit = 1,
  }) {
    return _weatherApi.reverseGeocode(
      lat: lat,
      lon: lon,
      limit: limit,
    );
  }

  Future<ApiResponse<List<Location>>> getLocationByZipCode({
    required String zipCode,
    String? countryCode,
  }) {
    return _weatherApi.geocodeByZip(
      zipCode: zipCode,
      countryCode: countryCode,
    );
  }

  // Historical weather
  Future<ApiResponse<WeatherData>> getHistoricalWeather({
    required double lat,
    required double lon,
    required DateTime timestamp,
    String units = ApiQueryParams.unitsMetric,
    String lang = ApiQueryParams.langEnglish,
  }) {
    return _weatherApi.getHistoricalWeather(
      lat: lat,
      lon: lon,
      timestamp: timestamp,
      units: units,
      lang: lang,
    );
  }

  // Utility methods
  String getWeatherIconUrl(String iconCode, {String size = '2x'}) {
    return _weatherApi.getIconUrl(iconCode, size: size);
  }

  String getMapTileUrl(String layer, int zoom, int x, int y) {
    return _weatherApi.getMapTileUrl(layer, zoom, x, y);
  }

  // Convenience methods for popular locations
  Future<ApiResponse<WeatherData>> getWeatherForParis() {
    return getCurrentWeatherByCoordinates(lat: 48.8566, lon: 2.3522);
  }

  Future<ApiResponse<WeatherData>> getWeatherForNewYork() {
    return getCurrentWeatherByCoordinates(lat: 40.7128, lon: -74.0060);
  }

  Future<ApiResponse<WeatherData>> getWeatherForLondon() {
    return getCurrentWeatherByCoordinates(lat: 51.5074, lon: -0.1278);
  }

  Future<ApiResponse<WeatherData>> getWeatherForTokyo() {
    return getCurrentWeatherByCoordinates(lat: 35.6762, lon: 139.6503);
  }

  // Cleanup
  void dispose() {
    _weatherApi.dispose();
  }

  void cancelAllRequests([String? reason]) {
    _weatherApi.cancelRequests(reason);
  }
}
