import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/welcome_screen.dart';
import '../../screens/weather_screen.dart';
import '../../screens/weather_details_screen.dart';
import '../../core/providers/providers.dart';

enum Routes {
  welcome,
  weather,
  weatherDetails;

  static List<Routes> get authRoutes => [
        // No auth routes for this simple weather app
      ];

  static List<Routes> get shellRoutes => [
        ...Routes.values
            .where((element) => !authRoutes.contains(element))
            .toList(),
      ];

  static Map<Routes, Function(BuildContext, GoRouterState)> get _builder => {
        Routes.welcome: (context, state) => const WelcomeScreen(),
        Routes.weather: (context, state) => const WeatherScreen(),
        Routes.weatherDetails: (context, state) {
          final locationWithWeather = state.extra as LocationWithWeather;
          return WeatherDetailsScreen(locationWithWeather: locationWithWeather);
        },
      };

  static Map<Routes, String> _routes = {
    Routes.welcome: '/',
    Routes.weather: '/weather',
    Routes.weatherDetails: '/weather-details',
  };

  static String getRoute(Routes route) {
    return _routes[route] ?? '/';
  }

  static Routes getRouteByName(String name) {
    if (!_routes.entries.any((element) => element.value == name)) {
      return Routes.welcome;
    }
    return _routes.entries.firstWhere((element) => element.value == name).key;
  }

  bool get isRequiredAuth {
    // No auth required for this simple weather app
    return false;
  }

  Widget build(BuildContext context, GoRouterState state) {
    return _builder[this]!(context, state);
  }

  String get route => Routes.getRoute(this);

  String get routeName {
    final route = this.route;
    return route.split(':').first;
  }
}
