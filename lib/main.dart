import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/firebase/firebase_service.dart';
import 'core/providers/app_providers.dart';
import 'core/providers/push_notification_provider.dart';
import 'core/services/notification_service.dart';
import 'core/utils/logger.dart';

/// Application entry point for SafePath AI.
///
/// Initializes all critical services before rendering the UI:
/// 1. Flutter bindings
/// 2. System UI chrome
/// 3. Firebase Core
/// 4. Local notifications
/// 5. Global error handlers
/// 6. App launch with providers
///
/// Firebase Messaging and Push Notification Provider are initialized
/// *after* the widget tree is built, so they can access providers.
void main() {
  runZonedGuarded(
    () async {
      // ── 1. Ensure Flutter bindings ──
      WidgetsFlutterBinding.ensureInitialized();

      // ── 2. System UI styling ──
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF060610),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      // Lock to portrait orientation (optional, remove for tablets)
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // ── 3. Initialize Firebase Core ──
      try {
        await FirebaseService.initialize();
        AppLogger.info('Firebase Core initialized successfully');
      } catch (e, st) {
        AppLogger.error(
          'Firebase initialization failed',
          error: e,
          stackTrace: st,
        );
        // App can still run without Firebase for local features
      }

      // ── 4. Initialize local notifications ──
      try {
        await NotificationService.instance.initialize();
        await NotificationService.instance.requestPermission();
        AppLogger.info('Notification service initialized');
      } catch (e, st) {
        AppLogger.error('Notification init failed', error: e, stackTrace: st);
      }

      // ── 5. Global Flutter error handler ──
      FlutterError.onError = (details) {
        AppLogger.error(
          'Flutter error: ${details.exceptionAsString()}',
          error: details.exception,
          stackTrace: details.stack,
        );
      };

      // ── 6. Launch app ──
      runApp(
        MultiProvider(
          providers: AppProviders.providers,
          child: const _AppBootstrapper(),
        ),
      );
    },
    // ── Zone-level error handler (catches async errors) ──
    (error, stackTrace) {
      AppLogger.error(
        'Unhandled zone error: $error',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}

/// Bootstrapper widget that initializes Firebase Messaging and
/// Push Notifications after the provider tree is available.
///
/// This pattern is needed because FCM initialization requires
/// the widget tree to exist (for provider access), but must run
/// before the first frame is painted.
class _AppBootstrapper extends StatefulWidget {
  const _AppBootstrapper();

  @override
  State<_AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<_AppBootstrapper> {
  bool _messagingInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeMessaging();
  }

  Future<void> _initializeMessaging() async {
    if (_messagingInitialized) return;

    try {
      // Initialize Firebase Messaging with foreground handler
      // The foreground handler is managed by PushNotificationProvider,
      // so we pass null here and let the provider set it up.
      await FirebaseService.initializeMessaging();
      AppLogger.info('Firebase Messaging initialized');

      // Initialize the push notification provider
      if (mounted) {
        final pushProvider = context.read<PushNotificationProvider>();
        await pushProvider.initialize();
        AppLogger.info('PushNotificationProvider initialized');
      }

      _messagingInitialized = true;
    } catch (e, st) {
      AppLogger.error(
        'Messaging initialization failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SafePathApp();
  }
}
