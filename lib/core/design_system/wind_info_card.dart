import 'package:flutter/material.dart';
import 'package:celestia/core/design_system/app_colors.dart';
import 'package:celestia/core/design_system/app_spacing.dart';
import 'package:celestia/core/design_system/app_typography.dart';
import 'package:celestia/core/models/weather_data.dart';

class WindInfoCard extends StatelessWidget {
  final WindData wind;

  const WindInfoCard({
    super.key,
    required this.wind,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.air,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Wind',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // Wind details
          Row(
            children: [
              // Wind speed
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Speed',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      wind.speedFormatted,
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Wind direction
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Direction',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Transform.rotate(
                          angle: (wind.deg * 3.14159) /
                              180, // Convert degrees to radians
                          child: Icon(
                            Icons.navigation,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          wind.direction,
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Wind gust (if available)
              if (wind.gust != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gust',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        wind.gustFormatted,
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
