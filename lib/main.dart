import 'package:flutter/material.dart';
import 'core/design_system/design_system.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const CelestiaApp());
}

class CelestiaApp extends StatelessWidget {
  const CelestiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Celestia Weather',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}
