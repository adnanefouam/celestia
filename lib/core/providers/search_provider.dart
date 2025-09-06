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

// Removed static cities - now using API-based search

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  Future<void> searchCities(String query) async {
    if (query.trim().isEmpty || query.trim().length < 2) {
      state = const SearchState();
      return;
    }

    try {
      // Search for cities using OpenWeatherMap Geocoding API
      final locationsResponse =
          await WeatherService.instance.searchLocationsByName(
        query: query,
        limit: 10, // Limit to 10 results for better performance
      );

      if (locationsResponse.isSuccess && locationsResponse.data != null) {
        final locations = locationsResponse.data!;

        if (locations.isEmpty) {
          // No cities found
          state = state.copyWith(
            results: const [],
            isLoading: false,
            error: null,
          );
        } else {
          // Just show the locations without fetching weather data
          final results = locations
              .map((location) => LocationWithWeather(
                    location: location,
                    isLoadingWeather:
                        false, // No weather data needed for search results
                  ))
              .toList();

          state = state.copyWith(
            results: results,
            isLoading: false, // Search is complete, no need to load weather
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error:
              locationsResponse.userFriendlyError ?? 'Failed to search cities',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed: ${e.toString()}',
      );
    }
  }

  // Removed _fetchWeatherForLocations - weather data is now fetched only when user clicks on a city

  void clearSearch() {
    state = const SearchState();
  }

  void setLoadingState(String query) {
    state = state.copyWith(
      isLoading: true,
      query: query,
      error: null,
      results: const [],
    );
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
