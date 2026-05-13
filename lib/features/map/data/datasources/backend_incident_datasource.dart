import '../../../../core/api/api_client.dart';

import '../models/incident_model.dart';
import '../models/lat_lng_model.dart';

class BackendIncidentDatasource {
  static final ApiClient _client = ApiClient.instance;

  // ─────────────────────────────────────────────
  // FETCH INCIDENTS
  // ─────────────────────────────────────────────

  static Future<List<IncidentModel>> getIncidents() async {
    final response = await _client.get(
      '/incidents',
    );

    final data = response.data as List;

    return data.map((json) {
      return IncidentModel(
        id: json['_id'] ?? '',

        title: json['category'] ?? 'Incident',

        description: json['description'] ?? '',

        location: LatLngModel(
          latitude: (json['latitude'] ?? 0).toDouble(),

          longitude: (json['longitude'] ?? 0).toDouble(),
        ),

        severity: _parseSeverity(
          json['severity'],
        ),

        type: _parseType(
          json['category'],
        ),

        reportedAt: DateTime.parse(
          json['timestamp'],
        ),

        imageUrl: json['image_url'],

        reportedBy: json['user_id'],
      );
    }).toList();
  }

  // ─────────────────────────────────────────────
  // REPORT INCIDENT
  // ─────────────────────────────────────────────

  static Future<void> submitIncident(
    IncidentModel incident,
  ) async {
    await _client.post(
      '/report',
      data: {
        'user_id': incident.reportedBy ?? 'anonymous',

        'latitude': incident.location.latitude,

        'longitude': incident.location.longitude,

        'category': incident.type.name,

        'severity': incident.severity.name,

        'description': incident.description.isEmpty
            ? 'No description provided'
            : incident.description,

        'image_url': incident.imageUrl,
      },
    );
  }

  // ─────────────────────────────────────────────
  // ENUM HELPERS
  // ─────────────────────────────────────────────

  static IncidentSeverity _parseSeverity(
    String? severity,
  ) {
    switch (severity?.toLowerCase()) {
      case 'low':
        return IncidentSeverity.low;

      case 'medium':
        return IncidentSeverity.medium;

      case 'high':
        return IncidentSeverity.high;

      case 'critical':
        return IncidentSeverity.critical;

      default:
        return IncidentSeverity.medium;
    }
  }

  static IncidentType _parseType(
    String? category,
  ) {
    switch (category?.toLowerCase()) {
      case 'theft':
        return IncidentType.theft;

      case 'assault':
        return IncidentType.assault;

      case 'harassment':
        return IncidentType.harassment;

      case 'accident':
        return IncidentType.accident;

      case 'poor_lighting':
        return IncidentType.poorLighting;

      case 'suspicious_activity':
        return IncidentType.suspiciousActivity;

      case 'natural_hazard':
        return IncidentType.naturalHazard;

      case 'road_block':
        return IncidentType.roadBlock;

      default:
        return IncidentType.other;
    }
  }
}