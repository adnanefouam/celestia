import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/location.dart';
import '../models/weather_data.dart';
import '../api/weather_service.dart';
import '../api/api_response.dart';

class SearchState {
  final List<LocationWithWeather> results;
  final bool isLoading;
  final String? error;
  final String query;

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
  });

  SearchState copyWith({
    List<LocationWithWeather>? results,
    bool? isLoading,
    String? error,
    String? query,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      query: query ?? this.query,
    );
  }
}

class LocationWithWeather {
  final Location location;
  final WeatherData? weather;
  final bool isLoadingWeather;

  const LocationWithWeather({
    required this.location,
    this.weather,
    this.isLoadingWeather = false,
  });

  LocationWithWeather copyWith({
    Location? location,
    WeatherData? weather,
    bool? isLoadingWeather,
  }) {
    return LocationWithWeather(
      location: location ?? this.location,
      weather: weather ?? this.weather,
      isLoadingWeather: isLoadingWeather ?? this.isLoadingWeather,
    );
  }
}

const List<Location> majorCities = [
  Location(name: 'Paris', lat: 48.8566, lon: 2.3522, country: 'France'),
  Location(
      name: 'London', lat: 51.5074, lon: -0.1278, country: 'United Kingdom'),
  Location(
      name: 'New York', lat: 40.7128, lon: -74.0060, country: 'United States'),
  Location(name: 'Tokyo', lat: 35.6762, lon: 139.6503, country: 'Japan'),
  Location(name: 'Hong Kong', lat: 22.3193, lon: 114.1694, country: 'China'),
  Location(name: 'Brussels', lat: 50.8503, lon: 4.3517, country: 'Belgium'),
  Location(name: 'Berlin', lat: 52.5200, lon: 13.4050, country: 'Germany'),
  Location(name: 'Sydney', lat: -33.8688, lon: 151.2093, country: 'Australia'),
  Location(
      name: 'Dubai',
      lat: 25.2048,
      lon: 55.2708,
      country: 'United Arab Emirates'),
  Location(name: 'São Paulo', lat: -23.5505, lon: -46.6333, country: 'Brazil'),
  Location(name: 'Mumbai', lat: 19.0760, lon: 72.8777, country: 'India'),
  Location(
      name: 'Los Angeles',
      lat: 34.0522,
      lon: -118.2437,
      country: 'United States'),
  Location(name: 'Singapore', lat: 1.3521, lon: 103.8198, country: 'Singapore'),
  Location(name: 'Barcelona', lat: 41.3851, lon: 2.1734, country: 'Spain'),
  Location(name: 'Toronto', lat: 43.6532, lon: -79.3832, country: 'Canada'),
];

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  Future<void> searchCities(String query) async {
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      query: query,
      error: null,
    );

    try {
      final filteredCities = majorCities
          .where((city) =>
              city.name.toLowerCase().contains(query.toLowerCase()) ||
              (city.country?.toLowerCase().contains(query.toLowerCase()) ??
                  false))
          .toList();

      final initialResults = filteredCities
          .map((location) => LocationWithWeather(
                location: location,
                isLoadingWeather: true,
              ))
          .toList();

      state = state.copyWith(
        results: initialResults,
        isLoading: true,
      );
      await _fetchWeatherForLocations(filteredCities);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed: ${e.toString()}',
      );
    }
  }

  Future<void> _fetchWeatherForLocations(List<Location> locations) async {
    for (int i = 0; i < locations.length; i++) {
      final location = locations[i];

      try {
        final weatherResponse =
            await WeatherService.instance.getCurrentWeatherByCoordinates(
          lat: location.lat,
          lon: location.lon,
        );

        if (weatherResponse.isSuccess && weatherResponse.data != null) {
          final updatedResults = List<LocationWithWeather>.from(state.results);
          if (i < updatedResults.length) {
            updatedResults[i] = updatedResults[i].copyWith(
              weather: weatherResponse.data,
              isLoadingWeather: false,
            );
            state = state.copyWith(results: updatedResults);
          }
        } else {
          final updatedResults = List<LocationWithWeather>.from(state.results);
          if (i < updatedResults.length) {
            updatedResults[i] = updatedResults[i].copyWith(
              isLoadingWeather: false,
            );
            state = state.copyWith(results: updatedResults);
          }
        }
      } catch (e) {
        final updatedResults = List<LocationWithWeather>.from(state.results);
        if (i < updatedResults.length) {
          updatedResults[i] = updatedResults[i].copyWith(
            isLoadingWeather: false,
          );
          state = state.copyWith(results: updatedResults);
        }
        print('Error fetching weather for ${location.name}: $e');
      }

      await Future.delayed(const Duration(milliseconds: 200));
    }

    state = state.copyWith(isLoading: false);
  }

  void clearSearch() {
    state = const SearchState();
  }

  void selectLocation(LocationWithWeather locationWithWeather) {
    print(
        'Selected: ${locationWithWeather.location.name}, ${locationWithWeather.location.country}');
    if (locationWithWeather.weather != null) {
      print(
          'Weather: ${locationWithWeather.weather!.currentTemp}°C, ${locationWithWeather.weather!.description}');
    }
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(),
);

final hasSearchResultsProvider = Provider<bool>((ref) {
  final searchState = ref.watch(searchProvider);
  return searchState.results.isNotEmpty;
});

final isLoadingWeatherProvider = Provider<bool>((ref) {
  final searchState = ref.watch(searchProvider);
  return searchState.results.any((result) => result.isLoadingWeather);
});
