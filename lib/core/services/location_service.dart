import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// Wrapper around [Geolocator] providing location services for SafePath AI.
///
/// Handles permission requests, current position retrieval,
/// and continuous location streaming.
class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  // ── Permission Handling ──

  /// Check and request location permissions.
  ///
  /// Returns `true` if permission is granted, `false` otherwise.
  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      return false;
    }

    return true;
  }

  /// Check if location services are enabled and permitted.
  Future<bool> get isLocationAvailable async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // ── Position Retrieval ──

  /// Get the current device position.
  ///
  /// Throws if permissions are not granted.
  Future<Position> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    return Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: accuracy),
    );
  }

  /// Get the last known position (faster, may be stale).
  Future<Position?> getLastKnownPosition() async {
    return Geolocator.getLastKnownPosition();
  }

  // ── Continuous Tracking ──

  /// Stream of position updates.
  ///
  /// [distanceFilter] — minimum distance (meters) between updates.
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
    int intervalMs = 5000,
  }) {
    late final LocationSettings locationSettings;

    locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  // ── Distance Calculation ──

  /// Calculate distance in meters between two coordinates.
  double distanceBetween({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Calculate bearing between two coordinates.
  double bearingBetween({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.bearingBetween(startLat, startLng, endLat, endLng);
  }
}
