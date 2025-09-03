import 'package:flutter/material.dart';
import '../core/design_system/design_system.dart';
import 'weather_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundSecondary,
              AppColors.backgroundPrimary,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: AppSpacing.paddingXL,
            child: Column(
              children: [
                const Spacer(flex: 2),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    gradient: AppColors.temperatureGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wb_sunny,
                    size: 48,
                    color: AppColors.backgroundPrimary,
                  ),
                ),
                AppSpacing.gapVerticalXXL,
                Text(
                  'Welcome to',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                AppSpacing.gapVerticalSM,
                Text(
                  'Celestia',
                  style: AppTypography.displayLarge.copyWith(
                    foreground: Paint()
                      ..shader = AppColors.temperatureGradient.createShader(
                        const Rect.fromLTWH(0, 0, 200, 70),
                      ),
                  ),
                ),
                AppSpacing.gapVerticalXL,
                Text(
                  'Accurate, real-time weather insights to\\nkeep you ahead of the storm.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const Spacer(flex: 2),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final cities = [
                        'Paris',
                        'San Francisco',
                        'New York',
                        'Tokyo'
                      ];
                      final colors = [
                        AppColors.primaryBlue,
                        AppColors.primaryOrange,
                        AppColors.primaryBlueLight,
                        AppColors.primaryOrangeLight,
                      ];

                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: colors[index].withOpacity(0.1),
                          borderRadius: AppRadius.radiusLG,
                          border: Border.all(
                            color: colors[index].withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wb_sunny,
                              color: colors[index],
                              size: 32,
                            ),
                            AppSpacing.gapVerticalSM,
                            Text(
                              cities[index],
                              style: AppTypography.labelMedium.copyWith(
                                color: colors[index],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(flex: 1),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WeatherScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: AppSpacing.paddingVerticalLG,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusLG,
                      ),
                    ),
                    child: Text(
                      'Discover the weather',
                      style: AppTypography.buttonLarge.copyWith(
                        color: AppColors.backgroundPrimary,
                      ),
                    ),
                  ),
                ),
                AppSpacing.gapVerticalMD,
                RichText(
                  text: TextSpan(
                    text: 'Designed & developed with ',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    children: [
                      TextSpan(
                        text: '❤️',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      TextSpan(
                        text: ' by @Fouham Adnane',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapVerticalLG,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
