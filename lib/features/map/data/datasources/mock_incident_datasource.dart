import '../models/heatmap_point_model.dart';
import '../models/incident_model.dart';
import '../models/lat_lng_model.dart';

/// Mock incident data source providing realistic test data.
///
/// Generates 15+ incidents around San Francisco (the default map center)
/// with varying severities, types, and timestamps.
///
/// Replace this with a real API datasource in production.
class MockIncidentDatasource {
  MockIncidentDatasource._();

  /// Simulated network delay.
  static Future<List<IncidentModel>> getIncidents() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockIncidents;
  }

  /// Get incidents near a specific location within a radius.
  static Future<List<IncidentModel>> getIncidentsNear({
    required LatLngModel center,
    double radiusKm = 5.0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Simple filtering — in production use geo queries
    return _mockIncidents.where((incident) {
      final dist = incident.location.roughDistanceTo(center);
      // Rough degree-based filter (~0.01 degree ≈ 1.1km)
      return dist < (radiusKm * 0.009) * (radiusKm * 0.009);
    }).toList();
  }

  /// Convert incidents to heatmap points.
  static List<HeatmapPointModel> getHeatmapPoints() {
    return _mockIncidents.map((incident) {
      final weight = switch (incident.severity) {
        IncidentSeverity.critical => 1.0,
        IncidentSeverity.high => 0.75,
        IncidentSeverity.medium => 0.5,
        IncidentSeverity.low => 0.25,
      };
      return HeatmapPointModel(
        location: incident.location,
        weight: weight,
        type: incident.type.name,
      );
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════
  //  MOCK DATA — San Francisco area
  // ═══════════════════════════════════════════════════════════

  static final List<IncidentModel> _mockIncidents = [
    IncidentModel(
      id: 'inc_001',
      title: 'Vehicle Break-in',
      description: 'Multiple car break-ins reported along Lombard Street. Glass shattered on sidewalk.',
      location: const LatLngModel(latitude: 37.8020, longitude: -122.4194),
      severity: IncidentSeverity.high,
      type: IncidentType.theft,
      reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
      reportedBy: 'user_42',
      isVerified: true,
      upvotes: 12,
    ),
    IncidentModel(
      id: 'inc_002',
      title: 'Poor Street Lighting',
      description: 'Street lights out on the 600 block of Market St. Very dark after 8pm.',
      location: const LatLngModel(latitude: 37.7870, longitude: -122.4030),
      severity: IncidentSeverity.medium,
      type: IncidentType.poorLighting,
      reportedAt: DateTime.now().subtract(const Duration(hours: 5)),
      reportedBy: 'user_17',
      isVerified: true,
      upvotes: 8,
    ),
    IncidentModel(
      id: 'inc_003',
      title: 'Assault Near BART',
      description: 'Physical assault reported near the 16th Street BART station entrance.',
      location: const LatLngModel(latitude: 37.7650, longitude: -122.4194),
      severity: IncidentSeverity.critical,
      type: IncidentType.assault,
      reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
      reportedBy: 'user_89',
      isVerified: true,
      upvotes: 23,
    ),
    IncidentModel(
      id: 'inc_004',
      title: 'Suspicious Activity',
      description: 'Group loitering and approaching pedestrians near Dolores Park south entrance.',
      location: const LatLngModel(latitude: 37.7597, longitude: -122.4268),
      severity: IncidentSeverity.medium,
      type: IncidentType.suspiciousActivity,
      reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
      upvotes: 5,
    ),
    IncidentModel(
      id: 'inc_005',
      title: 'Traffic Accident',
      description: 'Two-car collision at the intersection of Van Ness and Market. Road partially blocked.',
      location: const LatLngModel(latitude: 37.7749, longitude: -122.4194),
      severity: IncidentSeverity.high,
      type: IncidentType.accident,
      reportedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      isVerified: true,
      upvotes: 15,
    ),
    IncidentModel(
      id: 'inc_006',
      title: 'Street Harassment',
      description: 'Verbal harassment reported on Mission Street between 5th and 6th.',
      location: const LatLngModel(latitude: 37.7830, longitude: -122.4088),
      severity: IncidentSeverity.medium,
      type: IncidentType.harassment,
      reportedAt: DateTime.now().subtract(const Duration(hours: 4)),
      upvotes: 7,
    ),
    IncidentModel(
      id: 'inc_007',
      title: 'Fallen Tree Branch',
      description: 'Large tree branch blocking sidewalk in Golden Gate Park near JFK Drive.',
      location: const LatLngModel(latitude: 37.7694, longitude: -122.4862),
      severity: IncidentSeverity.low,
      type: IncidentType.naturalHazard,
      reportedAt: DateTime.now().subtract(const Duration(hours: 8)),
      isVerified: true,
      upvotes: 3,
    ),
    IncidentModel(
      id: 'inc_008',
      title: 'Package Theft',
      description: 'Multiple package thefts from porches reported on Hayes Street.',
      location: const LatLngModel(latitude: 37.7765, longitude: -122.4250),
      severity: IncidentSeverity.medium,
      type: IncidentType.theft,
      reportedAt: DateTime.now().subtract(const Duration(hours: 6)),
      upvotes: 9,
    ),
    IncidentModel(
      id: 'inc_009',
      title: 'Road Construction',
      description: 'Major roadwork on Howard Street. Detours in effect. Expect delays.',
      location: const LatLngModel(latitude: 37.7815, longitude: -122.3990),
      severity: IncidentSeverity.low,
      type: IncidentType.roadBlock,
      reportedAt: DateTime.now().subtract(const Duration(days: 1)),
      isVerified: true,
      upvotes: 4,
    ),
    IncidentModel(
      id: 'inc_010',
      title: 'Mugging Attempt',
      description: 'Armed mugging attempt reported near Civic Center. Suspect fled on foot.',
      location: const LatLngModel(latitude: 37.7793, longitude: -122.4180),
      severity: IncidentSeverity.critical,
      type: IncidentType.assault,
      reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
      isVerified: true,
      upvotes: 31,
    ),
    IncidentModel(
      id: 'inc_011',
      title: 'Broken Sidewalk',
      description: 'Large crack and uneven pavement on Geary Blvd near Fillmore. Trip hazard.',
      location: const LatLngModel(latitude: 37.7854, longitude: -122.4323),
      severity: IncidentSeverity.low,
      type: IncidentType.naturalHazard,
      reportedAt: DateTime.now().subtract(const Duration(days: 2)),
      upvotes: 2,
    ),
    IncidentModel(
      id: 'inc_012',
      title: 'Bike Theft',
      description: 'Locked bicycle stolen from rack outside the Ferry Building.',
      location: const LatLngModel(latitude: 37.7955, longitude: -122.3937),
      severity: IncidentSeverity.medium,
      type: IncidentType.theft,
      reportedAt: DateTime.now().subtract(const Duration(hours: 12)),
      upvotes: 6,
    ),
    IncidentModel(
      id: 'inc_013',
      title: 'Unlit Alley',
      description: 'No working lights in the alley between Mission and Valencia on 20th St.',
      location: const LatLngModel(latitude: 37.7585, longitude: -122.4210),
      severity: IncidentSeverity.medium,
      type: IncidentType.poorLighting,
      reportedAt: DateTime.now().subtract(const Duration(days: 1)),
      upvotes: 11,
    ),
    IncidentModel(
      id: 'inc_014',
      title: 'Aggressive Panhandling',
      description: 'Aggressive behavior from individuals near Powell St station entrance.',
      location: const LatLngModel(latitude: 37.7845, longitude: -122.4078),
      severity: IncidentSeverity.medium,
      type: IncidentType.suspiciousActivity,
      reportedAt: DateTime.now().subtract(const Duration(hours: 7)),
      upvotes: 14,
    ),
    IncidentModel(
      id: 'inc_015',
      title: 'Hit and Run',
      description: 'Pedestrian struck by vehicle at Polk and Turk. Driver fled the scene.',
      location: const LatLngModel(latitude: 37.7824, longitude: -122.4196),
      severity: IncidentSeverity.critical,
      type: IncidentType.accident,
      reportedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      isVerified: true,
      upvotes: 27,
    ),
  ];
}
