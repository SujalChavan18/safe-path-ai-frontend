import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/presentation/widgets/custom_bottom_nav.dart';
import '../../features/alerts/presentation/screens/alert_detail_screen.dart';
import '../../features/alerts/presentation/screens/alert_history_screen.dart';
import '../../features/alerts/presentation/screens/report_incident_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import 'route_names.dart';

/// GoRouter configuration for SafePath AI.
///
/// Defines the complete navigation graph with:
/// - Splash / onboarding / auth flows
/// - ShellRoute for bottom navigation scaffold
/// - Nested sub-routes per feature
/// - Auth redirect guard
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  /// The top-level router instance consumed by [MaterialApp.router].
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: _authGuard,
    routes: [
      // ── Splash ──
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splashName,
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Onboarding ──
      GoRoute(
        path: RouteNames.onboarding,
        name: RouteNames.onboardingName,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Onboarding'),
      ),

      // ── Auth ──
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: RouteNames.registerName,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: RouteNames.forgotPasswordName,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ── Main Shell (bottom navigation) ──
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) =>
            _MainShellScaffold(child: child),
        routes: [
          // Home
          GoRoute(
            path: RouteNames.home,
            name: RouteNames.homeName,
            pageBuilder: (context, state) => _buildFadeTransitionPage(
              state: state,
              child: const HomeScreen(),
            ),
          ),

          // Map
          GoRoute(
            path: RouteNames.map,
            name: RouteNames.mapName,
            pageBuilder: (context, state) => _buildFadeTransitionPage(
              state: state,
              child: const MapScreen(),
            ),
          ),

          // Alerts (with sub-routes)
          GoRoute(
            path: RouteNames.alerts,
            name: RouteNames.alertsName,
            pageBuilder: (context, state) => _buildFadeTransitionPage(
              state: state,
              child: const AlertHistoryScreen(),
            ),
            routes: [
              GoRoute(
                path: RouteNames.alertDetail,
                name: RouteNames.alertDetailName,
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return AlertDetailScreen(alertId: id);
                },
              ),
              GoRoute(
                path: RouteNames.reportIncident,
                name: RouteNames.reportIncidentName,
                builder: (context, state) => const ReportIncidentScreen(),
              ),
            ],
          ),

          // Navigation
          GoRoute(
            path: RouteNames.navigation,
            name: RouteNames.navigationName,
            pageBuilder: (context, state) => _buildFadeTransitionPage(
              state: state,
              child: const _PlaceholderScreen(title: 'Navigation'),
            ),
            routes: [
              GoRoute(
                path: RouteNames.routePreview,
                name: RouteNames.routePreviewName,
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Route Preview'),
              ),
            ],
          ),

          // Profile (with sub-routes)
          GoRoute(
            path: RouteNames.profile,
            name: RouteNames.profileName,
            pageBuilder: (context, state) => _buildFadeTransitionPage(
              state: state,
              child: const _PlaceholderScreen(title: 'Profile'),
            ),
            routes: [
              GoRoute(
                path: RouteNames.settings,
                name: RouteNames.settingsName,
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Settings'),
              ),
              GoRoute(
                path: RouteNames.editProfile,
                name: RouteNames.editProfileName,
                builder: (context, state) =>
                    const _PlaceholderScreen(title: 'Edit Profile'),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => _PlaceholderScreen(
      title: '404 — ${state.error?.message ?? "Page not found"}',
    ),
  );

  /// Auth guard redirect.
  ///
  /// Stub implementation — replace with actual [AuthProvider] check.
  static String? _authGuard(BuildContext context, GoRouterState state) {
    // TODO: Inject AuthProvider and check authentication state.
    // final isLoggedIn = context.read<AuthProvider>().isAuthenticated;
    // final isAuthRoute = state.matchedLocation == RouteNames.login ||
    //     state.matchedLocation == RouteNames.register;
    //
    // if (!isLoggedIn && !isAuthRoute) return RouteNames.login;
    // if (isLoggedIn && isAuthRoute) return RouteNames.home;
    return null; // No redirect
  }

  /// Helper to create a smooth fade transition between bottom navigation tabs.
  static CustomTransitionPage _buildFadeTransitionPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  TEMPORARY PLACEHOLDER WIDGETS
//  Replace these with actual screens as features are built.
// ═════════════════════════════════════════════════════════════

/// Placeholder screen used during architecture scaffolding.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Screen under construction',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shell scaffold providing the bottom navigation bar.
class _MainShellScaffold extends StatelessWidget {
  const _MainShellScaffold({required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(RouteNames.map)) return 1;
    if (location.startsWith(RouteNames.alerts)) return 2;
    if (location.startsWith(RouteNames.navigation)) return 3;
    if (location.startsWith(RouteNames.profile)) return 4;
    return 0; // Home
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      extendBody: true, // Allows content to flow under the floating nav bar
      body: child,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: index,
        onTap: (i) => _onTap(context, i),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
      case 1:
        context.go(RouteNames.map);
      case 2:
        context.go(RouteNames.alerts);
      case 3:
        context.go(RouteNames.navigation);
      case 4:
        context.go(RouteNames.profile);
    }
  }
}
