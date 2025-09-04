import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

@JsonSerializable()
class Location extends Equatable {
  final double lat;
  final double lon;
  final String name;
  final String? country;
  final String? state;

  const Location({
    required this.lat,
    required this.lon,
    required this.name,
    this.country,
    this.state,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);

  @override
  List<Object?> get props => [lat, lon, name, country, state];

  Location copyWith({
    double? lat,
    double? lon,
    String? name,
    String? country,
    String? state,
  }) {
    return Location(
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      name: name ?? this.name,
      country: country ?? this.country,
      state: state ?? this.state,
    );
  }

  String get displayName {
    if (country != null && state != null) {
      return '$name, $state, $country';
    } else if (country != null) {
      return '$name, $country';
    } else if (state != null) {
      return '$name, $state';
    }
    return name;
  }

  String get coordinates =>
      '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
}
