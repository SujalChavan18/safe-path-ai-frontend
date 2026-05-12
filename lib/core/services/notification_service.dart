import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../config/constants/app_constants.dart';
import '../utils/logger.dart';

/// Notification callback type for handling notification taps.
typedef NotificationTapCallback = void Function(String? payload);

/// Local notification service for SafePath AI.
///
/// Manages notification channels, permissions, and display
/// for safety alerts and incident notifications.
///
/// Also bridges Firebase Cloud Messaging [RemoteMessage] payloads
/// into local notifications for foreground display.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Optional callback invoked when a notification is tapped.
  ///
  /// Set this from your routing layer to navigate on tap:
  /// ```dart
  /// NotificationService.instance.onNotificationTap = (payload) {
  ///   if (payload != null) router.push(payload);
  /// };
  /// ```
  NotificationTapCallback? onNotificationTap;

  // ═══════════════════════════════════════════════════════════
  //  INITIALIZATION
  // ═══════════════════════════════════════════════════════════

  /// Initialize the notification plugin and create channels.
  ///
  /// Must be called once during app startup.
  Future<void> initialize() async {
    if (_initialized) return;

    // ── Android Settings ──
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // ── iOS Settings ──
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // ── Create Android Notification Channels ──
    await _createChannels();

    _initialized = true;
    AppLogger.info('NotificationService initialized', tag: 'Notification');
  }

  /// Request notification permissions (primarily for iOS 10+ and Android 13+).
  Future<bool> requestPermission() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  // ═══════════════════════════════════════════════════════════
  //  FCM → LOCAL NOTIFICATION BRIDGE
  // ═══════════════════════════════════════════════════════════

  /// Convert a Firebase Cloud Messaging [RemoteMessage] into a
  /// local notification and display it.
  ///
  /// This is used when a push arrives while the app is in the
  /// foreground, since FCM does not show heads-up notifications
  /// by default in that state.
  ///
  /// [isSafetyAlert] — if `true`, uses max priority and full-screen intent.
  Future<void> showFromRemoteMessage(
    RemoteMessage message, {
    bool isSafetyAlert = false,
  }) async {
    final notification = message.notification;
    if (notification == null) return;

    final title = notification.title ?? 'SafePath AI';
    final body = notification.body ?? '';

    // Encode the message data as JSON payload for navigation on tap
    final payload = message.data.isNotEmpty
        ? jsonEncode(message.data)
        : null;

    // Use the message hash as notification ID
    final id = message.messageId?.hashCode ?? DateTime.now().hashCode;

    if (isSafetyAlert) {
      await showSafetyAlert(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );
    } else {
      await showNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );
    }

    AppLogger.info(
      'Displayed local notification from FCM: $title',
      tag: 'Notification',
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  SHOW NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════

  /// Display an immediate notification (standard priority).
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? channelId,
    String? channelName,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId ?? AppConstants.alertChannelId,
      channelName ?? AppConstants.alertChannelName,
      channelDescription: AppConstants.alertChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Display a safety alert notification with maximum priority.
  ///
  /// Uses full-screen intent on Android and critical interruption
  /// level on iOS for urgent safety alerts.
  Future<void> showSafetyAlert({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _safetyChannelId,
      _safetyChannelName,
      channelDescription: _safetyChannelDescription,
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Display a general informational notification.
  Future<void> showInfoNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _generalChannelId,
      _generalChannelName,
      channelDescription: _generalChannelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Cancel a specific notification.
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ═══════════════════════════════════════════════════════════
  //  NOTIFICATION CHANNELS
  // ═══════════════════════════════════════════════════════════

  // Safety alerts channel (high priority)
  static const String _safetyChannelId = 'safepath_safety_alerts';
  static const String _safetyChannelName = 'Safety Alerts';
  static const String _safetyChannelDescription =
      'Critical safety alerts and danger notifications';

  // General notifications channel
  static const String _generalChannelId = 'safepath_general';
  static const String _generalChannelName = 'General';
  static const String _generalChannelDescription =
      'General app notifications and updates';

  Future<void> _createChannels() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Primary alerts channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          AppConstants.alertChannelId,
          AppConstants.alertChannelName,
          description: AppConstants.alertChannelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      // Safety alerts channel (max priority)
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _safetyChannelId,
          _safetyChannelName,
          description: _safetyChannelDescription,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );

      // General notifications channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _generalChannelId,
          _generalChannelName,
          description: _generalChannelDescription,
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  NOTIFICATION TAP HANDLING
  // ═══════════════════════════════════════════════════════════

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    debugPrint('Notification tapped with payload: $payload');

    // Invoke the registered callback for navigation
    if (onNotificationTap != null && payload != null) {
      onNotificationTap!(payload);
    }
  }
}
