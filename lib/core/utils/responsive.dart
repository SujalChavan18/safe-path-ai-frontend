import 'package:flutter/material.dart';

/// Responsive layout utilities for SafePath AI.
///
/// Provides breakpoint detection and adaptive layout helpers
/// for building UIs that work across phone, tablet, and desktop.
class Responsive {
  Responsive._();

  // ── Breakpoints ──
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Whether the screen is mobile-sized.
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  /// Whether the screen is tablet-sized.
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Whether the screen is desktop-sized.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopBreakpoint;

  /// Return a value based on the current breakpoint.
  ///
  /// ```dart
  /// final columns = Responsive.value(context, mobile: 1, tablet: 2, desktop: 3);
  /// ```
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktopBreakpoint) return desktop ?? tablet ?? mobile;
    if (width >= mobileBreakpoint) return tablet ?? mobile;
    return mobile;
  }

  /// Horizontal padding that adapts to screen width.
  static double horizontalPadding(BuildContext context) {
    return value(context, mobile: 16.0, tablet: 24.0, desktop: 48.0);
  }
}

/// A responsive layout builder widget.
///
/// Renders different widgets based on screen width breakpoints.
///
/// ```dart
/// ResponsiveBuilder(
///   mobile: (context) => MobileLayout(),
///   tablet: (context) => TabletLayout(),
///   desktop: (context) => DesktopLayout(),
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget Function(BuildContext) mobile;
  final Widget Function(BuildContext)? tablet;
  final Widget Function(BuildContext)? desktop;

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context) && desktop != null) {
      return desktop!(context);
    }
    if (Responsive.isTablet(context) && tablet != null) {
      return tablet!(context);
    }
    return mobile(context);
  }
}
