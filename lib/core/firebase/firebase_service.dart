import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../utils/logger.dart';
import 'firebase_options.dart';

/// Top-level background message handler.
///
/// Must be a top-level function (not a class method) for Firebase.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AppLogger.info(
    'Background message received: ${message.messageId}',
    tag: 'FCM',
  );
  // Processing is handled by the notification service
  // which is initialized separately in main.dart
}

/// Firebase initialization and instance management for SafePath AI.
///
/// Provides a single point of initialization for all Firebase services
/// and exposes singleton accessors for Auth, Firestore, and FCM.
///
/// **Initialization order in main.dart:**
/// 1. `FirebaseService.initialize()` — core + Firestore
/// 2. `FirebaseService.initializeMessaging()` — FCM (call after auth ready)
///
/// ```dart
/// await FirebaseService.initialize();
/// // ...later, after auth provider is registered...
/// await FirebaseService.initializeMessaging();
/// ```
class FirebaseService {
  FirebaseService._();

  static bool _coreInitialized = false;
  static bool _messagingInitialized = false;

  // ═══════════════════════════════════════════════════════════
  //  INITIALIZATION
  // ═══════════════════════════════════════════════════════════

  /// Initialize Firebase Core and Firestore settings.
  ///
  /// Must be called after `WidgetsFlutterBinding.ensureInitialized()`.
  static Future<void> initialize() async {
    if (_coreInitialized) return;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // ── Firestore Settings ──
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    _coreInitialized = true;
    AppLogger.info('Firebase Core initialized', tag: 'Firebase');
  }

  /// Initialize Firebase Cloud Messaging.
  ///
  /// Call this separately after Firebase Core is ready.
  /// Sets up background handler, foreground presentation, and token refresh.
  ///
  /// [onForegroundMessage] — optional callback invoked when a push
  /// arrives while the app is in the foreground.
  static Future<void> initializeMessaging({
    void Function(RemoteMessage)? onForegroundMessage,
  }) async {
    if (_messagingInitialized) return;
    if (!_coreInitialized) {
      throw StateError(
        'FirebaseService.initialize() must be called before initializeMessaging()',
      );
    }

    // ── Background handler (must be top-level) ──
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ── Foreground presentation options (iOS) ──
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // ── Foreground message listener ──
    if (onForegroundMessage != null) {
      FirebaseMessaging.onMessage.listen(onForegroundMessage);
    }

    // ── Token refresh listener ──
    messaging.onTokenRefresh.listen((newToken) {
      AppLogger.info('FCM token refreshed', tag: 'FCM');
      _onTokenRefresh(newToken);
    });

    // ── Handle notification tap when app was terminated ──
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      AppLogger.info(
        'App opened from terminated state via notification: '
        '${initialMessage.messageId}',
        tag: 'FCM',
      );
      // TODO: Route to appropriate screen based on message data
    }

