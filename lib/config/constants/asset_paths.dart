/// Asset path constants for SafePath AI.
///
/// Centralizes all asset references so changes to asset
/// locations only need updating in one place.
class AssetPaths {
  AssetPaths._();

  // ── Base Paths ──
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _animations = 'assets/animations';

  // ── Logo & Branding ──
  static const String logo = '$_images/logo.png';
  static const String logoDark = '$_images/logo_dark.png';
  static const String splash = '$_images/splash.png';

  // ── Map Markers ──
  static const String markerSafe = '$_icons/marker_safe.png';
  static const String markerDanger = '$_icons/marker_danger.png';
  static const String markerUser = '$_icons/marker_user.png';
  static const String markerIncident = '$_icons/marker_incident.png';

  // ── Empty States ──
  static const String emptyAlerts = '$_images/empty_alerts.png';
  static const String emptyMap = '$_images/empty_map.png';
  static const String noConnection = '$_images/no_connection.png';
  static const String errorState = '$_images/error_state.png';

  // ── Animations ──
  static const String loadingAnimation = '$_animations/loading.json';
  static const String successAnimation = '$_animations/success.json';
  static const String locationPulse = '$_animations/location_pulse.json';
}
