import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/design_system/design_system.dart';
import 'core/routes/app_router.dart';
import 'core/api/weather_service.dart';
import 'core/api/api_config.dart';

void main() {
  // Initialize weather service with API key
  // Note: In a real app, you should store this in environment variables or secure storage
  WeatherService.initialize(
    apiKey: '2b82ccf3fb883f1267530199e5e0d4e6', // Using the provided API key
    environment: Environment.development,
    defaultQueryParameters: {
      'units': 'metric',
      'lang': 'en',
    },
  );

  runApp(
    const ProviderScope(
      child: CelestiaApp(),
    ),
  );
}

class CelestiaApp extends StatelessWidget {
  const CelestiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Celestia Weather',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
