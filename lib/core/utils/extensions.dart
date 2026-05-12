import 'package:flutter/material.dart';

/// Convenience extensions for SafePath AI.

// ═════════════════════════════════════════════════════════════
//  BuildContext Extensions
// ═════════════════════════════════════════════════════════════

extension ContextExtensions on BuildContext {
  /// Quick access to [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Quick access to [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Quick access to [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Screen size.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Screen width.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Screen height.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Top padding (status bar).
  double get topPadding => MediaQuery.paddingOf(this).top;

  /// Bottom padding (home indicator / nav bar).
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;

  /// Whether the keyboard is visible.
  bool get isKeyboardVisible => MediaQuery.viewInsetsOf(this).bottom > 0;

  /// Show a snackbar.
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }

  /// Show a success snackbar.
  void showSuccess(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF00E676),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
//  String Extensions
// ═════════════════════════════════════════════════════════════

extension StringExtensions on String {
  /// Capitalize the first letter.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Convert to title case.
  String get titleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Truncate with ellipsis.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}…';
  }

  /// Check if string is a valid email.
  bool get isEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(this);

  /// Check if string is numeric.
  bool get isNumeric => double.tryParse(this) != null;
}

// ═════════════════════════════════════════════════════════════
//  DateTime Extensions
// ═════════════════════════════════════════════════════════════

extension DateTimeExtensions on DateTime {
  /// Format as relative time (e.g., "2 hours ago").
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  /// Whether this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Whether this date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}

// ═════════════════════════════════════════════════════════════
//  Num Extensions
// ═════════════════════════════════════════════════════════════

extension NumExtensions on num {
  /// Convert meters to a human-readable distance string.
  String get distanceString {
    if (this < 1000) return '${toStringAsFixed(0)}m';
    return '${(this / 1000).toStringAsFixed(1)}km';
  }

  /// Convert to duration string (seconds → "Xm Ys").
  String get durationString {
    final minutes = (this / 60).floor();
    final seconds = (toInt() % 60);
    if (minutes == 0) return '${seconds}s';
    return '${minutes}m ${seconds}s';
  }
}
