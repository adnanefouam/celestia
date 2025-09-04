import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/design_system/design_system.dart';
import 'core/routes/app_router.dart';

void main() {
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
