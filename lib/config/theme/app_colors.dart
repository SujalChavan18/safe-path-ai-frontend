import 'package:flutter/material.dart';

/// Dark futuristic color palette for SafePath AI.
///
/// Uses electric neon accents against deep dark surfaces
/// to create a high-tech, cyberpunk-inspired aesthetic.
class AppColors {
  AppColors._();

  // ── Primary Palette ──
  static const Color primary = Color(0xFF00E5FF);        // Electric cyan
  static const Color primaryLight = Color(0xFF6EFFFF);
  static const Color primaryDark = Color(0xFF00B2CC);

  // ── Secondary Palette ──
  static const Color secondary = Color(0xFF7C4DFF);      // Neon violet
  static const Color secondaryLight = Color(0xFFB47CFF);
  static const Color secondaryDark = Color(0xFF3F1DCB);

  // ── Accent / Tertiary ──
  static const Color accent = Color(0xFFFF6D00);         // Hot orange
  static const Color accentLight = Color(0xFFFF9E40);

  // ── Surface & Background ──
  static const Color background = Color(0xFF060610);      // Near-black
  static const Color surface = Color(0xFF0D0D1A);         // Deep charcoal
  static const Color surfaceVariant = Color(0xFF1A1A2E);  // Elevated surface
  static const Color surfaceContainer = Color(0xFF16213E); // Card background
  static const Color surfaceBright = Color(0xFF232342);    // Dialogs/sheets

  // ── On Colors (text/icons on surfaces) ──
  static const Color onPrimary = Color(0xFF000000);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFFE0E0E0);
  static const Color onSurface = Color(0xFFE0E0E0);
  static const Color onSurfaceVariant = Color(0xFFB0B0C0);

  // ── Semantic Colors ──
  static const Color error = Color(0xFFFF5252);           // Hot coral
  static const Color errorContainer = Color(0xFF3D0000);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF00E676);         // Emerald
  static const Color successContainer = Color(0xFF003D1A);
  static const Color warning = Color(0xFFFFD740);         // Amber
  static const Color warningContainer = Color(0xFF3D3000);
  static const Color info = Color(0xFF448AFF);            // Sky blue

  // ── Safety-specific Colors ──
  static const Color safeZone = Color(0xFF00E676);
  static const Color cautionZone = Color(0xFFFFD740);
  static const Color dangerZone = Color(0xFFFF5252);
  static const Color unknownZone = Color(0xFF757575);

  // ── Outline & Divider ──
  static const Color outline = Color(0xFF2A2A3D);
  static const Color outlineVariant = Color(0xFF1E1E30);
  static const Color divider = Color(0xFF1A1A2E);

  // ── Glow / Glassmorphism ──
  static const Color glowCyan = Color(0x4000E5FF);
  static const Color glowViolet = Color(0x407C4DFF);
  static const Color glassBorder = Color(0x20FFFFFF);
  static const Color glassBackground = Color(0x0DFFFFFF);

  // ── Shimmer ──
  static const Color shimmerBase = Color(0xFF1A1A2E);
  static const Color shimmerHighlight = Color(0xFF2A2A3D);

  // ── Gradient Presets ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, surfaceVariant],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Light Theme Colors (secondary priority) ──
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F0F5);
  static const Color lightOnBackground = Color(0xFF1A1A2E);
  static const Color lightOnSurface = Color(0xFF1A1A2E);
  static const Color lightOutline = Color(0xFFD0D0D5);
}
