import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages theme mode (dark/light) with persistence.
///
/// Persists the user's theme preference to [SharedPreferences]
/// and exposes it via [ChangeNotifier] for Provider consumption.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _loadTheme();
  }

  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.dark;

  /// Current theme mode.
  ThemeMode get themeMode => _themeMode;

  /// Whether dark mode is active.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Toggle between dark and light mode.
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _saveTheme();
    notifyListeners();
  }

  /// Set a specific theme mode.
  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _saveTheme();
    notifyListeners();
  }

  /// Load persisted theme preference.
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedTheme,
        orElse: () => ThemeMode.dark,
      );
      notifyListeners();
    }
  }

  /// Persist current theme preference.
  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _themeMode.name);
  }
}
