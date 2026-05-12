/// Central registry of all REST API endpoints for the custom backend.
///
/// This file dictates the API contract that the backend teammate must build
/// in order to serve the SafePath AI frontend perfectly.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Base URL ──
  // Use 10.0.2.2 for Android emulator connecting to local Node.js/Python server.
  // Use http://localhost:3000 for iOS simulator.
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

  // ── Auth ──
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';

  // ── User ──
  static const String userProfile = '/users/me';
  static const String updatePushToken = '/users/me/push-token';

  // ── Incidents ──
  /// GET: Returns List<IncidentModel>. Supports ?limit=x&lat=y&lng=z&radius=r
  static const String incidents = '/incidents';
  
  /// POST: Creates a new Incident.
  static const String createIncident = '/incidents';
  
  /// GET: Returns a specific Incident by ID.
  static String incidentDetail(String id) => '/incidents/$id';

  // ── Alerts (Emergency) ──
  /// POST: Triggers a high-priority emergency SOS.
  static const String triggerSos = '/alerts/sos';
  
  /// GET: Returns active emergency broadcast alerts in the area.
  static const String activeAlerts = '/alerts/active';

  // ── Media ──
  /// POST: Uploads an image (multipart/form-data) and returns the public URL.
  static const String uploadMedia = '/media/upload';
}
