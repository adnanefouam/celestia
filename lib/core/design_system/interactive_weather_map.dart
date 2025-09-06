import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:celestia/core/models/forecast_data.dart';
import 'package:celestia/core/models/location.dart';
import 'package:celestia/core/models/weather_data.dart';
import 'package:celestia/core/enums/weather_condition.dart';
import 'package:celestia/core/design_system/precipitation_tile_provider.dart';
import 'package:celestia/core/design_system/temperature_tile_provider.dart';
import 'package:celestia/core/design_system/wind_tile_provider.dart';
import 'package:celestia/gen/assets.gen.dart';

class InteractiveWeatherMap extends StatefulWidget {
  final Location centerLocation;
  final List<HourlyForecast> forecasts;
  final WeatherData? currentWeather;
  final double radius;

  const InteractiveWeatherMap({
    super.key,
    required this.centerLocation,
    required this.forecasts,
    this.currentWeather,
    this.radius = 50.0,
  });

  @override
  State<InteractiveWeatherMap> createState() => _InteractiveWeatherMapState();
}

class _InteractiveWeatherMapState extends State<InteractiveWeatherMap>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  late AnimationController _markerAnimationController;
  late Animation<double> _markerScaleAnimation;

  String _selectedLayer = 'precipitation'; // temperature, precipitation, wind

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Initialize marker animations
    _markerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _markerScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _markerAnimationController,
      curve: Curves.elasticOut,
    ));

    // Auto-zoom to the city location and animate marker once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoZoomToCity();
      _markerAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _markerAnimationController.dispose();
    super.dispose();
  }

  void _autoZoomToCity() {
    _mapController.move(
      LatLng(widget.centerLocation.lat, widget.centerLocation.lon),
      6.0, // Zoom level for country view
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Main map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(
                    widget.centerLocation.lat, widget.centerLocation.lon),
                initialZoom: 6.0,
                minZoom: 3.0,
                maxZoom: 18.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onTap: (tapPosition, point) {
                  // Handle map tap interactions
                },
              ),
              children: [
                // Mapbox tiles
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/mapbox/light-v11/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiYWRuYW5lZm91aGFtIiwiYSI6ImNrYTFvbXU5YzAyaGIzZG9jMjQ4cDJzcm0ifQ.TTC6dVvtTUyuj4MEJdbq0A',
                  userAgentPackageName: 'com.celestia.app',
                  maxZoom: 18,
                  minZoom: 3,
                ),

                // Precipitation tile layer (conditional)
                if (_selectedLayer == 'precipitation')
                  Opacity(
                    opacity: 0.7,
                    child: TileLayer(
                      key: ValueKey(
                          'precipitation_${_selectedLayer}_${DateTime.now().millisecondsSinceEpoch}'),
                      tileProvider: PrecipitationTileProvider(
                        apiKey: '2b82ccf3fb883f1267530199e5e0d4e6',
                      ),
                      maxZoom: 18,
                      minZoom: 3,
                    ),
                  ),

                // Temperature tile layer (conditional)
                if (_selectedLayer == 'temperature')
                  Opacity(
                    opacity: 0.7,
                    child: TileLayer(
                      key: ValueKey(
                          'temperature_${_selectedLayer}_${DateTime.now().millisecondsSinceEpoch}'),
                      tileProvider: TemperatureTileProvider(
                        apiKey: '2b82ccf3fb883f1267530199e5e0d4e6',
                      ),
                      maxZoom: 18,
                      minZoom: 3,
                    ),
                  ),

                // Wind tile layer (conditional)
                if (_selectedLayer == 'wind')
                  Opacity(
                    opacity: 0.7,
                    child: TileLayer(
                      key: ValueKey(
                          'wind_${_selectedLayer}_${DateTime.now().millisecondsSinceEpoch}'),
                      tileProvider: WindTileProvider(
                        apiKey: '2b82ccf3fb883f1267530199e5e0d4e6',
                      ),
                      maxZoom: 18,
                      minZoom: 3,
                    ),
                  ),

                // Additional city markers layer (rendered first)
                MarkerLayer(
                  markers: _buildAdditionalCityMarkers(),
                ),

                // Main city marker layer (rendered last to stay on top)
                MarkerLayer(
                  markers: _buildMainCityMarker(),
                ),
              ],
            ),

            // Layer selection buttons (top right)
            Positioned(
              top: 80,
              right: 16,
              child: _buildLayerButtons(),
            ),

            // Legend panel (top left)
            Positioned(
              top: 80,
              left: 16,
              child: _buildLegendPanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayerButtons() {
    return Column(
      children: [
        _buildLayerButton('precipitation', Icons.water_drop, 'Precipitation'),
        const SizedBox(height: 8),
        _buildLayerButton('temperature', Icons.thermostat, 'Temperature'),
        const SizedBox(height: 8),
        _buildLayerButton('wind', Icons.air, 'Wind'),
      ],
    );
  }

  Widget _buildLayerButton(String layer, IconData icon, String tooltip) {
    final isSelected = _selectedLayer == layer;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLayer = layer;
        });
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF007AFF)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[700],
          size: 24.0,
        ),
      ),
    );
  }

  Widget _buildLegendPanel() {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getLayerTitle(),
            style: const TextStyle(
              color: Color(0xFF2A2A2B),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildLegendScale(),
        ],
      ),
    );
  }

  String _getLayerTitle() {
    switch (_selectedLayer) {
      case 'precipitation':
        return 'Precipitation';
      case 'temperature':
        return 'Temperature';
      case 'wind':
        return 'Wind (mph)';
      default:
        return 'Weather';
    }
  }

  Widget _buildLegendScale() {
    switch (_selectedLayer) {
      case 'precipitation':
        return _buildPrecipitationScale();
      case 'temperature':
        return _buildTemperatureScale();
      case 'wind':
        return _buildWindScale();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPrecipitationScale() {
    return Row(
      children: [
        // Vertical gradient bar
        Container(
          width: 20,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.yellow, // Extreme (top)
                Colors.orange, // Heavy
                Colors.purple, // Moderate
                Colors.lightBlue, // Light (bottom)
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        // Labels
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Extreme', style: _getScaleTextStyle()),
            Text('Heavy', style: _getScaleTextStyle()),
            Text('Moderate', style: _getScaleTextStyle()),
            Text('Light', style: _getScaleTextStyle()),
          ],
        ),
      ],
    );
  }

  Widget _buildTemperatureScale() {
    return Row(
      children: [
        // Vertical gradient bar
        Container(
          width: 20,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.red, // 55° (top)
                Colors.orange, // 20°
                Colors.yellow, // 10°
                Colors.lightBlue, // 0°
                Colors.blue, // -20°
                Colors.purple, // -40° (bottom)
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        // Labels
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('55°', style: _getScaleTextStyle()),
            Text('20°', style: _getScaleTextStyle()),
            Text('10°', style: _getScaleTextStyle()),
            Text('0°', style: _getScaleTextStyle()),
            Text('-20°', style: _getScaleTextStyle()),
            Text('-40°', style: _getScaleTextStyle()),
          ],
        ),
      ],
    );
  }

  Widget _buildWindScale() {
    return Row(
      children: [
        // Vertical gradient bar
        Container(
          width: 20,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white, // 75 (top)
                Colors.lightBlue, // 50
                Colors.blue, // 25
                Colors.blue[900]!, // 0 (bottom)
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        // Labels
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('75', style: _getScaleTextStyle()),
            Text('50', style: _getScaleTextStyle()),
            Text('25', style: _getScaleTextStyle()),
            Text('0', style: _getScaleTextStyle()),
          ],
        ),
      ],
    );
  }

  TextStyle _getScaleTextStyle() {
    return const TextStyle(
      color: Color(0xFF2A2A2B),
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
  }

  List<Marker> _buildMainCityMarker() {
    final markers = <Marker>[];

    // Main city marker (animated) - always on top
    if (widget.currentWeather != null) {
      markers.add(
        Marker(
          point: LatLng(widget.centerLocation.lat, widget.centerLocation.lon),
          width: 110,
          height: 110,
          child: AnimatedBuilder(
            animation: _markerAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _markerScaleAnimation.value,
                child: _buildAnimatedWeatherMarker(widget.currentWeather!),
              );
            },
          ),
        ),
      );
    }

    return markers;
  }

  List<Marker> _buildAdditionalCityMarkers() {
    final markers = <Marker>[];

    // Additional city markers (static) - rendered first
    final additionalCities = _generateAdditionalCities();
    for (final city in additionalCities) {
      markers.add(
        Marker(
          point: LatLng(city['lat'], city['lon']),
          width: 60,
          height: 60,
          child: _buildStaticWeatherMarker(city),
        ),
      );
    }

    return markers;
  }

  Widget _buildAnimatedWeatherMarker(WeatherData weather) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Color(0xFF007AFF), // Solid vibrant blue like iOS
            shape: BoxShape.circle,
            border: Border.all(
              color: Color(0xFF46464C),
              width: 4.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Temperature
              Text(
                '${weather.currentTemp.round()}°',
                style: const TextStyle(
                    color: Colors.white, fontSize: 20.0, height: 0.8),
              ),

              Image.asset(
                _getWeatherIcon(weather.condition).path,
                width: 25,
                fit: BoxFit.contain,
                opacity: const AlwaysStoppedAnimation(1),
              ),
            ],
          ),
        ),
        SizedBox(height: 6),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Color(0xFF46464C),
            shape: BoxShape.circle,
            border: Border.all(
              color: Color(0xFF46464C),
              width: 2.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaticWeatherMarker(Map<String, dynamic> city) {
    final temp = city['temp'] as double;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Color(0XFF2A2A2B),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Weather icon
          Icon(
            _getWeatherIconFromTemp(temp),
            color: Colors.white,
            size: 14.0,
          ),
          // Temperature
          Text(
            '${temp.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIconFromTemp(double temp) {
    if (temp <= 5) return Icons.ac_unit;
    if (temp <= 15) return Icons.cloud;
    if (temp <= 25) return Icons.wb_cloudy;
    return Icons.wb_sunny;
  }

  List<Map<String, dynamic>> _generateAdditionalCities() {
    // Generate nearby cities with mock weather data
    final centerLat = widget.centerLocation.lat;
    final centerLon = widget.centerLocation.lon;

    return [
      {
        'name': 'Nearby City 1',
        'lat': centerLat + 0.5,
        'lon': centerLon + 0.5,
        'temp': widget.currentWeather?.currentTemp != null
            ? widget.currentWeather!.currentTemp +
                (math.Random().nextDouble() - 0.5) * 10
            : 20.0,
      },
      {
        'name': 'Nearby City 2',
        'lat': centerLat - 0.3,
        'lon': centerLon + 0.7,
        'temp': widget.currentWeather?.currentTemp != null
            ? widget.currentWeather!.currentTemp +
                (math.Random().nextDouble() - 0.5) * 8
            : 18.0,
      },
      {
        'name': 'Nearby City 3',
        'lat': centerLat + 0.8,
        'lon': centerLon - 0.4,
        'temp': widget.currentWeather?.currentTemp != null
            ? widget.currentWeather!.currentTemp +
                (math.Random().nextDouble() - 0.5) * 12
            : 22.0,
      },
    ];
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

// Full screen map class
class _FullScreenMap extends StatefulWidget {
  final Location centerLocation;
  final List<HourlyForecast> forecasts;

  const _FullScreenMap({
    required this.centerLocation,
    required this.forecasts,
  });

  @override
  State<_FullScreenMap> createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<_FullScreenMap> {
  late final MapController _mapController;
  String _selectedLayer = 'precipitation'; // temperature, precipitation, wind

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(
        LatLng(widget.centerLocation.lat, widget.centerLocation.lon),
        8.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Full screen map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  LatLng(widget.centerLocation.lat, widget.centerLocation.lon),
              initialZoom: 6.0,
              minZoom: 3.0,
              maxZoom: 18.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // Mapbox tiles
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/mapbox/light-v11/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiYWRuYW5lZm91aGFtIiwiYSI6ImNrYTFvbXU5YzAyaGIzZG9jMjQ4cDJzcm0ifQ.TTC6dVvtTUyuj4MEJdbq0A',
                userAgentPackageName: 'com.celestia.app',
                maxZoom: 18,
                minZoom: 3,
              ),

              // Precipitation tile layer (conditional)
              if (_selectedLayer == 'precipitation')
                Opacity(
                  opacity: 0.7,
                  child: TileLayer(
                    key: ValueKey(
                        'fullscreen_precipitation_${_selectedLayer}_${DateTime.now().millisecondsSinceEpoch}'),
                    tileProvider: PrecipitationTileProvider(
                      apiKey: '2b82ccf3fb883f1267530199e5e0d4e6',
                    ),
                    maxZoom: 18,
                    minZoom: 3,
                  ),
                ),

              // Temperature tile layer (conditional)
              if (_selectedLayer == 'temperature')
                Opacity(
                  opacity: 0.7,
                  child: TileLayer(
                    key: ValueKey(
                        'fullscreen_temperature_${_selectedLayer}_${DateTime.now().millisecondsSinceEpoch}'),
                    tileProvider: TemperatureTileProvider(
                      apiKey: '2b82ccf3fb883f1267530199e5e0d4e6',
                    ),
                    maxZoom: 18,
                    minZoom: 3,
                  ),
                ),

              // Wind tile layer (conditional)
              if (_selectedLayer == 'wind')
                Opacity(
                  opacity: 0.7,
                  child: TileLayer(
                    key: ValueKey(
                        'fullscreen_wind_${_selectedLayer}_${DateTime.now().millisecondsSinceEpoch}'),
                    tileProvider: WindTileProvider(
                      apiKey: '2b82ccf3fb883f1267530199e5e0d4e6',
                    ),
                    maxZoom: 18,
                    minZoom: 3,
                  ),
                ),
            ],
          ),

          // Layer selection buttons (top right)
          Positioned(
            top: 50,
            right: 20,
            child: _buildFullScreenLayerButtons(),
          ),

          // Legend panel (top left)
          Positioned(
            top: 50,
            left: 20,
            child: _buildFullScreenLegendPanel(),
          ),

          // Close button
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.grey,
                  size: 20.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullScreenLayerButtons() {
    return Column(
      children: [
        _buildFullScreenLayerButton(
            'precipitation', Icons.water_drop, 'Precipitation'),
        const SizedBox(height: 8),
        _buildFullScreenLayerButton(
            'temperature', Icons.thermostat, 'Temperature'),
        const SizedBox(height: 8),
        _buildFullScreenLayerButton('wind', Icons.air, 'Wind'),
      ],
    );
  }

  Widget _buildFullScreenLayerButton(
      String layer, IconData icon, String tooltip) {
    final isSelected = _selectedLayer == layer;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLayer = layer;
        });
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF007AFF)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[700],
          size: 24.0,
        ),
      ),
    );
  }

  Widget _buildFullScreenLegendPanel() {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getFullScreenLayerTitle(),
            style: const TextStyle(
              color: Color(0xFF2A2A2B),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildFullScreenLegendScale(),
        ],
      ),
    );
  }

  String _getFullScreenLayerTitle() {
    switch (_selectedLayer) {
      case 'precipitation':
        return 'Precipitation';
      case 'temperature':
        return 'Temperature';
      case 'wind':
        return 'Wind (mph)';
      default:
        return 'Weather';
    }
  }

  Widget _buildFullScreenLegendScale() {
    switch (_selectedLayer) {
      case 'precipitation':
        return _buildFullScreenPrecipitationScale();
      case 'temperature':
        return _buildFullScreenTemperatureScale();
      case 'wind':
        return _buildFullScreenWindScale();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFullScreenPrecipitationScale() {
    return Row(
      children: [
        // Vertical gradient bar
        Container(
          width: 20,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.yellow, // Extreme (top)
                Colors.orange, // Heavy
                Colors.purple, // Moderate
                Colors.lightBlue, // Light (bottom)
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        // Labels
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Extreme', style: _getFullScreenScaleTextStyle()),
            Text('Heavy', style: _getFullScreenScaleTextStyle()),
            Text('Moderate', style: _getFullScreenScaleTextStyle()),
            Text('Light', style: _getFullScreenScaleTextStyle()),
          ],
        ),
      ],
    );
  }

  Widget _buildFullScreenTemperatureScale() {
    return Row(
      children: [
        // Vertical gradient bar
        Container(
          width: 20,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.red, // 55° (top)
                Colors.orange, // 20°
                Colors.yellow, // 10°
                Colors.lightBlue, // 0°
                Colors.blue, // -20°
                Colors.purple, // -40° (bottom)
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        // Labels
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('55°', style: _getFullScreenScaleTextStyle()),
            Text('20°', style: _getFullScreenScaleTextStyle()),
            Text('10°', style: _getFullScreenScaleTextStyle()),
            Text('0°', style: _getFullScreenScaleTextStyle()),
            Text('-20°', style: _getFullScreenScaleTextStyle()),
            Text('-40°', style: _getFullScreenScaleTextStyle()),
          ],
        ),
      ],
    );
  }

  Widget _buildFullScreenWindScale() {
    return Row(
      children: [
        // Vertical gradient bar
        Container(
          width: 20,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white, // 75 (top)
                Colors.lightBlue, // 50
                Colors.blue, // 25
                Colors.blue[900]!, // 0 (bottom)
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        // Labels
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('75', style: _getFullScreenScaleTextStyle()),
            Text('50', style: _getFullScreenScaleTextStyle()),
            Text('25', style: _getFullScreenScaleTextStyle()),
            Text('0', style: _getFullScreenScaleTextStyle()),
          ],
        ),
      ],
    );
  }

  TextStyle _getFullScreenScaleTextStyle() {
    return const TextStyle(
      color: Color(0xFF2A2A2B),
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
  }
}
