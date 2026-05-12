import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../config/constants/app_constants.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../alerts/domain/repositories/incident_repository.dart';
import '../../data/models/incident_model.dart';
import '../../services/heatmap_service.dart';
import '../../services/marker_service.dart';

/// Map layer visibility flags.
class MapLayers {
  const MapLayers({
    this.incidents = true,
    this.heatmap = false,
    this.safetyZones = false,
    this.routes = false,
  });

  final bool incidents;
  final bool heatmap;
  final bool safetyZones;
  final bool routes;

  MapLayers copyWith({
    bool? incidents,
    bool? heatmap,
    bool? safetyZones,
    bool? routes,
  }) {
    return MapLayers(
      incidents: incidents ?? this.incidents,
      heatmap: heatmap ?? this.heatmap,
      safetyZones: safetyZones ?? this.safetyZones,
      routes: routes ?? this.routes,
    );
  }
}

/// Central map state provider for SafePath AI.
///
/// Manages:
/// - Google Maps controller
/// - Camera position and map type
/// - Incident markers with severity coloring
/// - Heatmap circle overlays
/// - Layer visibility toggles
/// - User location tracking
/// - Selected incident state
class MapProvider extends ChangeNotifier {
  MapProvider({required IncidentRepository incidentRepository}) 
    : _incidentRepository = incidentRepository {
    _initialize();
  }

  final IncidentRepository _incidentRepository;

  // ═══════════════════════════════════════════════════════════
  //  STATE
  // ═══════════════════════════════════════════════════════════

  GoogleMapController? _mapController;
  bool _isLoading = true;
  String? _error;

  // Camera
  CameraPosition _cameraPosition = const CameraPosition(
    target: LatLng(AppConstants.defaultLatitude, AppConstants.defaultLongitude),
    zoom: AppConstants.defaultZoom,
  );
  MapType _mapType = MapType.normal;

  // Location
  LatLng? _userLocation;
  bool _isTrackingLocation = false;
  bool _locationPermissionGranted = false;
  StreamSubscription<Position>? _locationSubscription;

  // Data
  List<IncidentModel> _incidents = [];
  IncidentModel? _selectedIncident;

  // Overlays
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  MapLayers _layers = const MapLayers();
  
  // Filters (Apply to Heatmap)
  IncidentSeverity? _filterSeverity;
  IncidentType? _filterCategory;

  // ═══════════════════════════════════════════════════════════
  //  GETTERS
  // ═══════════════════════════════════════════════════════════

  GoogleMapController? get mapController => _mapController;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CameraPosition get cameraPosition => _cameraPosition;
  MapType get mapType => _mapType;

  LatLng? get userLocation => _userLocation;
  bool get isTrackingLocation => _isTrackingLocation;
  bool get locationPermissionGranted => _locationPermissionGranted;

  List<IncidentModel> get incidents => _incidents;
  IncidentModel? get selectedIncident => _selectedIncident;

  Set<Marker> get markers => _markers;
  Set<Circle> get circles => _circles;
  MapLayers get layers => _layers;

  IncidentSeverity? get filterSeverity => _filterSeverity;
  IncidentType? get filterCategory => _filterCategory;

  /// Total number of active incidents.
  int get incidentCount => _incidents.length;

  /// Count of critical/high severity incidents.
  int get criticalCount => _incidents
      .where((i) =>
          i.severity == IncidentSeverity.critical ||
          i.severity == IncidentSeverity.high)
      .length;

  // ═══════════════════════════════════════════════════════════
  //  INITIALIZATION
  // ═══════════════════════════════════════════════════════════

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check location permissions
      _locationPermissionGranted =
          await LocationService.instance.requestPermission();

      // Load mock incidents
      await loadIncidents();

      // Start location tracking if permitted
      if (_locationPermissionGranted) {
        await _getCurrentLocation();
      }

