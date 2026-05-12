import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../config/theme/app_colors.dart';
import '../data/models/safe_route_model.dart';

/// Converts [SafeRouteModel] data into Google Maps [Polyline] sets.
///
/// Provides safety-score-based coloring and styling for route
/// visualization on the map.
class RouteService {
  RouteService._();

  /// Build a polyline from a single safe route.
  ///
  /// The polyline color is based on the route's safety rating:
  /// - Safe: green
  /// - Moderate: blue
  /// - Caution: yellow/amber
  /// - Unsafe: red
  static Polyline buildRoutePolyline({
    required SafeRouteModel route,
    bool isActive = false,
    void Function(String routeId)? onTap,
  }) {
    return Polyline(
      polylineId: PolylineId(route.id),
      points: route.waypoints.map((w) => w.toGoogleLatLng()).toList(),
      color: isActive
          ? AppColors.primary
          : route.safetyRating.color,
      width: isActive ? 6 : 4,
      patterns: isActive
          ? const []
          : [PatternItem.dash(20), PatternItem.gap(10)],
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
      consumeTapEvents: onTap != null,
      onTap: onTap != null ? () => onTap(route.id) : null,
      zIndex: isActive ? 10 : 1,
    );
  }

  /// Build polylines for multiple routes.
  ///
  /// The [activeRouteId] will be rendered as solid and wider.
  static Set<Polyline> buildRoutePolylines({
    required List<SafeRouteModel> routes,
    String? activeRouteId,
    void Function(String routeId)? onRouteTap,
  }) {
    return routes.map((route) {
      return buildRoutePolyline(
        route: route,
        isActive: route.id == activeRouteId,
        onTap: onRouteTap,
      );
    }).toSet();
  }

  /// Build start and end markers for a route.
  static Set<Marker> buildRouteEndpointMarkers(SafeRouteModel route) {
    if (route.waypoints.isEmpty) return {};

    final start = route.waypoints.first;
    final end = route.waypoints.last;

    return {
      Marker(
        markerId: MarkerId('${route.id}_start'),
        position: start.toGoogleLatLng(),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Start'),
        zIndexInt: 20,
      ),
      Marker(
        markerId: MarkerId('${route.id}_end'),
        position: end.toGoogleLatLng(),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: route.name),
        zIndexInt: 20,
      ),
    };
  }

  /// Build a camera bounds that encompasses an entire route.
  static LatLngBounds getRouteBounds(SafeRouteModel route) {
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;

    for (final point in route.waypoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// Sort routes by safety score (highest first).
  static List<SafeRouteModel> sortBySafety(List<SafeRouteModel> routes) {
    return List.from(routes)..sort((a, b) => b.safetyScore.compareTo(a.safetyScore));
  }

  /// Sort routes by distance (shortest first).
  static List<SafeRouteModel> sortByDistance(List<SafeRouteModel> routes) {
    return List.from(routes)
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
  }

  /// Sort routes by duration (fastest first).
  static List<SafeRouteModel> sortByDuration(List<SafeRouteModel> routes) {
    return List.from(routes)
      ..sort((a, b) => a.durationSeconds.compareTo(b.durationSeconds));
  }
}
