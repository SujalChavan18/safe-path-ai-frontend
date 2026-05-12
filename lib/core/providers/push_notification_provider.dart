import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../firebase/firebase_service.dart';
import '../services/notification_service.dart';
import '../utils/logger.dart';

/// Manages push notification state and FCM lifecycle for SafePath AI.
///
/// Handles:
/// - FCM permission requests
/// - Token retrieval and refresh
/// - Topic subscriptions for safety alerts
/// - Foreground message → local notification bridge
///
/// This provider is initialized after [FirebaseService.initializeMessaging()]
/// and should be accessed via `context.read<PushNotificationProvider>()`.
class PushNotificationProvider extends ChangeNotifier {
  PushNotificationProvider();

  // ═══════════════════════════════════════════════════════════
  //  STATE
  // ═══════════════════════════════════════════════════════════

  String? _fcmToken;
  bool _permissionGranted = false;
  bool _isInitialized = false;
  bool _subscribedToSafetyAlerts = false;

  StreamSubscription<RemoteMessage>? _foregroundSubscription;

  // ═══════════════════════════════════════════════════════════
  //  GETTERS
  // ═══════════════════════════════════════════════════════════

  /// The current FCM device token, or `null` if not yet obtained.
  String? get fcmToken => _fcmToken;

  /// Whether notification permissions have been granted.
  bool get permissionGranted => _permissionGranted;

  /// Whether this provider has completed initialization.
  bool get isInitialized => _isInitialized;

  /// Whether the user is subscribed to safety alert topics.
  bool get subscribedToSafetyAlerts => _subscribedToSafetyAlerts;

  // ═══════════════════════════════════════════════════════════
  //  INITIALIZATION
  // ═══════════════════════════════════════════════════════════

  /// Initialize push notifications.
  ///
  /// Requests permissions, obtains the FCM token, sets up
  /// the foreground message listener, and subscribes to
  /// default topics.
  ///
  /// Should be called after Firebase Core is initialized.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permission and get token
      _fcmToken = await FirebaseService.requestPermissionAndGetToken();
      _permissionGranted = _fcmToken != null;

      if (_permissionGranted) {
        // Listen for token refreshes
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          AppLogger.info('FCM token refreshed in provider', tag: 'Push');
          notifyListeners();
        });

        // Setup foreground message handler
        _setupForegroundListener();

        // Subscribe to default safety alerts topic
        await subscribeToSafetyAlerts();
      }

      _isInitialized = true;
      notifyListeners();

      AppLogger.info(
        'PushNotificationProvider initialized '
        '(permission: $_permissionGranted)',
        tag: 'Push',
      );
    } catch (e, st) {
      AppLogger.error(
        'PushNotificationProvider init failed: $e',
        tag: 'Push',
        error: e,
        stackTrace: st,
      );
      _isInitialized = true; // Mark as initialized even on failure
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  FOREGROUND MESSAGE HANDLING
  // ═══════════════════════════════════════════════════════════

  /// Set up the foreground message listener.
  ///
  /// When a push arrives while the app is in the foreground,
  /// this bridges it to the local notification service so the
  /// user sees a heads-up notification.
  void _setupForegroundListener() {
    _foregroundSubscription?.cancel();
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        AppLogger.info(
          'Foreground message received: ${message.messageId}',
          tag: 'Push',
        );
        _handleForegroundMessage(message);
      },
    );
  }

  /// Process a foreground FCM message.
  ///
  /// Converts the [RemoteMessage] into a local notification
  /// so the user sees it as a heads-up banner.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // Determine notification type from data payload
    final type = message.data['type'] as String?;
    final isSafetyAlert = type == 'safety_alert' || type == 'danger_alert';

    if (isSafetyAlert) {
      await NotificationService.instance.showFromRemoteMessage(
        message,
        isSafetyAlert: true,
      );
    } else {
      await NotificationService.instance.showFromRemoteMessage(message);
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  TOPIC MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  /// Topics used for safety alert notifications.
  static const String _safetyAlertsTopic = 'safety_alerts';
  static const String _generalTopic = 'general';

  /// Subscribe to safety alert notifications.
  Future<void> subscribeToSafetyAlerts() async {
    try {
      await FirebaseService.subscribeToTopic(_safetyAlertsTopic);
      await FirebaseService.subscribeToTopic(_generalTopic);
      _subscribedToSafetyAlerts = true;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to subscribe to safety alerts: $e', tag: 'Push');
    }
  }

  /// Unsubscribe from safety alert notifications.
  Future<void> unsubscribeFromSafetyAlerts() async {
    try {
      await FirebaseService.unsubscribeFromTopic(_safetyAlertsTopic);
      _subscribedToSafetyAlerts = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error(
        'Failed to unsubscribe from safety alerts: $e',
        tag: 'Push',
      );
    }
  }

  /// Subscribe to a custom topic.
  Future<void> subscribeToTopic(String topic) async {
    await FirebaseService.subscribeToTopic(topic);
  }

  /// Unsubscribe from a custom topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseService.unsubscribeFromTopic(topic);
  }

  // ═══════════════════════════════════════════════════════════
  //  PERMISSION RE-REQUEST
  // ═══════════════════════════════════════════════════════════

  /// Re-request notification permissions (e.g., from settings screen).
  ///
  /// Useful when the user initially denied permissions and later
  /// wants to enable them.
  Future<void> requestPermission() async {
    _fcmToken = await FirebaseService.requestPermissionAndGetToken();
    _permissionGranted = _fcmToken != null;

    if (_permissionGranted && _foregroundSubscription == null) {
      _setupForegroundListener();
    }

    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  //  CLEANUP
  // ═══════════════════════════════════════════════════════════

  @override
  void dispose() {
    _foregroundSubscription?.cancel();
    super.dispose();
  }
}