      _error = null;
    } catch (e, st) {
      _error = 'Failed to initialize map: $e';
      AppLogger.error('Map init error', error: e, stackTrace: st, tag: 'Map');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  //  MAP CONTROLLER
  // ═══════════════════════════════════════════════════════════

  /// Called when the Google Map is created.
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    AppLogger.info('Map controller created', tag: 'Map');
  }

  /// Called when the camera position changes.
  void onCameraMove(CameraPosition position) {
    _cameraPosition = position;
  }

  /// Called when camera movement is idle.
  void onCameraIdle() {
    // Could trigger incident refresh based on visible bounds
  }

  // ═══════════════════════════════════════════════════════════
  //  INCIDENTS
  // ═══════════════════════════════════════════════════════════

  /// Load incidents from the data source.
  Future<void> loadIncidents() async {
    try {
      _incidents = await _incidentRepository.getIncidents();
      _rebuildOverlays();
      AppLogger.info('Loaded ${_incidents.length} incidents', tag: 'Map');
    } catch (e) {
      AppLogger.error('Failed to load incidents: $e', tag: 'Map');
    }
  }

  /// Select an incident (e.g., from marker tap).
  void selectIncident(String incidentId) {
    _selectedIncident = _incidents
        .cast<IncidentModel?>()
        .firstWhere(
          (i) => i?.id == incidentId,
          orElse: () => null,
        );
    notifyListeners();
  }

  /// Clear the selected incident.
  void clearSelectedIncident() {
    _selectedIncident = null;
    notifyListeners();
  }

  /// Get an incident by ID.
  IncidentModel? getIncidentById(String id) {
    try {
      return _incidents.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  LAYERS
  // ═══════════════════════════════════════════════════════════

  /// Toggle a map layer on/off.
  void toggleLayer({
    bool? incidents,
    bool? heatmap,
    bool? safetyZones,
    bool? routes,
  }) {
    _layers = _layers.copyWith(
      incidents: incidents,
      heatmap: heatmap,
      safetyZones: safetyZones,
      routes: routes,
    );
    _rebuildOverlays();
    notifyListeners();
  }

  /// Set filters for the heatmap layer.
  void setFilters({
    IncidentSeverity? severity,
    IncidentType? category,
  }) {
    _filterSeverity = severity;
    _filterCategory = category;
    _rebuildOverlays();
  }

  /// Clear all heatmap filters.
  void clearFilters() {
    _filterSeverity = null;
    _filterCategory = null;
    _rebuildOverlays();
  }

  /// Toggle map type (normal / satellite / terrain).
  void toggleMapType() {
    _mapType = switch (_mapType) {
      MapType.normal => MapType.satellite,
      MapType.satellite => MapType.terrain,
      _ => MapType.normal,
    };
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  //  LOCATION
  // ═══════════════════════════════════════════════════════════

  /// Get the current device location and center the map.
  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationService.instance.getCurrentPosition();
      _userLocation = LatLng(position.latitude, position.longitude);
      notifyListeners();
    } catch (e) {
      AppLogger.warning('Failed to get location: $e', tag: 'Map');
    }
  }

  /// Center the map on the user's current location.
  Future<void> goToCurrentLocation() async {
    if (!_locationPermissionGranted) {
      _locationPermissionGranted =
          await LocationService.instance.requestPermission();
      if (!_locationPermissionGranted) return;
    }

    await _getCurrentLocation();

    if (_userLocation != null) {
      await animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _userLocation!,
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  /// Start continuous location tracking.
  void startLocationTracking() {
    if (_isTrackingLocation) return;

    _locationSubscription = LocationService.instance
        .getPositionStream(
      distanceFilter: AppConstants.locationDistanceFilter.toInt(),
      intervalMs: AppConstants.locationUpdateIntervalMs,
    )
        .listen(
      (position) {
        _userLocation = LatLng(position.latitude, position.longitude);
        _rebuildOverlays(); // Update user marker
        notifyListeners();
      },
      onError: (e) {
        AppLogger.error('Location stream error: $e', tag: 'Map');
      },
    );

    _isTrackingLocation = true;
    notifyListeners();
    AppLogger.info('Location tracking started', tag: 'Map');
  }

  /// Stop continuous location tracking.
  void stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _isTrackingLocation = false;
    notifyListeners();
    AppLogger.info('Location tracking stopped', tag: 'Map');
  }

  // ═══════════════════════════════════════════════════════════
  //  CAMERA
  // ═══════════════════════════════════════════════════════════

  /// Animate the camera to a new position.
  Future<void> animateCamera(CameraUpdate update) async {
    await _mapController?.animateCamera(update);
  }

  /// Move the camera to a specific location.
  Future<void> goToLocation(LatLng target, {double zoom = 15.0}) async {
    await animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  /// Fit the camera to show all incident markers.
  Future<void> fitAllIncidents() async {
    if (_incidents.isEmpty) return;

    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final incident in _incidents) {
      final lat = incident.location.latitude;
      final lng = incident.location.longitude;
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    await animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        60, // padding
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  OVERLAY REBUILDING
  // ═══════════════════════════════════════════════════════════

  /// Rebuild all map overlays based on current data and layer visibility.
  void _rebuildOverlays() {
    _markers = {};
    _circles = {};

    // ── Incident markers ──
    if (_layers.incidents) {
      _markers = MarkerService.buildIncidentMarkers(
        incidents: _incidents,
        onMarkerTap: selectIncident,
      );
    }

    // ── User location marker ──
    if (_userLocation != null) {
      _markers.add(MarkerService.buildUserLocationMarker(
        position: _userLocation!,
      ));
    }

    // ── Heatmap circles ──
    if (_layers.heatmap) {
      // Filter incidents before generating heatmap points
      final filteredIncidents = _incidents.where((i) {
        if (_filterSeverity != null && i.severity != _filterSeverity) return false;
        if (_filterCategory != null && i.type != _filterCategory) return false;
        return true;
      }).toList();

      final filteredHeatmapPoints = HeatmapService.getHeatmapPoints(filteredIncidents);

      _circles = HeatmapService.buildHeatmapCircles(
        points: filteredHeatmapPoints,
      );
    }

    // ── Safety radius around user ──
    if (_userLocation != null && _layers.safetyZones) {
      _circles.addAll(HeatmapService.buildSafetyRadiusCircles(
        center: _userLocation!,
        radiusMeters: AppConstants.defaultSafetyRadius,
      ));
    }

    notifyListeners();
  }

  /// Force a full data refresh.
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    await loadIncidents();
    if (_locationPermissionGranted) {
      await _getCurrentLocation();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  //  CLEANUP
  // ═══════════════════════════════════════════════════════════

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}
