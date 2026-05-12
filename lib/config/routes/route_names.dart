/// Named route constants for SafePath AI.
///
/// Centralizes all route paths and names to prevent
/// string typos and enable easy refactoring.
class RouteNames {
  RouteNames._();

  // ── Route Paths ──
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  // ── Auth ──
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // ── Main Shell (bottom nav) ──
  static const String home = '/';
  static const String map = '/map';
  static const String alerts = '/alerts';
  static const String navigation = '/navigation';
  static const String profile = '/profile';

  // ── Sub-routes ──
  static const String alertDetail = 'detail/:id';
  static const String reportIncident = 'report';
  static const String settings = 'settings';
  static const String editProfile = 'edit';
  static const String routePreview = 'preview';

  // ── Route Names (for named navigation) ──
  static const String splashName = 'splash';
  static const String onboardingName = 'onboarding';
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String forgotPasswordName = 'forgotPassword';
  static const String homeName = 'home';
  static const String mapName = 'map';
  static const String alertsName = 'alerts';
  static const String alertDetailName = 'alertDetail';
  static const String reportIncidentName = 'reportIncident';
  static const String navigationName = 'navigation';
  static const String routePreviewName = 'routePreview';
  static const String profileName = 'profile';
  static const String settingsName = 'settings';
  static const String editProfileName = 'editProfile';
}