    // ── Handle notification tap when app is in background ──
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      AppLogger.info(
        'Notification tapped (background): ${message.messageId}',
        tag: 'FCM',
      );
      // TODO: Route to appropriate screen based on message data
    });

    _messagingInitialized = true;
    AppLogger.info('Firebase Messaging initialized', tag: 'FCM');
  }

  // ═══════════════════════════════════════════════════════════
  //  INSTANCE ACCESSORS
  // ═══════════════════════════════════════════════════════════

  /// Firebase Authentication instance.
  static FirebaseAuth get auth => FirebaseAuth.instance;

  /// Cloud Firestore instance.
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Firebase Cloud Messaging instance.
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;

  // ═══════════════════════════════════════════════════════════
  //  FIRESTORE COLLECTION REFERENCES
  // ═══════════════════════════════════════════════════════════

  /// Users collection.
  static CollectionReference<Map<String, dynamic>> get usersCollection =>
      firestore.collection('users');

  /// Incidents collection.
  static CollectionReference<Map<String, dynamic>> get incidentsCollection =>
      firestore.collection('incidents');

  /// Safety zones collection.
  static CollectionReference<Map<String, dynamic>> get safetyZonesCollection =>
      firestore.collection('safety_zones');

  /// Alerts collection.
  static CollectionReference<Map<String, dynamic>> get alertsCollection =>
      firestore.collection('alerts');

  /// Routes collection.
  static CollectionReference<Map<String, dynamic>> get routesCollection =>
      firestore.collection('routes');

  // ═══════════════════════════════════════════════════════════
  //  AUTH HELPERS
  // ═══════════════════════════════════════════════════════════

  /// Current authenticated user (null if not signed in).
  static User? get currentUser => auth.currentUser;

  /// Stream of auth state changes.
  static Stream<User?> get authStateChanges => auth.authStateChanges();

  /// Whether a user is currently signed in.
  static bool get isAuthenticated => currentUser != null;

  // ═══════════════════════════════════════════════════════════
  //  FCM — TOKEN MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  /// Request notification permissions and return the FCM token.
  ///
  /// Returns `null` if permission is denied.
  static Future<String?> requestPermissionAndGetToken() async {
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      final token = await messaging.getToken();
      AppLogger.info('FCM token obtained: ${token?.substring(0, 20)}...', tag: 'FCM');
      return token;
    }

    AppLogger.warning('FCM permission denied', tag: 'FCM');
    return null;
  }

  /// Save the current FCM token to the authenticated user's Firestore document.
  ///
  /// Should be called after successful authentication and on token refresh.
  static Future<void> saveFcmTokenToFirestore() async {
    final user = currentUser;
    if (user == null) return;

    try {
      final token = await messaging.getToken();
      if (token == null) return;

      await usersCollection.doc(user.uid).set(
        {
          'fcmTokens': FieldValue.arrayUnion([token]),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      AppLogger.info('FCM token saved to Firestore', tag: 'FCM');
    } catch (e) {
      AppLogger.error('Failed to save FCM token: $e', tag: 'FCM');
    }
  }

  /// Remove the current FCM token from the user's Firestore document.
  ///
  /// Should be called on sign-out to stop push notifications.
  static Future<void> removeFcmTokenFromFirestore() async {
    final user = currentUser;
    if (user == null) return;

    try {
      final token = await messaging.getToken();
      if (token == null) return;

      await usersCollection.doc(user.uid).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
      AppLogger.info('FCM token removed from Firestore', tag: 'FCM');
    } catch (e) {
      AppLogger.error('Failed to remove FCM token: $e', tag: 'FCM');
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  FCM — TOPIC SUBSCRIPTIONS
  // ═══════════════════════════════════════════════════════════

  /// Subscribe to a messaging topic for group notifications.
  ///
  /// Common topics: `safety_alerts`, `route_updates`, `general`.
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await messaging.subscribeToTopic(topic);
      AppLogger.info('Subscribed to topic: $topic', tag: 'FCM');
    } catch (e) {
      AppLogger.error('Failed to subscribe to topic $topic: $e', tag: 'FCM');
    }
  }

  /// Unsubscribe from a messaging topic.
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await messaging.unsubscribeFromTopic(topic);
      AppLogger.info('Unsubscribed from topic: $topic', tag: 'FCM');
    } catch (e) {
      AppLogger.error('Failed to unsubscribe from topic $topic: $e', tag: 'FCM');
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  FCM — USER DOCUMENT MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  /// Create or update the user's Firestore profile document.
  ///
  /// Called after first registration or when profile data changes.
  static Future<void> createUserDocument(User user) async {
    final docRef = usersCollection.doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSignIn': FieldValue.serverTimestamp(),
        'fcmTokens': <String>[],
        'safetyScore': 0,
        'incidentsReported': 0,
        'routesCompleted': 0,
      });
    } else {
      await docRef.update({
        'lastSignIn': FieldValue.serverTimestamp(),
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
      });
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════

  /// Called when the FCM token is refreshed.
  static Future<void> _onTokenRefresh(String newToken) async {
    if (isAuthenticated) {
      await saveFcmTokenToFirestore();
    }
  }

  /// Whether Firebase Core has been initialized.
  static bool get isCoreInitialized => _coreInitialized;

  /// Whether Firebase Messaging has been initialized.
  static bool get isMessagingInitialized => _messagingInitialized;

  /// Reset initialization flags (for testing only).
  @visibleForTesting
  static void reset() {
    _coreInitialized = false;
    _messagingInitialized = false;
  }
}
