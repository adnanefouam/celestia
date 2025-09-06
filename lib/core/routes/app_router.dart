import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/welcome_screen.dart';
import '../../screens/weather_screen.dart';
import '../../screens/weather_details_screen.dart';
import '../providers/providers.dart';
import '../providers/search_provider.dart';

class AppRouter {
  static const String welcome = '/';
  static const String weather = '/weather';
  static const String weatherDetails = '/weather-details';

  static final GoRouter router = GoRouter(
    initialLocation: welcome,
    debugLogDiagnostics: false, // Reduce debug noise
    routes: [
      GoRoute(
        path: welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: weather,
        name: 'weather',
        builder: (context, state) => const WeatherScreen(),
      ),
      GoRoute(
        path: weatherDetails,
        name: 'weather-details',
        builder: (context, state) {
          final locationWithWeather = state.extra as LocationWithWeather?;

          // If no location data is provided, redirect to weather screen
          if (locationWithWeather == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(weather);
            });
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return WeatherDetailsScreen(locationWithWeather: locationWithWeather);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The requested page could not be found.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(welcome),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
