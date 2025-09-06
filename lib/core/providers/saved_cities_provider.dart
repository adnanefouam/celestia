import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:celestia/core/services/saved_weather_service.dart';
import 'package:celestia/core/models/weather_data.dart';
import 'package:celestia/core/models/location.dart';
import 'package:celestia/core/api/weather_service.dart';
import 'package:celestia/core/api/api_response.dart';

class SavedCitiesState {
  final Map<String, dynamic> cities;
  final Map<String, WeatherData?> weatherData;
  final bool isLoading;

  const SavedCitiesState({
    this.cities = const {},
    this.weatherData = const {},
    this.isLoading = false,
  });

  SavedCitiesState copyWith({
    Map<String, dynamic>? cities,
    Map<String, WeatherData?>? weatherData,
    bool? isLoading,
  }) {
    return SavedCitiesState(
      cities: cities ?? this.cities,
      weatherData: weatherData ?? this.weatherData,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SavedCitiesNotifier extends StateNotifier<SavedCitiesState> {
  SavedCitiesNotifier() : super(const SavedCitiesState()) {
    loadSavedCities();
  }

  Future<void> loadSavedCities() async {
    state = state.copyWith(isLoading: true);

    try {
      final savedCities = await SavedWeatherService.getSavedWeatherCities();
      state = state.copyWith(
        cities: savedCities,
        isLoading: false,
      );

      // Fetch weather data for each saved city
      await _fetchWeatherForSavedCities();
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _fetchWeatherForSavedCities() async {
    final weatherData = <String, WeatherData?>{};

    for (final entry in state.cities.entries) {
      final cityData = entry.value;
      final location = Location(
        name: cityData['name'] ?? '',
        country: cityData['country'] ?? '',
        lat: cityData['lat']?.toDouble() ?? 0.0,
        lon: cityData['lon']?.toDouble() ?? 0.0,
      );

      try {
        final response =
            await WeatherService.instance.getCurrentWeatherByCoordinates(
          lat: location.lat,
          lon: location.lon,
        );

        if (response is ApiSuccess && response.data != null) {
          weatherData[entry.key] = response.data;
        } else {
          weatherData[entry.key] = null;
        }
      } catch (e) {
        weatherData[entry.key] = null;
      }
    }

    state = state.copyWith(weatherData: weatherData);
  }

  Future<void> addSavedCity(Map<String, dynamic> cityData) async {
    // Reload saved cities to get the updated list
    await loadSavedCities();
  }

  Future<void> removeSavedCity(String cityKey) async {
    try {
      await SavedWeatherService.removeSavedWeatherCity(cityKey);

      // Update state by removing the city
      final updatedCities = Map<String, dynamic>.from(state.cities);
      final updatedWeatherData =
          Map<String, WeatherData?>.from(state.weatherData);

      updatedCities.remove(cityKey);
      updatedWeatherData.remove(cityKey);

      state = state.copyWith(
        cities: updatedCities,
        weatherData: updatedWeatherData,
      );
    } catch (e) {
      // Handle error if needed
      rethrow;
    }
  }

  Future<void> refreshWeatherData() async {
    await _fetchWeatherForSavedCities();
  }
}

final savedCitiesProvider =
    StateNotifierProvider<SavedCitiesNotifier, SavedCitiesState>((ref) {
  return SavedCitiesNotifier();
});
