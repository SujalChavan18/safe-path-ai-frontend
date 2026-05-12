import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Structured logging utility for SafePath AI.
///
/// Provides debug, info, warning, and error log levels
/// with timestamps. Only outputs in debug mode.
class AppLogger {
  AppLogger._();

  static const String _tag = 'SafePathAI';

  /// Debug-level log.
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(
        '🔵 $message',
        name: tag ?? _tag,
        time: DateTime.now(),
      );
    }
  }

  /// Info-level log.
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(
        '🟢 $message',
        name: tag ?? _tag,
        time: DateTime.now(),
      );
    }
  }

  /// Warning-level log.
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(
        '🟡 $message',
        name: tag ?? _tag,
        time: DateTime.now(),
        level: 900,
      );
    }
  }

  /// Error-level log.
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      developer.log(
        '🔴 $message',
        name: tag ?? _tag,
        time: DateTime.now(),
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log a network request summary.
  static void network(String method, String url, {int? statusCode}) {
    if (kDebugMode) {
      final status = statusCode != null ? ' → $statusCode' : '';
      developer.log(
        '🌐 $method $url$status',
        name: 'Network',
        time: DateTime.now(),
      );
    }
  }
}
