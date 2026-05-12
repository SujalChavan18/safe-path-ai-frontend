/// API endpoint constants for SafePath AI.
///
/// Centralizes all backend URL configuration to enable
/// easy environment switching (dev / staging / prod).
class ApiConstants {
  ApiConstants._();

  // ── Base URLs ──
  static const String baseUrl = 'https://api.safepath.ai/v1';
  static const String stagingUrl = 'https://staging-api.safepath.ai/v1';

  // ── Timeouts (milliseconds) ──
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // ── Auth Endpoints ──
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // ── Map Endpoints ──
  static const String safetyZones = '/map/safety-zones';
  static const String heatmap = '/map/heatmap';
  static const String incidents = '/map/incidents';

  // ── Route Endpoints ──
  static const String safeRoute = '/routes/safe';
  static const String routeAnalysis = '/routes/analyze';

  // ── Alerts Endpoints ──
  static const String alerts = '/alerts';
  static const String reportIncident = '/alerts/report';
  static const String nearbyAlerts = '/alerts/nearby';

  // ── User Endpoints ──
  static const String userProfile = '/user/profile';
  static const String userSettings = '/user/settings';
}
