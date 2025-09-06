import 'package:celestia/core/design_system/app_colors.dart';
import 'package:celestia/core/design_system/app_spacing.dart';
import 'package:celestia/core/design_system/app_typography.dart';
import 'package:celestia/core/design_system/wind_info_card.dart';
import 'package:celestia/core/design_system/flutter_map_heatmap.dart';
import 'package:celestia/core/models/weather_data.dart';
import 'package:celestia/core/models/location.dart';
import 'package:celestia/core/models/forecast_data.dart';
import 'package:celestia/core/enums/weather_condition.dart';
import 'package:celestia/core/providers/providers.dart';
import 'package:celestia/core/api/weather_service.dart';
import 'package:celestia/core/api/api_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class WeatherDetailsScreen extends ConsumerStatefulWidget {
  final LocationWithWeather locationWithWeather;

  const WeatherDetailsScreen({
    Key? key,
    required this.locationWithWeather,
  }) : super(key: key);

  @override
  ConsumerState<WeatherDetailsScreen> createState() =>
      _WeatherDetailsScreenState();
}

class _WeatherDetailsScreenState extends ConsumerState<WeatherDetailsScreen> {
  WeatherData? _currentWeather;
  ForecastData? _forecastData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final location = widget.locationWithWeather.location;

      // Fetch current weather if not already available
      if (widget.locationWithWeather.weather == null) {
        final weatherResponse =
            await WeatherService.instance.getCurrentWeatherByCoordinates(
          lat: location.lat,
          lon: location.lon,
        );

        if (weatherResponse.isSuccess && weatherResponse.data != null) {
          _currentWeather = weatherResponse.data;
        }
      } else {
        _currentWeather = widget.locationWithWeather.weather;
      }

      // Fetch forecast data for hourly and daily forecasts
      final forecastResponse =
          await WeatherService.instance.getDetailedForecast(
        lat: location.lat,
        lon: location.lon,
      );

      if (forecastResponse.isSuccess && forecastResponse.data != null) {
        _forecastData = forecastResponse.data;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_currentWeather == null) {
      return _buildNoDataState();
    }

    return _buildWeatherDetails();
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Loading weather data...',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'Error loading weather data',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  _error ?? 'Unknown error occurred',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _fetchWeatherData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataState() {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'No weather data available',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Weather information for this location is not available at the moment.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetails() {
    final weather = _currentWeather!;
    final location = widget.locationWithWeather.location;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(location, weather),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wind Information
                    if (_currentWeather?.wind != null) ...[
                      WindInfoCard(wind: _currentWeather!.wind!),
                      SizedBox(height: AppSpacing.lg),
                    ],

