/// General application-wide constants for SafePath AI.
class AppConstants {
  AppConstants._();

  // ── App Info ──
  static const String appName = 'SafePath AI';
  static const String appTagline = 'Crowdsourced Geospatial Safety & Smart Routing';
  static const String appVersion = '1.0.0';

  // ── Default Map Configuration ──
  static const double defaultLatitude = 37.7749;
  static const double defaultLongitude = -122.4194;
  static const double defaultZoom = 14.0;
  static const double maxZoom = 20.0;
  static const double minZoom = 5.0;

  // ── Map Safety Radius (meters) ──
  static const double defaultSafetyRadius = 500.0;
  static const double maxSafetyRadius = 5000.0;

  // ── Location Update Intervals ──
  static const int locationUpdateIntervalMs = 5000;
  static const double locationDistanceFilter = 10.0; // meters

  // ── Cache Duration ──
  static const int cacheDurationMinutes = 30;

  // ── Pagination ──
  static const int defaultPageSize = 20;

  // ── Notification Channels ──
  static const String alertChannelId = 'safepath_alerts';
  static const String alertChannelName = 'Safety Alerts';
  static const String alertChannelDescription = 'Notifications for safety alerts and incidents';

  // ── Secure Storage Keys ──
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
}
