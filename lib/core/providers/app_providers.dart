import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/alerts/data/repositories/incident_repository_impl.dart';
import '../../features/alerts/data/repositories/mock_alert_repository.dart';
import '../../features/alerts/presentation/providers/alert_provider.dart';
import '../../features/alerts/presentation/providers/report_incident_provider.dart';
import '../../features/map/presentation/providers/map_provider.dart';
import '../../features/map/presentation/providers/navigation_provider.dart';
import '../api/backend_auth_service.dart';
import 'auth_provider.dart';
import 'connectivity_provider.dart';
import 'push_notification_provider.dart';
import 'theme_provider.dart';

/// Top-level providers for SafePath AI.
///
/// This list is consumed by [MultiProvider] in `main.dart`.
class AppProviders {
  AppProviders._();

  static List<SingleChildWidget> get providers => [
        // ── Core Providers ──
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => ConnectivityProvider(),
        ),

        // ── Auth ──
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: BackendAuthService(),
          ),
        ),

        // ── Push Notifications ──
        ChangeNotifierProvider(
          create: (_) => PushNotificationProvider(),
        ),

        // ── Feature Providers ──
        ChangeNotifierProvider(
          create: (_) => MapProvider(
            incidentRepository: IncidentRepositoryImpl(),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => NavigationProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => ReportIncidentProvider(
            repository: IncidentRepositoryImpl(),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => AlertProvider(
            repository: MockAlertRepository(),
          )..loadAlerts(),
        ),
      ];
}