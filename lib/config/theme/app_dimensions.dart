/// Spacing, radius, elevation, and sizing tokens for SafePath AI.
///
/// Provides a consistent spacing scale used throughout the app
/// to maintain visual rhythm and alignment.
class AppDimensions {
  AppDimensions._();

  // ── Spacing Scale ──
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space56 = 56.0;
  static const double space64 = 64.0;

  // ── Border Radius ──
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusRound = 100.0;  // pill shape

  // ── Elevation ──
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationMax = 16.0;

  // ── Icon Sizes ──
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;
  static const double iconHero = 64.0;

  // ── Component Heights ──
  static const double buttonHeight = 52.0;
  static const double inputHeight = 52.0;
  static const double appBarHeight = 64.0;
  static const double bottomNavHeight = 72.0;
  static const double cardMinHeight = 80.0;

  // ── Component Widths ──
  static const double maxContentWidth = 600.0;
  static const double sidebarWidth = 280.0;

  // ── Border Width ──
  static const double borderThin = 0.5;
  static const double borderDefault = 1.0;
  static const double borderThick = 2.0;

  // ── Animation Durations (milliseconds) ──
  static const int animFast = 150;
  static const int animDefault = 300;
  static const int animSlow = 500;
  static const int animPage = 400;
}
