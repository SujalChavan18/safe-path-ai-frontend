import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

/// Serializable latitude/longitude coordinate for SafePath AI.
///
/// Wraps a geographic coordinate pair with JSON serialization
/// and conversion to Google Maps [LatLng].
class LatLngModel {
  const LatLngModel({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  /// Create from a JSON map.
  factory LatLngModel.fromJson(Map<String, dynamic> json) {
    return LatLngModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  /// Convert to a JSON map.
  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  /// Convert to a Google Maps [LatLng].
  gmaps.LatLng toGoogleLatLng() => gmaps.LatLng(latitude, longitude);

  /// Create from a Google Maps [LatLng].
  factory LatLngModel.fromGoogleLatLng(gmaps.LatLng latLng) {
    return LatLngModel(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
    );
  }

  /// Calculate a rough distance indicator (not geodesic).
  /// For accurate distance, use [LocationService.distanceBetween].
  double roughDistanceTo(LatLngModel other) {
    final dLat = latitude - other.latitude;
    final dLng = longitude - other.longitude;
    return (dLat * dLat + dLng * dLng);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLngModel &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'LatLngModel($latitude, $longitude)';
}
