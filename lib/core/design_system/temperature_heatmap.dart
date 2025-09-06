import 'package:flutter/material.dart';
import 'package:celestia/core/design_system/app_colors.dart';
import 'package:celestia/core/design_system/app_spacing.dart';
import 'package:celestia/core/design_system/app_typography.dart';
import 'package:celestia/core/models/forecast_data.dart';

class TemperatureHeatmap extends StatelessWidget {
  final List<HourlyForecast> forecasts;

  const TemperatureHeatmap({
    super.key,
    required this.forecasts,
  });

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'No temperature data available',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    // Get temperature range for color mapping
    final temps = forecasts.map((f) => f.temp).toList();
    final minTemp = temps.reduce((a, b) => a < b ? a : b);
    final maxTemp = temps.reduce((a, b) => a > b ? a : b);
    final tempRange = maxTemp - minTemp;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.thermostat,
                  color: AppColors.primaryOrange,
                  size: 20,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Temperature Heatmap',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Next 24 hours',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Heatmap grid
          Container(
            height: 120,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8, // 8 hours in 24 hours (3-hour intervals)
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemCount: forecasts.length,
              itemBuilder: (context, index) {
                final forecast = forecasts[index];
                final temp = forecast.temp;

                // Calculate color intensity (0.0 to 1.0)
                final intensity =
                    tempRange > 0 ? (temp - minTemp) / tempRange : 0.5;

                // Create color gradient from cool to warm
                final color = Color.lerp(
                      const Color(0xFF2196F3), // Cool blue
                      const Color(0xFFFF5722), // Warm orange
                      intensity,
                    ) ??
                    const Color(0xFF2196F3);

                return Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${temp}°',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        _formatTime(forecast.dateTime),
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: AppSpacing.sm),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    '${minTemp}°',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                'Temperature Range',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${maxTemp}°',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5722),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour == 0) return '12a';
    if (hour < 12) return '${hour}a';
    if (hour == 12) return '12p';
    return '${hour - 12}p';
  }
}
