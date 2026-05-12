import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

/// ┌────────────────────────────────────────────────────────────┐
/// │  PLACEHOLDER — Replace with generated Firebase options     │
/// │                                                            │
/// │  Run the following commands to generate the real file:      │
/// │                                                            │
/// │    dart pub global activate flutterfire_cli                 │
/// │    flutterfire configure                                    │
/// │                                                            │
/// │  This will overwrite this file with your actual Firebase    │
/// │  project configuration for each platform.                  │
/// └────────────────────────────────────────────────────────────┘
class DefaultFirebaseOptions {
  /// Returns the [FirebaseOptions] for the current platform.
  ///
  /// Throws [UnsupportedError] until `flutterfire configure` has been run.
  static FirebaseOptions get currentPlatform {
    // TODO: Remove this placeholder after running `flutterfire configure`.
    // The CLI will replace this entire file with real credentials.

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _android;
      case TargetPlatform.iOS:
        return _ios;
      case TargetPlatform.macOS:
        return _macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for '
          '${defaultTargetPlatform.name}. '
          'Run `flutterfire configure` to generate this file.',
        );
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  PLACEHOLDER OPTIONS — Replace with your actual values
  //  These use empty strings so the app compiles but Firebase
  //  will fail to initialize until replaced.
  // ═══════════════════════════════════════════════════════════

  static const FirebaseOptions _android = FirebaseOptions(
    apiKey: 'YOUR-ANDROID-API-KEY',
    appId: 'YOUR-ANDROID-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
  );

  static const FirebaseOptions _ios = FirebaseOptions(
    apiKey: 'YOUR-IOS-API-KEY',
    appId: 'YOUR-IOS-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
    iosBundleId: 'YOUR-IOS-BUNDLE-ID',
  );

  static const FirebaseOptions _macos = FirebaseOptions(
    apiKey: 'YOUR-MACOS-API-KEY',
    appId: 'YOUR-MACOS-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
    iosBundleId: 'YOUR-MACOS-BUNDLE-ID',
  );
}
