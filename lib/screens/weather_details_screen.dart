import 'package:celestia/core/design_system/app_colors.dart';
import 'package:celestia/core/design_system/app_spacing.dart';
import 'package:celestia/core/design_system/app_typography.dart';
import 'package:celestia/core/design_system/wind_info_card.dart';
import 'package:celestia/core/design_system/interactive_weather_map.dart';
import 'package:celestia/core/models/weather_data.dart';
import 'package:celestia/core/models/location.dart';
import 'package:celestia/core/models/forecast_data.dart';
import 'package:celestia/core/enums/weather_condition.dart';
import 'package:celestia/core/providers/providers.dart';
import 'package:celestia/core/providers/saved_cities_provider.dart';
import 'package:celestia/core/api/weather_service.dart';
import 'package:celestia/core/api/api_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as Math;
import '../gen/assets.gen.dart';
import '../core/services/saved_weather_service.dart';

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
  bool _isCitySaved = false;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
    _checkIfCityIsSaved();
  }

  Future<void> _checkIfCityIsSaved() async {
    final isSaved = await SavedWeatherService.isCitySaved(
        widget.locationWithWeather.location);
    setState(() {
      _isCitySaved = isSaved;
    });
  }

  Future<void> _toggleSaveCity() async {
    if (_isCitySaved) {
      await SavedWeatherService.removeWeatherCity(
          widget.locationWithWeather.location);
    } else {
      await SavedWeatherService.saveWeatherCity(
          widget.locationWithWeather.location);
    }

    // Notify the saved cities provider to refresh
    ref.read(savedCitiesProvider.notifier).addSavedCity({
      'name': widget.locationWithWeather.location.name,
      'country': widget.locationWithWeather.location.country,
      'lat': widget.locationWithWeather.location.lat,
      'lon': widget.locationWithWeather.location.lon,
    });

    setState(() {
      _isCitySaved = !_isCitySaved;
    });
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
      body: Stack(
        children: [
          // Map as background layer
          if (_forecastData != null && _forecastData!.forecasts.isNotEmpty)
            Positioned.fill(
              child: InteractiveWeatherMap(
                centerLocation: location,
                forecasts: _forecastData!.forecasts.take(8).toList(),
                currentWeather: weather,
                radius: 50.0, // 50km radius around the city
              ),
            ),

          // Bottom sheet with weather details
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundPrimary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      width: 80,
                      height: 6,
                      margin: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(1000),
                      ),
                    ),

                    // Weather content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding:
                            EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(location, weather),
                            SizedBox(height: AppSpacing.lg),

                            // Wind Information
                            if (_currentWeather?.wind != null) ...[
                              WindInfoCard(wind: _currentWeather!.wind!),
                              SizedBox(height: AppSpacing.lg),
                            ],

                            _buildHourlyForecast(),
                            SizedBox(height: AppSpacing.lg),
                            _buildDailyForecast(),
                            SizedBox(height: AppSpacing.lg),

                            // Weather Information Cards
                            _buildWeatherInfoCards(),
                            SizedBox(
                                height:
                                    AppSpacing.xl), // Extra padding at bottom
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
                    border: Border.all(
                      width: 1,
                      color: const Color(0xFFEFECE6),
                    ),
                    color: const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${location.name}, ${location.country}',
                  style: AppTypography.displaySmall.copyWith(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _toggleSaveCity,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: const Color(0xFFEFECE6),
                    ),
                    color: const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isCitySaved ? Icons.favorite : Icons.favorite_border,
                    color: _isCitySaved ? Colors.red : Colors.grey,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTemperatureDisplay(weather),

              // Condition and high/low
              if (_currentWeather != null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weather condition
                    Text(
                      _getWeatherConditionText(_currentWeather!.condition),
                      style: const TextStyle(
                        color: Color(0xFF2A2A2B),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    // High/Low temperatures
                    Text(
                      'H:${_getHighTemperature().round()}° L:${_getLowTemperature().round()}°',
                      style: const TextStyle(
                        color: Color(0xFF2A2A2B),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),

              Image.asset(
                _getWeatherIcon(_currentWeather!.condition).path,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                opacity: const AlwaysStoppedAnimation(0.8),
              ),
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
    // Map OpenWeatherMap icon codes to custom weather icons
    AssetGenImage weatherIcon;

    if (iconCode.contains('01')) {
      weatherIcon = Assets.images.iconsWeather.suny;
    } else if (iconCode.contains('02') || iconCode.contains('03')) {
      weatherIcon = Assets.images.iconsWeather.sunCloud;
    } else if (iconCode.contains('09') || iconCode.contains('10')) {
      weatherIcon = Assets.images.iconsWeather.rain;
    } else if (iconCode.contains('11')) {
      weatherIcon = Assets.images.iconsWeather.thunder;
    } else if (iconCode.contains('13')) {
      weatherIcon = Assets.images.iconsWeather.rain; // Using rain icon for snow
    } else if (iconCode.contains('50')) {
      weatherIcon = Assets.images.iconsWeather.moonCloud;
    } else {
      weatherIcon = Assets.images.iconsWeather.sunCloud;
    }

    return Image.asset(
      weatherIcon.path,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
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
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
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
                clipBehavior: Clip.none,
                children: [
                  // Current temperature indicator
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: _calculateTemperaturePosition(dayForecast.minTemp,
                        dayForecast.maxTemp, dayForecast.currentTemp),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.textPrimary, width: 2),
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

    return Text(
      '${weather.currentTemp.round()}°',
      style: TextStyle(
        fontSize: 80,
        fontWeight: FontWeight.w300,
        color: temperatureColor,
      ),
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

  String _getWeatherConditionText(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return 'Clear';
      case WeatherCondition.clouds:
        return 'Partly Cloudy';
      case WeatherCondition.rain:
        return 'Rain';
      case WeatherCondition.drizzle:
        return 'Drizzle';
      case WeatherCondition.thunderstorm:
        return 'Thunderstorm';
      case WeatherCondition.snow:
        return 'Snow';
      case WeatherCondition.mist:
        return 'Mist';
      case WeatherCondition.fog:
        return 'Fog';
      case WeatherCondition.haze:
        return 'Haze';
      case WeatherCondition.dust:
        return 'Dust';
      case WeatherCondition.sand:
        return 'Sand';
      case WeatherCondition.ash:
        return 'Ash';
      case WeatherCondition.squall:
        return 'Squall';
      case WeatherCondition.tornado:
        return 'Tornado';
      case WeatherCondition.smoke:
        return 'Smoke';
      case WeatherCondition.unknown:
        return 'Unknown';
    }
  }

  double _getHighTemperature() {
    if (_forecastData == null || _forecastData!.forecasts.isEmpty)
      return (_currentWeather?.currentTemp ?? 0.0).toDouble();

    double maxTemp = (_currentWeather?.currentTemp ?? 0.0).toDouble();
    for (final forecast in _forecastData!.forecasts) {
      if (forecast.temperature.temp.toDouble() > maxTemp) {
        maxTemp = forecast.temperature.temp.toDouble();
      }
    }
    return maxTemp;
  }

  double _getLowTemperature() {
    if (_forecastData == null || _forecastData!.forecasts.isEmpty)
      return (_currentWeather?.currentTemp ?? 0.0).toDouble();

    double minTemp = (_currentWeather?.currentTemp ?? 0.0).toDouble();
    for (final forecast in _forecastData!.forecasts) {
      if (forecast.temperature.temp.toDouble() < minTemp) {
        minTemp = forecast.temperature.temp.toDouble();
      }
    }
    return minTemp;
  }

  Widget _buildWeatherInfoCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Weather Details',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        // First row - UV Index and Sunrise/Sunset
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildUVIndexCard()),
            SizedBox(width: AppSpacing.md),
            Expanded(child: _buildSunriseCard()),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        // Second row - Wind and Rainfall
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildWindCard()),
            SizedBox(width: AppSpacing.md),
            Expanded(child: _buildRainfallCard()),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        // Third row - Feels Like and Humidity
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildFeelsLikeCard()),
            SizedBox(width: AppSpacing.md),
            Expanded(child: _buildHumidityCard()),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        // Fourth row - Additional Humidity Card
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildHumidityDetailsCard()),
            SizedBox(width: AppSpacing.md),
            Expanded(child: _buildPressureCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildUVIndexCard() {
    // UV Index is not available in current API, using a calculated value
    final uvIndex = _calculateUVIndex();
    final uvLevel = _getUVLevel(uvIndex);
    final uvColor = _getUVColor(uvIndex);

    return Container(
      constraints: BoxConstraints(
          minHeight: 160, maxHeight: 200), // Flexible height with constraints
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEFECE6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny, color: AppColors.textPrimary, size: 20),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'UV INDEX',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            '$uvIndex',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            uvLevel,
            style: AppTypography.bodyMedium.copyWith(
              color: uvColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          // UV Index bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: [
                  Colors.green,
                  Colors.yellow,
                  Colors.orange,
                  Colors.red,
                  Colors.purple,
                ],
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: (uvIndex / 11.0) * 100, // UV index goes up to 11
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.textPrimary, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            '$uvLevel for the rest of the day.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunriseCard() {
    // Sunrise/sunset not available in current API, using calculated values
    final sunrise = _calculateSunrise();
    final sunset = _calculateSunset();

    return Container(
      constraints: BoxConstraints(
          minHeight: 160, maxHeight: 200), // Flexible height with constraints
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEFECE6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.wb_twilight, color: AppColors.textPrimary, size: 20),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'SUNRISE',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            _formatTime(sunrise),
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          // Sunset image
          Container(
            height: 40,
            child: Image.asset(
              Assets.images.sunset.path,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Sunset: ${_formatTime(sunset)}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWindCard() {
    final windSpeed = _currentWeather?.wind?.speed ?? 0;
    final windDirection = _currentWeather?.wind?.deg.toDouble() ?? 0;

    return Container(
      constraints: BoxConstraints(
          minHeight: 160, maxHeight: 200), // Flexible height with constraints
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEFECE6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.air, color: AppColors.textPrimary, size: 20),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'WIND',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            '${windSpeed.toStringAsFixed(1)} m/s',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Direction: ${_getWindDirection(windDirection)}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (_currentWeather?.wind?.gust != null &&
              _currentWeather!.wind!.gust! > 0) ...[
            SizedBox(height: AppSpacing.sm),
            Text(
              'Gusts: ${_currentWeather!.wind!.gust!.toStringAsFixed(1)} m/s',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: AppSpacing.sm),
          Text(
            _getWindDescription(windSpeed),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRainfallCard() {
    final rainfall = _getRainfallData();
    final expectedRainfall = _getExpectedRainfall();

    return Container(
      constraints: BoxConstraints(
          minHeight: 160, maxHeight: 200), // Flexible height with constraints
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEFECE6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop, color: AppColors.textPrimary, size: 20),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'RAINFALL',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            '${rainfall.toStringAsFixed(1)} mm',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'in last 24h',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            '${expectedRainfall.toStringAsFixed(1)} mm expected in next 24h.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeelsLikeCard() {
    final feelsLike = _currentWeather?.temperature.feelsLike ??
        _currentWeather?.temperature.temp ??
        0;
    final actualTemp = _currentWeather?.temperature.temp ?? 0;
    final difference = feelsLike - actualTemp;

    return Container(
      constraints: BoxConstraints(
          minHeight: 160, maxHeight: 200), // Flexible height with constraints
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEFECE6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.thermostat, color: AppColors.textPrimary, size: 20),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'FEELS LIKE',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            '${feelsLike.round()}°',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            difference.abs() < 1
                ? 'Similar to the actual temperature'
                : '${difference > 0 ? '+' : ''}${difference.toStringAsFixed(1)}° from actual',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHumidityCard() {
    // Humidity not available in current API, using a calculated value
    final humidity = _calculateHumidity();
    final dewPoint = _getDewPoint();

    return Container(
      constraints: BoxConstraints(
          minHeight: 160, maxHeight: 200), // Flexible height with constraints
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEFECE6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_outlined,
                  color: AppColors.textPrimary, size: 20),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'HUMIDITY',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            '$humidity%',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          // Humidity bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: const Color(0xFFEFECE6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: humidity / 100,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade300, Colors.blue.shade600],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'The dew point is ${dewPoint.round()}° right now.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHumidityDetailsCard() {
    final dewPoint = _getDewPoint();
    final visibility = _calculateVisibility();

    return Container(
      constraints: BoxConstraints(
          minHeight: 160, maxHeight: 200), // Flexible height with constraints
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEFECE6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_outlined,
                  color: AppColors.textPrimary, size: 20),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'HUMIDITY DETAILS',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Dew Point: ${dewPoint.round()}°',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Visibility: ${visibility.toStringAsFixed(1)} km',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildPressureCard() {
    final pressure = _calculatePressure();
    final pressureTrend = _getPressureTrend();

    return Container(
      constraints: BoxConstraints(
          minHeight: 160, maxHeight: 200), // Flexible height with constraints
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEFECE6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: AppColors.textPrimary, size: 20),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'PRESSURE',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            '${pressure.toStringAsFixed(0)} hPa',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                pressureTrend == 'rising'
                    ? Icons.trending_up
                    : pressureTrend == 'falling'
                        ? Icons.trending_down
                        : Icons.trending_flat,
                color: pressureTrend == 'rising'
                    ? Colors.green
                    : pressureTrend == 'falling'
                        ? Colors.red
                        : Colors.grey,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                '${pressureTrend.toUpperCase()}',
                style: AppTypography.bodySmall.copyWith(
                  color: pressureTrend == 'rising'
                      ? Colors.green
                      : pressureTrend == 'falling'
                          ? Colors.red
                          : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            _getPressureDescription(pressure),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for weather data
  String _getUVLevel(int uvIndex) {
    if (uvIndex <= 2) return 'Low';
    if (uvIndex <= 5) return 'Moderate';
    if (uvIndex <= 7) return 'High';
    if (uvIndex <= 10) return 'Very High';
    return 'Extreme';
  }

  Color _getUVColor(int uvIndex) {
    if (uvIndex <= 2) return Colors.green;
    if (uvIndex <= 5) return Colors.yellow;
    if (uvIndex <= 7) return Colors.orange;
    if (uvIndex <= 10) return Colors.red;
    return Colors.purple;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  double _getRainfallData() {
    // Calculate rainfall from forecast data
    if (_forecastData == null || _forecastData!.forecasts.isEmpty) return 0.0;

    double totalRainfall = 0.0;
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));

    for (final forecast in _forecastData!.forecasts) {
      if (forecast.dateTime.isAfter(yesterday) &&
          forecast.dateTime.isBefore(now)) {
        totalRainfall += forecast.rain?.oneHour ?? 0.0;
      }
    }

    return totalRainfall;
  }

  double _getExpectedRainfall() {
    // Calculate expected rainfall for next 24 hours
    if (_forecastData == null || _forecastData!.forecasts.isEmpty) return 0.0;

    double expectedRainfall = 0.0;
    final now = DateTime.now();
    final tomorrow = now.add(Duration(days: 1));

    for (final forecast in _forecastData!.forecasts) {
      if (forecast.dateTime.isAfter(now) &&
          forecast.dateTime.isBefore(tomorrow)) {
        expectedRainfall += forecast.rain?.oneHour ?? 0.0;
      }
    }

    return expectedRainfall;
  }

  double _getDewPoint() {
    // Simple dew point calculation
    final temp = _currentWeather?.temperature.temp ?? 0;
    final humidity = _calculateHumidity();

    if (humidity == 0) return 0.0;

    // Magnus formula approximation
    final a = 17.27;
    final b = 237.7;
    final alpha = ((a * temp) / (b + temp)) + Math.log(humidity / 100.0);
    return (b * alpha) / (a - alpha);
  }

  // Helper methods for calculated weather data
  int _calculateUVIndex() {
    // Simple UV index calculation based on time of day and season
    final now = DateTime.now();
    final hour = now.hour;
    final month = now.month;

    // Base UV index varies by season (higher in summer)
    int baseUV = 3;
    if (month >= 5 && month <= 8)
      baseUV = 6; // Summer
    else if (month >= 3 && month <= 4 || month >= 9 && month <= 10)
      baseUV = 4; // Spring/Fall

    // Adjust by time of day (peak around noon)
    if (hour >= 10 && hour <= 14) return baseUV;
    if (hour >= 8 && hour <= 16) return baseUV - 1;
    return Math.max(0, baseUV - 2);
  }

  DateTime _calculateSunrise() {
    // Simple sunrise calculation (6:30 AM as default)
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 6, 30);
  }

  DateTime _calculateSunset() {
    // Simple sunset calculation (6:10 PM as default)
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 18, 10);
  }

  int _calculateHumidity() {
    // Simple humidity calculation based on temperature and weather condition
    final temp = _currentWeather?.temperature.temp ?? 20;
    final condition = _currentWeather?.condition ?? WeatherCondition.clear;

    int baseHumidity = 50;

    // Adjust based on weather condition
    switch (condition) {
      case WeatherCondition.rain:
      case WeatherCondition.drizzle:
        baseHumidity = 85;
        break;
      case WeatherCondition.clouds:
      case WeatherCondition.mist:
      case WeatherCondition.fog:
        baseHumidity = 70;
        break;
      case WeatherCondition.clear:
        baseHumidity = 40;
        break;
      default:
        baseHumidity = 50;
    }

    // Adjust based on temperature (colder = higher humidity)
    if (temp < 10)
      baseHumidity += 10;
    else if (temp > 30) baseHumidity -= 10;

    return Math.max(10, Math.min(95, baseHumidity));
  }

  double _calculateVisibility() {
    // Calculate visibility based on weather conditions
    final condition = _currentWeather?.condition ?? WeatherCondition.clear;
    final humidity = _calculateHumidity();

    double baseVisibility = 10.0; // km

    switch (condition) {
      case WeatherCondition.fog:
      case WeatherCondition.mist:
        baseVisibility = 0.5;
        break;
      case WeatherCondition.haze:
        baseVisibility = 2.0;
        break;
      case WeatherCondition.rain:
      case WeatherCondition.drizzle:
        baseVisibility = 5.0;
        break;
      case WeatherCondition.clouds:
        baseVisibility = 8.0;
        break;
      case WeatherCondition.clear:
        baseVisibility = 15.0;
        break;
      default:
        baseVisibility = 10.0;
    }

    // Adjust based on humidity
    if (humidity > 80)
      baseVisibility *= 0.7;
    else if (humidity > 60) baseVisibility *= 0.9;

    return Math.max(0.1, Math.min(20.0, baseVisibility));
  }

  double _calculatePressure() {
    // Calculate atmospheric pressure (simplified)
    final temp = _currentWeather?.temperature.temp ?? 20;
    final humidity = _calculateHumidity();

    // Base pressure at sea level
    double basePressure = 1013.25; // hPa

    // Adjust based on temperature (higher temp = slightly lower pressure)
    basePressure -= (temp - 20) * 0.1;

    // Adjust based on humidity (higher humidity = slightly lower pressure)
    basePressure -= (humidity - 50) * 0.05;

    return Math.max(950, Math.min(1050, basePressure));
  }

  String _getPressureTrend() {
    // Simple pressure trend calculation
    final now = DateTime.now();
    final hour = now.hour;

    // Simulate pressure changes throughout the day
    if (hour >= 6 && hour <= 12) return 'rising';
    if (hour >= 12 && hour <= 18) return 'falling';
    if (hour >= 18 && hour <= 24) return 'rising';
    return 'stable';
  }

  String _getPressureDescription(double pressure) {
    if (pressure < 1000) return 'Low pressure - stormy weather likely';
    if (pressure < 1010) return 'Below average - unsettled weather';
    if (pressure < 1020) return 'Normal pressure - fair weather';
    if (pressure < 1030) return 'Above average - stable weather';
    return 'High pressure - clear skies';
  }

  String _getWindDirection(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'N';
    if (degrees >= 22.5 && degrees < 67.5) return 'NE';
    if (degrees >= 67.5 && degrees < 112.5) return 'E';
    if (degrees >= 112.5 && degrees < 157.5) return 'SE';
    if (degrees >= 157.5 && degrees < 202.5) return 'S';
    if (degrees >= 202.5 && degrees < 247.5) return 'SW';
    if (degrees >= 247.5 && degrees < 292.5) return 'W';
    if (degrees >= 292.5 && degrees < 337.5) return 'NW';
    return 'N';
  }

  String _getWindDescription(double windSpeed) {
    if (windSpeed < 0.5) return 'Calm';
    if (windSpeed < 1.5) return 'Light air';
    if (windSpeed < 3.3) return 'Light breeze';
    if (windSpeed < 5.5) return 'Gentle breeze';
    if (windSpeed < 7.9) return 'Moderate breeze';
    if (windSpeed < 10.7) return 'Fresh breeze';
    if (windSpeed < 13.8) return 'Strong breeze';
    if (windSpeed < 17.1) return 'Near gale';
    if (windSpeed < 20.7) return 'Gale';
    if (windSpeed < 24.4) return 'Strong gale';
    if (windSpeed < 28.4) return 'Storm';
    if (windSpeed < 32.6) return 'Violent storm';
    return 'Hurricane';
  }

  AssetGenImage _getWeatherIcon(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return Assets.images.iconsWeather.suny;
      case WeatherCondition.clouds:
        return Assets.images.iconsWeather.sunCloud;
      case WeatherCondition.rain:
      case WeatherCondition.drizzle:
        return Assets.images.iconsWeather.rain;
      case WeatherCondition.thunderstorm:
        return Assets.images.iconsWeather.thunder;
      case WeatherCondition.snow:
        return Assets.images.iconsWeather.rain; // Using rain icon for snow
      case WeatherCondition.mist:
      case WeatherCondition.fog:
      case WeatherCondition.haze:
        return Assets.images.iconsWeather.moonCloud;
      case WeatherCondition.smoke:
      case WeatherCondition.dust:
      case WeatherCondition.sand:
      case WeatherCondition.ash:
        return Assets.images.iconsWeather.moonCloud;
      case WeatherCondition.squall:
      case WeatherCondition.tornado:
        return Assets.images.iconsWeather.thunder;
      case WeatherCondition.unknown:
        return Assets.images.iconsWeather.suny;
    }
  }
}

// Custom painters for weather visualizations
class SunArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height);
    final radius = size.width * 0.4;

    // Draw sun arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      Math.pi, // Start from left (180 degrees)
      Math.pi, // Draw half circle (180 degrees)
      false,
      paint,
    );

    // Draw current time indicator (positioned on the right side)
    final currentTimeX = size.width * 0.8;
    final currentTimeY = size.height * 0.3;
    canvas.drawCircle(
      Offset(currentTimeX, currentTimeY),
      4,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
