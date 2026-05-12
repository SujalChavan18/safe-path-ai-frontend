import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/utils/logger.dart';
import '../../data/datasources/mock_route_datasource.dart';
import '../../data/models/lat_lng_model.dart';
import '../../data/models/safe_route_model.dart';
import '../../services/route_service.dart';

/// Navigation state for the active route session.
enum NavigationStatus {
  /// No navigation active.
  idle,

  /// Loading available routes.
  loadingRoutes,

  /// Routes loaded — user choosing.
  routesReady,

  /// Active navigation in progress.
  navigating,

  /// Navigation completed.
  completed,

  /// Error occurred.
  error,
}

/// Route sort preference.
enum RouteSortMode {
  safety,
  distance,
  duration,
}

/// Manages route selection, visualization, and active navigation state.
///
/// Works alongside [MapProvider] — this provider's polylines and
/// endpoint markers should be merged into the map's overlay sets.
class NavigationProvider extends ChangeNotifier {
  NavigationProvider();

  // ═══════════════════════════════════════════════════════════
  //  STATE
  // ═══════════════════════════════════════════════════════════

  NavigationStatus _status = NavigationStatus.idle;
  String? _error;

  // Route data
  List<SafeRouteModel> _availableRoutes = [];
  SafeRouteModel? _selectedRoute;
  RouteSortMode _sortMode = RouteSortMode.safety;

  // Overlays
  Set<Polyline> _polylines = {};
  Set<Marker> _routeMarkers = {};

  // Navigation progress
  int _currentWaypointIndex = 0;
  double _distanceRemaining = 0;
  int _timeRemainingSeconds = 0;

  // ═══════════════════════════════════════════════════════════
  //  GETTERS
  // ═══════════════════════════════════════════════════════════

  NavigationStatus get status => _status;
  String? get error => _error;

  List<SafeRouteModel> get availableRoutes => _availableRoutes;
  SafeRouteModel? get selectedRoute => _selectedRoute;
  RouteSortMode get sortMode => _sortMode;

  Set<Polyline> get polylines => _polylines;
  Set<Marker> get routeMarkers => _routeMarkers;

  bool get isNavigating => _status == NavigationStatus.navigating;
  bool get hasRoutes => _availableRoutes.isNotEmpty;

  int get currentWaypointIndex => _currentWaypointIndex;
  double get distanceRemaining => _distanceRemaining;
  int get timeRemainingSeconds => _timeRemainingSeconds;

  /// Human-readable remaining distance.
  String get distanceRemainingFormatted {
    if (_distanceRemaining < 1000) {
      return '${_distanceRemaining.toStringAsFixed(0)}m';
    }
    return '${(_distanceRemaining / 1000).toStringAsFixed(1)}km';
  }

  /// Human-readable remaining time.
  String get timeRemainingFormatted {
    final minutes = (_timeRemainingSeconds / 60).ceil();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    return '${hours}h ${remaining}m';
  }

  // ═══════════════════════════════════════════════════════════
  //  ROUTE LOADING
  // ═══════════════════════════════════════════════════════════

  /// Load available routes between two points.
  Future<void> loadRoutes({
    required LatLngModel origin,
    required LatLngModel destination,
  }) async {
    _status = NavigationStatus.loadingRoutes;
    _error = null;
    notifyListeners();

    try {
      _availableRoutes = await MockRouteDatasource.getRoutes(
        origin: origin,
        destination: destination,
      );

      // Sort by current preference
      _sortRoutes();

      // Auto-select safest route
      if (_availableRoutes.isNotEmpty) {
        selectRoute(_availableRoutes.first.id);
      }

      _status = NavigationStatus.routesReady;
      AppLogger.info(
        'Loaded ${_availableRoutes.length} routes',
        tag: 'Navigation',
      );
    } catch (e, st) {
      _error = 'Failed to load routes: $e';
      _status = NavigationStatus.error;
      AppLogger.error('Route load error', error: e, stackTrace: st, tag: 'Navigation');
    }

    notifyListeners();
  }

