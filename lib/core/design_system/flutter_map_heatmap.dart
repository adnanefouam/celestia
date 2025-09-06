import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';
import 'package:celestia/core/design_system/app_colors.dart';
import 'package:celestia/core/design_system/app_spacing.dart';
import 'package:celestia/core/design_system/app_typography.dart';
import 'package:celestia/core/models/forecast_data.dart';
import 'package:celestia/core/models/location.dart';

class FlutterMapHeatmap extends StatefulWidget {
  final Location centerLocation;
  final List<HourlyForecast> forecasts;
  final double radius; // Radius around center location in kilometers

  const FlutterMapHeatmap({
    super.key,
    required this.centerLocation,
    required this.forecasts,
    this.radius = 120.0, // 50km radius by default
  });

  @override
  State<FlutterMapHeatmap> createState() => _FlutterMapHeatmapState();
}

class _FlutterMapHeatmapState extends State<FlutterMapHeatmap> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Auto-zoom to the city location after the map is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoZoomToCity();
    });
  }

  void _autoZoomToCity() {
    _mapController.move(
      LatLng(widget.centerLocation.lat, widget.centerLocation.lon),
      12.0, // Zoom level for city view
    );
  }

  void _toggleExpanded() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => _FullScreenMap(
          centerLocation: widget.centerLocation,
          forecasts: widget.forecasts,
        ),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.forecasts.isEmpty) {
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
            'No temperature data available for heatmap',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Hero(
      tag: 'mapHero_${widget.centerLocation.lat}_${widget.centerLocation.lon}',
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textSecondary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                      widget.centerLocation.lat, widget.centerLocation.lon),
                  initialZoom: 10.0,
                  minZoom: 6.0,
                  maxZoom: 16.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                  onTap: (tapPosition, point) {
                    // Auto-zoom to the tapped location
                    _mapController.move(point, 14.0);
                  },
                ),
                children: [
                  // Mapbox tiles as base layer
                  TileLayer(
                    urlTemplate:
                        'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiYWRuYW5lZm91aGFtIiwiYSI6ImNrYTFvbXU5YzAyaGIzZG9jMjQ4cDJzcm0ifQ.TTC6dVvtTUyuj4MEJdbq0A',
                    userAgentPackageName: 'com.celestia.app',
                    minZoom: 6,
                    maxZoom: 12,
                  ),

                  // Heatmap as tile layer
                  HeatMapLayer(
                    heatMapDataSource: InMemoryHeatMapDataSource(
                      data: _generateHeatmapPoints(),
                    ),
                    heatMapOptions: HeatMapOptions(
                      gradient: {
                        0.0: Colors.purple, // Cool
                        0.5: Colors.indigo, // Transition
                        1.0: Colors.blue, // Warm
                      },
                      minOpacity: 0.1,
                    ),
                    maxZoom: 12.0,
                  ),

                  // Center location marker
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(widget.centerLocation.lat,
                            widget.centerLocation.lon),
                        width: 20,
                        height: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Expand Button
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _toggleExpanded,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.fullscreen,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<WeightedLatLng> _generateHeatmapPoints() {
    final points = <WeightedLatLng>[];

    // Get temperature range for intensity mapping
    final temps = widget.forecasts.map((f) => f.temp).toList();
    final minTemp = temps.reduce((a, b) => a < b ? a : b);
    final maxTemp = temps.reduce((a, b) => a > b ? a : b);
    final tempRange = maxTemp - minTemp;

    // Use actual forecast data points - create multiple points around each forecast location
    // to simulate temperature distribution in the area
    for (int i = 0; i < widget.forecasts.length && i < 8; i++) {
      final forecast = widget.forecasts[i];

      // Create a cluster of points around the center location for this forecast
      // This simulates how temperature varies in the surrounding area
      for (int j = 0; j < 5; j++) {
        final angle =
            (j * 2 * math.pi) / 5 + (i * 0.1); // Slight offset per forecast
        final distance = (j + 1) * 0.01; // Small distance variations

        // Calculate position relative to center
        final lat = widget.centerLocation.lat + (math.cos(angle) * distance);
        final lon = widget.centerLocation.lon + (math.sin(angle) * distance);

        // Calculate intensity based on temperature
        final intensity = tempRange > 0
            ? ((forecast.temp - minTemp) / tempRange).clamp(0.0, 1.0)
            : 0.5;

        points.add(WeightedLatLng(LatLng(lat, lon), intensity));
      }
    }

    return points;
  }
}

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

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Hero(
        tag:
            'mapHero_${widget.centerLocation.lat}_${widget.centerLocation.lon}',
        child: Stack(
          children: [
            // Full screen map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(
                    widget.centerLocation.lat, widget.centerLocation.lon),
                initialZoom: 12.0,
                minZoom: 6.0,
                maxZoom: 16.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                // Mapbox tiles as base layer
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiYWRuYW5lZm91aGFtIiwiYSI6ImNrYTFvbXU5YzAyaGIzZG9jMjQ4cDJzcm0ifQ.TTC6dVvtTUyuj4MEJdbq0A',
                  userAgentPackageName: 'com.celestia.app',
                  minZoom: 6,
                  maxZoom: 16,
                ),

                // Heatmap layer (if forecasts available)
                if (widget.forecasts.isNotEmpty)
                  HeatMapLayer(
                    heatMapDataSource: InMemoryHeatMapDataSource(
                      data: _generateHeatmapPoints(),
                    ),
                    heatMapOptions: HeatMapOptions(
                      gradient: {
                        0.0: Colors.purple, // Cool
                        0.5: Colors.indigo, // Transition
                        1.0: Colors.blue, // Warm
                      },
                      minOpacity: 0.1,
                    ),
                    maxZoom: 12.0,
                  ),

                // Center location marker
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                          widget.centerLocation.lat, widget.centerLocation.lon),
                      width: 30,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Close Button
            Positioned(
              top: 50,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close,
                    size: 24,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // Scale Icon
            Positioned(
              bottom: 100,
              left: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.straighten,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '1km',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<WeightedLatLng> _generateHeatmapPoints() {
    final points = <WeightedLatLng>[];

    // Get temperature range for intensity mapping
    final temperatures =
        widget.forecasts.map((f) => f.temperature.temp).toList();
    final minTemp = temperatures.reduce((a, b) => a < b ? a : b);
    final maxTemp = temperatures.reduce((a, b) => a > b ? a : b);
    final tempRange = maxTemp - minTemp;

    // Generate heatmap points for each forecast
    for (final forecast in widget.forecasts.take(8)) {
      final temp = forecast.temperature.temp;
      final intensity = tempRange > 0 ? (temp - minTemp) / tempRange : 0.5;

      // Create a cluster of points around the center location
      final centerLat = widget.centerLocation.lat;
      final centerLon = widget.centerLocation.lon;
      final radius = 0.01; // ~1km radius

      // Generate multiple points in a cluster
      for (int i = 0; i < 5; i++) {
        final angle = (i * 2 * 3.14159) / 5; // Distribute points in a circle
        final distance = radius * (0.3 + (i * 0.1)); // Vary distance
        final lat = centerLat + (distance * math.cos(angle));
        final lon = centerLon + (distance * math.sin(angle));

        points.add(WeightedLatLng(LatLng(lat, lon), intensity));
      }
    }

    return points;
  }
}
