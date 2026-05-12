import 'package:flutter/material.dart';

/// Temporary simplified connectivity provider.
///
/// Always assumes internet is available.
/// Useful during backend integration/testing.
class ConnectivityProvider extends ChangeNotifier {
  bool get isOnline => true;

  bool get isInitialized => true;

  Future<void> checkConnectivity() async {}
}