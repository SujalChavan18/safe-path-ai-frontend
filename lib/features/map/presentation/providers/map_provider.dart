import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/datasources/backend_incident_datasource.dart';
import '../../data/models/incident_model.dart';
import '../../services/marker_service.dart';

class MapProvider extends ChangeNotifier {
  // MAP CONTROLLER

  GoogleMapController? _mapController;

  GoogleMapController? get mapController => _mapController;

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  // CAMERA

  CameraPosition _cameraPosition = const CameraPosition(
    target: LatLng(12.9716, 77.5946),
    zoom: 14,
  );

  CameraPosition get cameraPosition => _cameraPosition;

  // USER LOCATION

  LatLng? _userLocation;

  LatLng? get userLocation => _userLocation;

  Position? _currentPosition;

  Position? get currentPosition => _currentPosition;

  bool _isTrackingLocation = false;

  bool get isTrackingLocation => _isTrackingLocation;

  // INCIDENTS

  List<IncidentModel> _incidents = [];

  List<IncidentModel> get incidents => _incidents;

  IncidentModel? _selectedIncident;

  IncidentModel? get selectedIncident => _selectedIncident;

  // LOADING

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _error;

  String? get error => _error;

  // FILTERS

  IncidentSeverity? _filterSeverity;

  IncidentSeverity? get filterSeverity => _filterSeverity;

  IncidentType? _filterCategory;

  IncidentType? get filterCategory => _filterCategory;

  // LAYERS

  final Map<String, bool> _layers = {
    'incidents': true,
    'heatmap': true,
    'safetyZones': true,
  };

  Map<String, bool> get layers => _layers;

  // MARKERS

  Set<Marker> get markers {
    return MarkerService.buildIncidentMarkers(
      incidents: filteredIncidents,
      onMarkerTap: selectIncident,
    );
  }

  // CIRCLES

  Set<Circle> get circles {
    return filteredIncidents.map((incident) {
      return Circle(
        circleId: CircleId(incident.id),
        center: LatLng(
          incident.location.latitude,
          incident.location.longitude,
        ),
        radius: 100,
        fillColor: Colors.red.withOpacity(0.15),
        strokeColor: Colors.red,
        strokeWidth: 1,
      );
    }).toSet();
  }

  // COUNTS

  int get incidentCount => _incidents.length;

  int get criticalCount {
    return _incidents
        .where(
          (i) => i.severity == IncidentSeverity.critical,
        )
        .length;
  }

  // FILTERED INCIDENTS

  List<IncidentModel> get filteredIncidents {
    return _incidents.where((incident) {
      final severityMatch =
          _filterSeverity == null ||
              incident.severity == _filterSeverity;

      final categoryMatch =
          _filterCategory == null ||
              incident.type == _filterCategory;

      return severityMatch && categoryMatch;
    }).toList();
  }

  // CONSTRUCTOR

  MapProvider();

  // INITIALIZE

  Future<void> initialize() async {
    await fetchCurrentLocation();
    await fetchIncidents();
  }

  // LOCATION

  Future<void> fetchCurrentLocation() async {
    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) return;

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission ==
              LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        return;
      }

      _currentPosition =
          await Geolocator.getCurrentPosition();

      _userLocation = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> goToCurrentLocation() async {
    await fetchCurrentLocation();

    if (_mapController == null ||
        _userLocation == null) {
      return;
    }

    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _userLocation!,
          zoom: 16,
        ),
      ),
    );
  }

  void startLocationTracking() {
    _isTrackingLocation = true;
    notifyListeners();
  }

  void stopLocationTracking() {
    _isTrackingLocation = false;
    notifyListeners();
  }

  // INCIDENTS

  Future<void> fetchIncidents() async {
    try {
      _isLoading = true;
      notifyListeners();

      _incidents =
          await BackendIncidentDatasource
              .getIncidents();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await initialize();
  }

  // INCIDENT SELECTION

  void selectIncident(String id) {
    try {
      _selectedIncident = _incidents.firstWhere(
        (i) => i.id == id,
      );

      notifyListeners();
    } catch (_) {}
  }

  void clearSelectedIncident() {
    _selectedIncident = null;
    notifyListeners();
  }

  // FILTERS

  void setFilters({
    IncidentSeverity? severity,
    IncidentType? category,
  }) {
    _filterSeverity = severity;
    _filterCategory = category;

    notifyListeners();
  }

  // LAYERS

  void toggleLayer({
    bool? incidents,
    bool? heatmap,
    bool? safetyZones,
  }) {
    if (incidents != null) {
      _layers['incidents'] = incidents;
    }

    if (heatmap != null) {
      _layers['heatmap'] = heatmap;
    }

    if (safetyZones != null) {
      _layers['safetyZones'] = safetyZones;
    }

    notifyListeners();
  }

  // MAP TYPE

  MapType _mapType = MapType.normal;

  MapType get mapType => _mapType;

  void toggleMapType() {
    switch (_mapType) {
      case MapType.normal:
        _mapType = MapType.satellite;
        break;

      case MapType.satellite:
        _mapType = MapType.terrain;
        break;

      case MapType.terrain:
        _mapType = MapType.hybrid;
        break;

      case MapType.hybrid:
        _mapType = MapType.normal;
        break;

      default:
        _mapType = MapType.normal;
    }

    notifyListeners();
  }

  // FIT INCIDENTS

  Future<void> fitAllIncidents() async {
    if (_mapController == null ||
        _incidents.isEmpty) {
      return;
    }

    final first = _incidents.first;

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(
          first.location.latitude,
          first.location.longitude,
        ),
        12,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}