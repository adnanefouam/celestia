import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class WindTileProvider extends TileProvider {
  final String apiKey;
  final String baseUrl = 'https://tile.openweathermap.org/map/wind_new';

  WindTileProvider({required this.apiKey});

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return _WindTileImage(
      coordinates: coordinates,
      options: options,
      apiKey: apiKey,
      baseUrl: baseUrl,
    );
  }

  @override
  String getTileUrl(TileCoordinates coordinates, TileLayer options) {
    return '$baseUrl/${coordinates.z}/${coordinates.x}/${coordinates.y}.png?appid=$apiKey';
  }

  Future<WindTileProvider> obtainKey(ImageConfiguration configuration) {
    return Future.value(this);
  }
}

class _WindTileImage extends ImageProvider<_WindTileImage> {
  final TileCoordinates coordinates;
  final TileLayer options;
  final String apiKey;
  final String baseUrl;

  _WindTileImage({
    required this.coordinates,
    required this.options,
    required this.apiKey,
    required this.baseUrl,
  });

  @override
  ImageStreamCompleter loadImage(
      _WindTileImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: 1.0,
    );
  }

  Future<ui.Codec> _loadAsync(_WindTileImage key) async {
    final uri = _getTileUrl(key.coordinates);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        return await ui.instantiateImageCodec(bytes);
      } else {
        // Return empty tile if request fails
        return await _createEmptyTile();
      }
    } catch (e) {
      // Return empty tile if request fails
      return await _createEmptyTile();
    }
  }

  Future<ui.Codec> _createEmptyTile() async {
    // Create a transparent 256x256 pixel tile
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.transparent;
    canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);
    final picture = recorder.endRecording();
    final image = await picture.toImage(256, 256);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return await ui.instantiateImageCodec(byteData!.buffer.asUint8List());
  }

  Uri _getTileUrl(TileCoordinates coordinates) {
    return Uri.parse(
      '$baseUrl/${coordinates.z}/${coordinates.x}/${coordinates.y}.png?appid=$apiKey',
    );
  }

  @override
  Future<_WindTileImage> obtainKey(ImageConfiguration configuration) {
    return Future.value(this);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is _WindTileImage &&
        other.coordinates == coordinates &&
        other.apiKey == apiKey;
  }

  @override
  int get hashCode => Object.hash(coordinates, apiKey);
}