  /// Reload routes with the current origin/destination.
  Future<void> loadMockRoutes() async {
    await loadRoutes(
      origin: const LatLngModel(latitude: 37.7749, longitude: -122.4194),
      destination: const LatLngModel(latitude: 37.8060, longitude: -122.4170),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  ROUTE SELECTION
  // ═══════════════════════════════════════════════════════════

  /// Select a route by ID and rebuild overlays.
  void selectRoute(String routeId) {
    try {
      _selectedRoute = _availableRoutes.firstWhere((r) => r.id == routeId);
      _distanceRemaining = _selectedRoute!.distanceMeters;
      _timeRemainingSeconds = _selectedRoute!.durationSeconds;
      _currentWaypointIndex = 0;
      _rebuildOverlays();
      notifyListeners();
    } catch (_) {
      AppLogger.warning('Route not found: $routeId', tag: 'Navigation');
    }
  }

  /// Clear the selected route.
  void clearSelectedRoute() {
    _selectedRoute = null;
    _polylines = {};
    _routeMarkers = {};
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  //  SORTING
  // ═══════════════════════════════════════════════════════════

  /// Change the route sort preference.
  void setSortMode(RouteSortMode mode) {
    _sortMode = mode;
    _sortRoutes();
    notifyListeners();
  }

  void _sortRoutes() {
    _availableRoutes = switch (_sortMode) {
      RouteSortMode.safety =>
        RouteService.sortBySafety(_availableRoutes),
      RouteSortMode.distance =>
        RouteService.sortByDistance(_availableRoutes),
      RouteSortMode.duration =>
        RouteService.sortByDuration(_availableRoutes),
    };
  }

  // ═══════════════════════════════════════════════════════════
  //  NAVIGATION CONTROL
  // ═══════════════════════════════════════════════════════════

  /// Start active navigation on the selected route.
  void startNavigation() {
    if (_selectedRoute == null) return;

    _status = NavigationStatus.navigating;
    _currentWaypointIndex = 0;
    _distanceRemaining = _selectedRoute!.distanceMeters;
    _timeRemainingSeconds = _selectedRoute!.durationSeconds;

    _rebuildOverlays();
    notifyListeners();

    AppLogger.info(
      'Navigation started on: ${_selectedRoute!.name}',
      tag: 'Navigation',
    );
  }

  /// Stop the active navigation.
  void stopNavigation() {
    _status = NavigationStatus.routesReady;
    _currentWaypointIndex = 0;
    _rebuildOverlays();
    notifyListeners();

    AppLogger.info('Navigation stopped', tag: 'Navigation');
  }

  /// Simulate advancing to the next waypoint.
  ///
  /// In production, this would be triggered by location updates.
  void advanceWaypoint() {
    if (_selectedRoute == null) return;
    if (_currentWaypointIndex >= _selectedRoute!.waypoints.length - 1) {
      _status = NavigationStatus.completed;
      notifyListeners();
      return;
    }

    _currentWaypointIndex++;

    // Approximate remaining distance and time
    final totalWaypoints = _selectedRoute!.waypoints.length;
    final progress = _currentWaypointIndex / totalWaypoints;
    _distanceRemaining =
        _selectedRoute!.distanceMeters * (1 - progress);
    _timeRemainingSeconds =
        (_selectedRoute!.durationSeconds * (1 - progress)).round();

    notifyListeners();
  }

  /// Reset navigation to idle state and clear all route data.
  void reset() {
    _status = NavigationStatus.idle;
    _availableRoutes = [];
    _selectedRoute = null;
    _polylines = {};
    _routeMarkers = {};
    _currentWaypointIndex = 0;
    _distanceRemaining = 0;
    _timeRemainingSeconds = 0;
    _error = null;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  //  OVERLAY BUILDING
  // ═══════════════════════════════════════════════════════════

  void _rebuildOverlays() {
    if (_availableRoutes.isEmpty) {
      _polylines = {};
      _routeMarkers = {};
      return;
    }

    // Build polylines for all routes (active one highlighted)
    _polylines = RouteService.buildRoutePolylines(
      routes: _availableRoutes,
      activeRouteId: _selectedRoute?.id,
      onRouteTap: selectRoute,
    );

    // Build endpoint markers for the selected route
    _routeMarkers = {};
    if (_selectedRoute != null) {
      _routeMarkers = RouteService.buildRouteEndpointMarkers(_selectedRoute!);
    }
  }

  /// Get camera bounds for the selected route.
  LatLngBounds? getSelectedRouteBounds() {
    if (_selectedRoute == null) return null;
    return RouteService.getRouteBounds(_selectedRoute!);
  }
}
