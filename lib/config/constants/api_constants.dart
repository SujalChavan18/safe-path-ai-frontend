/// API endpoint constants for SafePath AI.
///
/// Local backend configuration for development.
class ApiConstants {
  ApiConstants._();

  // ── Base URLs ──
  static const String baseUrl = 'http://10.0.2.2:5001/api';

  // ── Timeouts (milliseconds) ──
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // ── Auth Endpoints ──
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String userProfile = '/auth/profile';

  // ── Incident Endpoints ──
  static const String incidents = '/incidents';
  static const String reportIncident = '/report';
  static const String heatmap = '/heatmap';
  static const String safetyScore = '/safety-score';
  static const String safeRoute = '/safe-route';
  static const String alert = '/alert';
}