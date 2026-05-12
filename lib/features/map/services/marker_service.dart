import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/models/incident_model.dart';

/// Converts [IncidentModel] data into Google Maps [Marker] sets.
///
/// Provides severity-based coloring and tap callback wiring.
/// Designed for efficient rebuild — regenerates markers only when
/// the incident list changes.
class MarkerService {
  MarkerService._();

  /// Build a set of map markers from incident data.
  ///
  /// [onMarkerTap] is called with the tapped incident's ID.
  static Set<Marker> buildIncidentMarkers({
    required List<IncidentModel> incidents,
    required void Function(String incidentId) onMarkerTap,
  }) {
    return incidents.map((incident) {
      return Marker(
        markerId: MarkerId(incident.id),
        position: incident.location.toGoogleLatLng(),
        infoWindow: InfoWindow(
          title: incident.title,
          snippet: '${incident.severity.label} • ${incident.type.label}',
        ),
        icon: _getMarkerIcon(incident.severity),
        onTap: () => onMarkerTap(incident.id),
        // Z-index: higher severity = higher z-index (on top)
        zIndexInt: _getZIndex(incident.severity),
      );
    }).toSet();
  }

  /// Build a single marker for the user's current location.
  static Marker buildUserLocationMarker({
    required LatLng position,
  }) {
    return Marker(
      markerId: const MarkerId('user_location'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      infoWindow: const InfoWindow(title: 'You are here'),
      zIndexInt: 999,
    );
  }

  /// Get the appropriate marker icon based on severity.
  static BitmapDescriptor _getMarkerIcon(IncidentSeverity severity) {
    return BitmapDescriptor.defaultMarkerWithHue(severity.markerHue);
  }

  /// Higher severity incidents appear on top of lower ones.
  static int _getZIndex(IncidentSeverity severity) {
    return switch (severity) {
      IncidentSeverity.critical => 4,
      IncidentSeverity.high => 3,
      IncidentSeverity.medium => 2,
      IncidentSeverity.low => 1,
    };
  }

  /// Filter incidents by severity threshold.
  ///
  /// Only includes incidents at or above [minSeverity].
  static List<IncidentModel> filterBySeverity(
    List<IncidentModel> incidents,
    IncidentSeverity minSeverity,
  ) {
    final minIndex = IncidentSeverity.values.indexOf(minSeverity);
    return incidents
        .where((i) => IncidentSeverity.values.indexOf(i.severity) >= minIndex)
        .toList();
  }

  /// Group incidents by type for legend display.
  static Map<IncidentType, int> groupByType(List<IncidentModel> incidents) {
    final groups = <IncidentType, int>{};
    for (final incident in incidents) {
      groups[incident.type] = (groups[incident.type] ?? 0) + 1;
    }
    return groups;
  }

  /// Build a simple cluster marker representing multiple incidents.
  ///
  /// Used when multiple incidents are very close together.
  static Marker buildClusterMarker({
    required String clusterId,
    required LatLng position,
    required int count,
    required IncidentSeverity highestSeverity,
    required VoidCallback onTap,
  }) {
    return Marker(
      markerId: MarkerId('cluster_$clusterId'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(highestSeverity.markerHue),
      infoWindow: InfoWindow(
        title: '$count incidents',
        snippet: 'Tap to zoom in',
      ),
      onTap: onTap,
      zIndexInt: 5,
    );
  }
}
