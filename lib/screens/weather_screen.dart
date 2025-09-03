import 'package:flutter/material.dart';
import '../core/design_system/design_system.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.temperatureGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: AppSpacing.paddingXL,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.backgroundPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.share,
                        color: AppColors.backgroundPrimary,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapVerticalXL,
                Text(
                  'Paris, France',
                  style: AppTypography.locationTitle.copyWith(
                    color: AppColors.backgroundPrimary,
                  ),
                ),
                AppSpacing.gapVerticalXXL,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '20°',
                      style: AppTypography.temperatureLarge.copyWith(
                        color: AppColors.backgroundPrimary,
                      ),
                    ),
                    AppSpacing.gapHorizontalLG,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.wb_cloudy,
                          size: 48,
                          color: AppColors.backgroundPrimary,
                        ),
                        AppSpacing.gapVerticalSM,
                        Text(
                          'Partly Cloudy',
                          style: AppTypography.weatherCondition.copyWith(
                            color: AppColors.backgroundPrimary.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          'H:29° L:15°',
                          style: AppTypography.weatherDetail.copyWith(
                            color: AppColors.backgroundPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                AppSpacing.gapVerticalXXXL,
                Container(
                  width: double.infinity,
                  padding: AppSpacing.paddingLG,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundPrimary.withOpacity(0.2),
                    borderRadius: AppRadius.radiusLG,
                  ),
                  child: Text(
                    'Cloudy conditions from 1AM-9AM, with showers expected at 9AM.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.backgroundPrimary,
                    ),
                  ),
                ),
                AppSpacing.gapVerticalXXL,
                Text(
                  'Hourly Forecast',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.backgroundPrimary,
                  ),
                ),
                AppSpacing.gapVerticalLG,
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final times = ['Now', '10PM', '11PM', '12AM', '1AM'];
                      final temps = ['21°', '21°', '19°', '19°', '19°'];
                      final icons = [
                        Icons.wb_cloudy_outlined,
                        Icons.grain,
                        Icons.grain,
                        Icons.thunderstorm,
                        Icons.grain,
                      ];

                      return Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: AppSpacing.lg),
                        child: Column(
                          children: [
                            Text(
                              times[index],
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.backgroundPrimary
                                    .withOpacity(0.8),
                              ),
                            ),
                            AppSpacing.gapVerticalMD,
                            Icon(
                              icons[index],
                              color: AppColors.backgroundPrimary,
                              size: 24,
                            ),
                            AppSpacing.gapVerticalMD,
                            Text(
                              temps[index],
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.backgroundPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                AppSpacing.gapVerticalXXL,
                Container(
                  padding: AppSpacing.paddingXL,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundPrimary.withOpacity(0.2),
                    borderRadius: AppRadius.radiusLG,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Temperature increase by',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.backgroundPrimary.withOpacity(0.8),
                        ),
                      ),
                      AppSpacing.gapVerticalSM,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '32%',
                            style: AppTypography.displayMedium.copyWith(
                              color: AppColors.backgroundPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppSpacing.gapHorizontalSM,
                          Text(
                            '+0,4%',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
