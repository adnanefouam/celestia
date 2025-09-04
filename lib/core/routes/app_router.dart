import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/welcome_screen.dart';
import '../../screens/weather_screen.dart';

class AppRouter {
  static const String welcome = '/';
  static const String weather = '/weather';

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