                    _buildHourlyForecast(),
                    SizedBox(height: AppSpacing.lg),
                    _buildDailyForecast(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Location location, WeatherData weather) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xxl),

          // City name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${location.name}',
                    style: AppTypography.displaySmall.copyWith(
                      fontSize: 32,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  // Temperature and condition
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Large temperature with weather-based styling
                        _buildTemperatureDisplay(weather),

                        // Condition and high/low
                      ],
                    ),
                  ),
                ],
              ),
              // Flutter Map Temperature Heatmap
              if (_forecastData != null &&
                  _forecastData!.forecasts.isNotEmpty) ...[
                FlutterMapHeatmap(
                  centerLocation: location,
                  forecasts: _forecastData!.forecasts.take(8).toList(),
                  radius: 50.0, // 50km radius around the city
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast() {
    if (_forecastData == null || _forecastData!.forecasts.isEmpty) {
      return _buildHourlyForecastPlaceholder();
    }

    // For 5-day forecast API, we get 3-hour intervals, so take first 8 entries (24 hours)
    final hourlyForecasts = _forecastData!.forecasts.take(8).toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: const Color(0xFFEFECE6),
        ),
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary text
                Text(
                  'Cloudy conditions from 1AM-9AM, with showers expected at 9AM.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Opacity(
                    opacity: 0.2,
                    child: Container(
                      width: double.infinity,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 0.20,
                            strokeAlign: BorderSide.strokeAlignCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Hourly list
          SizedBox(
            height: 100,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: hourlyForecasts.length,
              itemBuilder: (context, index) {
                final forecast = hourlyForecasts[index];
                return _buildHourlyItem(forecast, index == 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyItem(HourlyForecast forecast, bool isNow) {
    final time = isNow
        ? 'Now'
        : DateFormat('ha').format(forecast.dateTime).toLowerCase();

    return Container(
      width: 60,
      margin: EdgeInsets.only(right: AppSpacing.sm),
      child: Column(
        children: [
          Text(
            time,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          _buildWeatherIcon(forecast.weatherInfo.icon),
          SizedBox(height: AppSpacing.xs),
          Text(
            '${forecast.temp}°',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherIcon(String iconCode) {
    // Map OpenWeatherMap icon codes to appropriate icons
    IconData iconData;
    Color iconColor = AppColors.textPrimary;

    if (iconCode.contains('01')) {
      iconData = Icons.wb_sunny;
      iconColor = AppColors.sunColor;
    } else if (iconCode.contains('02') || iconCode.contains('03')) {
      iconData = Icons.wb_cloudy;
      iconColor = AppColors.cloudColor;
    } else if (iconCode.contains('09') || iconCode.contains('10')) {
      iconData = Icons.grain;
      iconColor = AppColors.rainColor;
    } else if (iconCode.contains('11')) {
      iconData = Icons.flash_on;
      iconColor = AppColors.stormColor;
    } else if (iconCode.contains('13')) {
      iconData = Icons.ac_unit;
      iconColor = AppColors.cloudColor;
    } else if (iconCode.contains('50')) {
      iconData = Icons.foggy;
      iconColor = AppColors.cloudColor;
    } else {
      iconData = Icons.wb_cloudy;
      iconColor = AppColors.cloudColor;
    }

    return Icon(
      iconData,
      size: 24,
      color: iconColor,
    );
  }

  Widget _buildHourlyForecastPlaceholder() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hourly forecast not available',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecast() {
    if (_forecastData == null || _forecastData!.forecasts.isEmpty) {
      return _buildDailyForecastPlaceholder();
    }

    // Group forecasts by day and take first 5 days (since 5-day forecast API)
    final dailyForecasts =
        _groupForecastsByDay(_forecastData!.forecasts).take(5).toList();

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: const Color(0xFFEFECE6),
        ),
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '5 Days Forecast',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Opacity(
              opacity: 0.2,
              child: Container(
                width: double.infinity,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 0.20,
                      strokeAlign: BorderSide.strokeAlignCenter,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Daily list
          ...dailyForecasts.asMap().entries.map((entry) {
            final index = entry.key;
            final dayForecast = entry.value;
            return _buildDailyItem(dayForecast, index == 0);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDailyItem(DailyForecast dayForecast, bool isToday) {
    final dayName =
        isToday ? 'Today' : DateFormat('EEEE').format(dayForecast.date);

    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          // Day name
          SizedBox(
            width: 80,
            child: Text(
              dayName,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Weather icon
          _buildWeatherIcon(dayForecast.icon),
          SizedBox(width: AppSpacing.sm),

          // Low temperature
          Text(
            '${dayForecast.minTemp}°',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: AppSpacing.sm),

          // Temperature range bar
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF96D0A8),
                    const Color(0xFFB5CF79),
                    const Color(0xFFF8D74A),
                    const Color(0xFFEF8835)
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Current temperature indicator
                  Positioned(
                    left: _calculateTemperaturePosition(dayForecast.minTemp,
                        dayForecast.maxTemp, dayForecast.currentTemp),
                    child: Container(
                      width: 4,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm),

          // High temperature
          Text(
            '${dayForecast.maxTemp}°',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTemperaturePosition(
      int minTemp, int maxTemp, int currentTemp) {
    final range = maxTemp - minTemp;
    if (range == 0) return 0;
    final position = (currentTemp - minTemp) / range;
    return (position * 100).clamp(0.0, 100.0);
  }

  Widget _buildDailyForecastPlaceholder() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '5 Days Forecast',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Daily forecast not available',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<DailyForecast> _groupForecastsByDay(List<HourlyForecast> forecasts) {
    final Map<String, List<HourlyForecast>> grouped = {};

    for (final forecast in forecasts) {
      final dayKey = DateFormat('yyyy-MM-dd').format(forecast.dateTime);
      grouped.putIfAbsent(dayKey, () => []).add(forecast);
    }

    return grouped.entries.map((entry) {
      final dayForecasts = entry.value;
      final date = dayForecasts.first.dateTime;
      final minTemp =
          dayForecasts.map((f) => f.temp).reduce((a, b) => a < b ? a : b);
      final maxTemp =
          dayForecasts.map((f) => f.temp).reduce((a, b) => a > b ? a : b);
      final currentTemp =
          dayForecasts.first.temp; // Use first forecast as current
      final icon = dayForecasts.first.icon;

      return DailyForecast(
        date: date,
        minTemp: minTemp,
        maxTemp: maxTemp,
        currentTemp: currentTemp,
        icon: icon,
      );
    }).toList();
  }

  Widget _buildTemperatureDisplay(WeatherData weather) {
    // Determine if weather is cold/cloudy or warm/sunny
    final isColdOrCloudy = _isColdOrCloudyWeather(weather);
    final temperatureColor =
        isColdOrCloudy ? AppColors.primaryBlue : AppColors.primaryOrange;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Temperature text
        Text(
          '${weather.currentTemp.round()}°',
          style: TextStyle(
            fontSize: 100,
            fontWeight: FontWeight.w300,
            color: temperatureColor,
            height: 0.9,
          ),
        ),
        // Weather overlay
        if (isColdOrCloudy)
          Positioned.fill(
            child: Image.asset(
              'assets/images/cold.png',
              fit: BoxFit.contain,
              opacity: const AlwaysStoppedAnimation(1),
            ),
          )
        else
          Positioned.fill(
            child: Image.asset(
              'assets/images/warm.png',
              fit: BoxFit.contain,
              opacity: const AlwaysStoppedAnimation(1),
            ),
          ),
      ],
    );
  }

  bool _isColdOrCloudyWeather(WeatherData weather) {
    // Check temperature
    if (weather.currentTemp <= 15) return true;

    // Check weather condition
    final condition = weather.condition;
    return condition == WeatherCondition.clouds ||
        condition == WeatherCondition.rain ||
        condition == WeatherCondition.drizzle ||
        condition == WeatherCondition.thunderstorm ||
        condition == WeatherCondition.snow ||
        condition == WeatherCondition.mist ||
        condition == WeatherCondition.fog ||
        condition == WeatherCondition.haze ||
        condition == WeatherCondition.smoke;
  }
}

// Helper class for daily forecast data

class DailyForecast {
  final DateTime date;
  final int minTemp;
  final int maxTemp;
  final int currentTemp;
  final String icon;

  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.currentTemp,
    required this.icon,
  });
}
