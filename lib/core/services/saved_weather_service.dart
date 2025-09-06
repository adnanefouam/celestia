import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:celestia/core/models/location.dart';

class SavedWeatherService {
  static const String _savedCitiesKey = 'saved_weather_cities';

  // Save a city location (only lat/lng and name for display)
  static Future<void> saveWeatherCity(Location location) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCities = await getSavedWeatherCities();

    // Create a unique key for this city
    final cityKey = '${location.lat}_${location.lon}';

    // Create saved city data (only location info)
    final savedCity = {
      'name': location.name,
      'country': location.country,
      'lat': location.lat,
      'lon': location.lon,
      'savedAt': DateTime.now().millisecondsSinceEpoch,
    };

    savedCities[cityKey] = savedCity;

    // Save to shared preferences
    await prefs.setString(_savedCitiesKey, jsonEncode(savedCities));
  }

  // Remove a saved weather city
  static Future<void> removeWeatherCity(Location location) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCities = await getSavedWeatherCities();

    final cityKey = '${location.lat}_${location.lon}';
    savedCities.remove(cityKey);

    await prefs.setString(_savedCitiesKey, jsonEncode(savedCities));
  }

  // Remove a saved weather city by key
  static Future<void> removeSavedWeatherCity(String cityKey) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCities = await getSavedWeatherCities();

    savedCities.remove(cityKey);

    await prefs.setString(_savedCitiesKey, jsonEncode(savedCities));
  }

  // Get all saved weather cities
  static Future<Map<String, dynamic>> getSavedWeatherCities() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCitiesJson = prefs.getString(_savedCitiesKey);

    if (savedCitiesJson == null) {
      return {};
    }

    try {
      return Map<String, dynamic>.from(jsonDecode(savedCitiesJson));
    } catch (e) {
      return {};
    }
  }

  // Check if a city is saved
  static Future<bool> isCitySaved(Location location) async {
    final savedCities = await getSavedWeatherCities();
    final cityKey = '${location.lat}_${location.lon}';
    return savedCities.containsKey(cityKey);
  }

  // Get saved location data for a specific location
  static Future<Map<String, dynamic>?> getSavedLocationData(
      Location location) async {
    final savedCities = await getSavedWeatherCities();
    final cityKey = '${location.lat}_${location.lon}';
    return savedCities[cityKey];
  }

  // Get all saved locations as Location objects
  static Future<List<Location>> getSavedLocations() async {
    final savedCities = await getSavedWeatherCities();
    final locations = <Location>[];

    for (final cityData in savedCities.values) {
      locations.add(Location(
        name: cityData['name'] ?? '',
        country: cityData['country'] ?? '',
        lat: cityData['lat']?.toDouble() ?? 0.0,
        lon: cityData['lon']?.toDouble() ?? 0.0,
      ));
    }

    return locations;
  }

  // Clear all saved cities
  static Future<void> clearAllSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedCitiesKey);
  }
}
