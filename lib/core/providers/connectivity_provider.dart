import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Monitors network connectivity status for SafePath AI.
///
/// Listens to the system connectivity stream and exposes
/// an [isOnline] flag via [ChangeNotifier].
class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOnline = true;
  bool _isInitialized = false;

  /// Whether the device currently has network connectivity.
  bool get isOnline => _isOnline;

  /// Whether the initial connectivity check has completed.
  bool get isInitialized => _isInitialized;

  Future<void> _init() async {
    // Initial check
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);
    _isInitialized = true;
    notifyListeners();

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.isNotEmpty &&
        !results.every((r) => r == ConnectivityResult.none);

    if (wasOnline != _isOnline) {
      notifyListeners();
    }
  }

  /// Force a connectivity re-check.
  Future<void> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
