import '../models/lat_lng_model.dart';
import '../models/safe_route_model.dart';

/// Mock route data source providing test safe routes.
///
/// Generates pre-built routes around San Francisco with
/// waypoints, safety scores, and distance/duration data.
///
/// Replace this with a real routing API datasource in production.
class MockRouteDatasource {
  MockRouteDatasource._();

  /// Get available safe routes between two points.
  ///
  /// Ignores [origin]/[destination] and returns mock routes
  /// for demonstration purposes.
  static Future<List<SafeRouteModel>> getRoutes({
    required LatLngModel origin,
    required LatLngModel destination,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockRoutes;
  }

  /// Get a single route by ID.
  static Future<SafeRouteModel?> getRouteById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockRoutes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  MOCK DATA — San Francisco routes
  // ═══════════════════════════════════════════════════════════

  static final List<SafeRouteModel> _mockRoutes = [
    // ── Route 1: Safest (longer, avoids Tenderloin) ──
    SafeRouteModel(
      id: 'route_001',
      name: 'Safest Route via Embarcadero',
      description: 'Avoids high-incident areas. Well-lit waterfront path.',
      waypoints: const [
        LatLngModel(latitude: 37.7749, longitude: -122.4194), // Start: Van Ness/Market
        LatLngModel(latitude: 37.7780, longitude: -122.4100),
        LatLngModel(latitude: 37.7850, longitude: -122.4020),
        LatLngModel(latitude: 37.7920, longitude: -122.3960),
        LatLngModel(latitude: 37.7955, longitude: -122.3937), // Embarcadero
        LatLngModel(latitude: 37.7980, longitude: -122.3980),
        LatLngModel(latitude: 37.8010, longitude: -122.4050),
        LatLngModel(latitude: 37.8040, longitude: -122.4100),
        LatLngModel(latitude: 37.8060, longitude: -122.4170), // End: Fisherman's Wharf
      ],
      safetyScore: 92,
      distanceMeters: 4800,
      durationSeconds: 62 * 60, // 62 min walk
      avoidedIncidents: 7,
    ),

    // ── Route 2: Balanced (moderate safety, shorter) ──
    SafeRouteModel(
      id: 'route_002',
      name: 'Balanced Route via Columbus',
      description: 'Moderate safety. Passes through North Beach neighborhood.',
      waypoints: const [
        LatLngModel(latitude: 37.7749, longitude: -122.4194), // Start
        LatLngModel(latitude: 37.7785, longitude: -122.4150),
        LatLngModel(latitude: 37.7830, longitude: -122.4110),
        LatLngModel(latitude: 37.7880, longitude: -122.4080),
        LatLngModel(latitude: 37.7940, longitude: -122.4070), // Columbus Ave
        LatLngModel(latitude: 37.7990, longitude: -122.4100),
        LatLngModel(latitude: 37.8030, longitude: -122.4130),
        LatLngModel(latitude: 37.8060, longitude: -122.4170), // End
      ],
      safetyScore: 71,
      distanceMeters: 3600,
      durationSeconds: 46 * 60,
      avoidedIncidents: 3,
    ),

    // ── Route 3: Fastest (shortest, passes through risky areas) ──
    SafeRouteModel(
      id: 'route_003',
      name: 'Fastest Route via Polk St',
      description: 'Shortest distance. Passes through Tenderloin area.',
      waypoints: const [
        LatLngModel(latitude: 37.7749, longitude: -122.4194), // Start
        LatLngModel(latitude: 37.7793, longitude: -122.4180),
        LatLngModel(latitude: 37.7824, longitude: -122.4196), // Near Civic Center
        LatLngModel(latitude: 37.7870, longitude: -122.4200),
        LatLngModel(latitude: 37.7920, longitude: -122.4195),
        LatLngModel(latitude: 37.7970, longitude: -122.4190),
        LatLngModel(latitude: 37.8020, longitude: -122.4185),
        LatLngModel(latitude: 37.8060, longitude: -122.4170), // End
      ],
      safetyScore: 38,
      distanceMeters: 3100,
      durationSeconds: 40 * 60,
      avoidedIncidents: 0,
    ),
  ];
}
