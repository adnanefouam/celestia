import 'package:celestia/core/design_system/app_colors.dart';
import 'package:celestia/core/design_system/app_spacing.dart';
import 'package:celestia/core/design_system/app_typography.dart';
import 'package:celestia/core/providers/providers.dart';
import 'package:celestia/core/services/saved_weather_service.dart';
import 'package:celestia/core/api/weather_service.dart';
import 'package:celestia/core/api/api_response.dart';
import 'package:celestia/core/models/location.dart';
import 'package:celestia/core/models/weather_data.dart';
import 'package:celestia/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  Timer? _debounceTimer;
  Map<String, dynamic> _savedCities = {};
  Map<String, WeatherData?> _savedCitiesWeather = {};
  bool _isLoadingWeather = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
    _loadSavedCities();
  }

  Future<void> _loadSavedCities() async {
    final savedCities = await SavedWeatherService.getSavedWeatherCities();
    setState(() {
      _savedCities = savedCities;
      _isLoadingWeather = true;
    });

    // Fetch weather data for each saved city
    await _fetchWeatherForSavedCities();
  }

  Future<void> _fetchWeatherForSavedCities() async {
    final weatherData = <String, WeatherData?>{};

    for (final entry in _savedCities.entries) {
      final cityData = entry.value;
      final location = Location(
        name: cityData['name'] ?? '',
        country: cityData['country'] ?? '',
        lat: cityData['lat']?.toDouble() ?? 0.0,
        lon: cityData['lon']?.toDouble() ?? 0.0,
      );

      try {
        final response =
            await WeatherService.instance.getCurrentWeatherByCoordinates(
          lat: location.lat,
          lon: location.lon,
        );

        if (response is ApiSuccess && response.data != null) {
          weatherData[entry.key] = response.data;
        } else {
          weatherData[entry.key] = null;
        }
      } catch (e) {
        weatherData[entry.key] = null;
      }
    }

    setState(() {
      _savedCitiesWeather = weatherData;
      _isLoadingWeather = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      _debounceTimer?.cancel();
      ref.read(searchProvider.notifier).clearSearch();
      return;
    }

    // Show loading state immediately when user starts typing
    ref.read(searchProvider.notifier).setLoadingState(query);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_searchController.text == query && query.trim().length >= 2) {
        ref.read(searchProvider.notifier).searchCities(query);
      } else if (query.trim().length < 2) {
        // Clear results if query is too short
        ref.read(searchProvider.notifier).clearSearch();
      }
    });
  }

  void _selectLocation(LocationWithWeather locationWithWeather) {
    _searchController.text = locationWithWeather.location.name;
    _searchFocusNode.unfocus();

    ref.read(searchProvider.notifier).selectLocation(locationWithWeather);
    // Don't clear search - keep the results visible when user comes back

    // Navigate to weather details screen
    context.pushNamed(
      'weather-details',
      extra: locationWithWeather,
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final hasResults = ref.watch(hasSearchResultsProvider);

    return GestureDetector(
      onTap: () {
        _searchFocusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: AppSpacing.paddingHorizontalLG,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.gapVerticalXXXL,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Text(
                            _getGreeting(),
                            style: AppTypography.displaySmall,
                          ),
                        ),
                        Flexible(
                          child: Assets.icons.celestiaLogo.svg(
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.gapVerticalXXL,
                    GestureDetector(
                      onTap: () {
                        _searchFocusNode.requestFocus();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          top: AppSpacing.sm + AppSpacing.xs,
                          left: AppSpacing.md + AppSpacing.xs,
                          right: AppSpacing.sm + AppSpacing.xs,
                          bottom: AppSpacing.sm + AppSpacing.xs,
                        ),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFAF9F7),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: _isSearchFocused
                                  ? AppColors.primaryOrange
                                  : const Color(0xFFE0DFDE),
                            ),
                            borderRadius: BorderRadius.circular(30.80),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 30.47,
                              height: 30.47,
                              clipBehavior: Clip.antiAlias,
                              decoration: const BoxDecoration(),
                              child: Assets.icons.searchIcon.svg(
                                width: 30.47,
                                height: 30.47,
                                colorFilter: ColorFilter.mode(
                                  _isSearchFocused
                                      ? AppColors.primaryOrange
                                      : AppColors.stormColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.80),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                onChanged: _onSearchChanged,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: AppTypography.medium,
                                  height: 1.21,
                                  letterSpacing: -0.08,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search for city or airport',
                                  hintStyle: AppTypography.bodyMedium.copyWith(
                                    color: const Color(0xFF76807B),
                                    fontSize: 14,
                                    fontWeight: AppTypography.medium,
                                    height: 1.21,
                                    letterSpacing: -0.08,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                              ),
                            ),
                            // Clear button when there's text
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _searchController,
                              builder: (context, value, child) {
                                if (value.text.isNotEmpty) {
                                  return GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      ref
                                          .read(searchProvider.notifier)
                                          .clearSearch();
                                    },
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: AppColors.textTertiary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }
                                return SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.gapVerticalLG,
                  ],
                ),
              ),
              Expanded(
                child: searchState.isLoading
                    ? _buildShimmerList()
                    : hasResults
                        ? _buildSearchResults(searchState.results)
                        : searchState.query.isNotEmpty
                            ? _buildNoResultsState()
                            : _buildMainContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<LocationWithWeather> results) {
    return ListView(
      padding: AppSpacing.paddingHorizontalXL,
      children: [
        ...results.asMap().entries.map((entry) {
          final index = entry.key;
          final result = entry.value;
          return Container(
            margin: EdgeInsets.only(
              bottom: index < results.length - 1 ? AppSpacing.md : 0,
            ),
            child: _buildSearchResultItem(result),
          );
        }),
      ],
    );
  }

  Widget _buildShimmerList() {
    return ListView(
      padding: AppSpacing.paddingHorizontalXL,
      children: List.generate(5, (index) {
        return Container(
          margin: EdgeInsets.only(
            bottom: index < 4 ? AppSpacing.md : 0,
          ),
          child: _buildShimmerItem(),
        );
      }),
    );
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultItem(LocationWithWeather result) {
    return InkWell(
      onTap: () => _selectLocation(result),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.location.name,
                    style: AppTypography.bodyLarge.copyWith(
                      color: const Color(0xFF030003),
                      fontSize: 20.14,
                      fontWeight: FontWeight.w500,
                      height: 1.21,
                      letterSpacing: -0.12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (result.location.state != null &&
                      result.location.state!.isNotEmpty)
                    Text(
                      '${result.location.state}, ${result.location.country}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      result.location.country ?? '',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Assets.icons.arrowUp.svg(
              width: 25,
              height: 25,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingHorizontalLG,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.images.noCity.image(width: 150),
            SizedBox(height: AppSpacing.lg),
            Text(
              'No cities found...',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Try searching with a different keyword',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    // Show saved cities if available
    if (_savedCities.isNotEmpty) {
      return _buildSavedCitiesList();
    }

    final screenSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
      padding: AppSpacing.paddingHorizontalLG,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Assets.images.allowLocationImage.image(width: 300),
            ),
            AppSpacing.gapVerticalXXXL,
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingHorizontalSM,
              child: Text(
                'Allow current location to show the actual weather, or try the search button above',
                textAlign: TextAlign.center,
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ),
            AppSpacing.gapVerticalXL,
            Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppRadius.radiusCircular,
                  onTap: () {
                    print('Allow current location tapped');
                  },
                  child: Container(
                    width: screenSize.width * 0.55,
                    height: screenSize.height * 0.05,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      border: Border.all(
                        color: AppColors.primaryOrangeDark.withOpacity(0.3),
                        width: 1.02,
                      ),
                      borderRadius: AppRadius.radiusCircular,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryOrange,
                          offset: const Offset(0, 0),
                          blurRadius: 0,
                          spreadRadius: 1.02,
                        ),
                        BoxShadow(
                          color: AppColors.primaryOrangeDark.withOpacity(0.1),
                          offset: const Offset(0, 1.02),
                          blurRadius: 2.05,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Allow current location',
                        style: AppTypography.buttonMedium.copyWith(
                          color: AppColors.backgroundPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCitiesList() {
    return ListView(
      padding: AppSpacing.paddingHorizontalLG,
      children: [
        SizedBox(height: AppSpacing.md),
        Text(
          'Saved Cities',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        if (_isLoadingWeather)
          ...List.generate(
              3,
              (index) => Container(
                    margin: EdgeInsets.only(bottom: AppSpacing.md),
                    child: _buildLoadingCard(),
                  ))
        else
          ..._savedCities.entries.map((entry) {
            final cityData = entry.value;
            final savedAt = cityData['savedAt'];
            final weather = _savedCitiesWeather[entry.key];

            return Container(
              margin: EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildSavedCityCard(cityData, savedAt, weather),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildSavedCityCard(
      Map<String, dynamic> cityData, int savedAt, WeatherData? weather) {
    // Calculate the actual time for this specific city
    final cityHour = _getCityHour(
        cityData['lat']?.toDouble() ?? 0.0, cityData['lon']?.toDouble() ?? 0.0);

    // Determine time of day and background based on city's actual time
    String timeOfDay;
    String condition;

    if (cityHour >= 6 && cityHour < 12) {
      timeOfDay = 'Morning';
      condition = weather?.description ?? 'Mostly clear';
    } else if (cityHour >= 12 && cityHour < 18) {
      timeOfDay = 'Noon';
      condition = weather?.description ?? 'Partly cloudy';
    } else {
      timeOfDay = 'Night';
      condition = weather?.description ?? 'Clear sky';
    }

    return GestureDetector(
        onTap: () {
          // Navigate to weather details for this saved city
          final location = Location(
            name: cityData['name'] ?? '',
            country: cityData['country'] ?? '',
            lat: cityData['lat']?.toDouble() ?? 0.0,
            lon: cityData['lon']?.toDouble() ?? 0.0,
          );

          // Create a LocationWithWeather with current weather data
          final locationWithWeather = LocationWithWeather(
            location: location,
            weather: weather,
            isLoadingWeather: false,
          );

          context.push('/weather-details', extra: locationWithWeather);
        },
        child: Container(
          height: 140,
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              child: Stack(
                children: [
                  // Background
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: _getTimeBasedBackgroundImage(timeOfDay),
                  ),

                  // Content overlay
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top - City name and temperature
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left side - City and country name
                              Expanded(
                                child: Text(
                                  '${cityData['name']}, ${cityData['country']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              // Right side - Temperature
                              Text(
                                weather != null
                                    ? '${weather.currentTemp.round()}°'
                                    : '--°',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),

                          // Bottom - Weather condition
                          Text(
                            condition,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  int _getCityHour(double lat, double lon) {
    // Calculate timezone offset based on longitude
    // Each 15 degrees of longitude represents 1 hour difference
    final timezoneOffset = (lon / 15.0).round();

    // Get current UTC time
    final utcNow = DateTime.now().toUtc();

    // Calculate the city's local time
    final cityTime = utcNow.add(Duration(hours: timezoneOffset));

    return cityTime.hour;
  }

  Widget _getTimeBasedBackgroundImage(String timeOfDay) {
    switch (timeOfDay) {
      case 'Morning':
        return Assets.images.savedwether.morning.image(
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        );
      case 'Noon':
        return Assets.images.savedwether.noon.image(
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        );
      case 'Night':
        return Assets.images.savedwether.night.image(
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        );
      default:
        return Assets.images.savedwether.morning.image(
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        );
    }
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 120,
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
        ),
      ),
    );
  }
}
