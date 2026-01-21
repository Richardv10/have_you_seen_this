import 'package:flutter/material.dart';

/// Provider for managing app theme (light/dark mode)
class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  /// Set theme mode
  void setThemeMode(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }

  /// Toggle between light and dark mode
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  /// Get the appropriate theme data
  ThemeData getThemeData() {
    const seedColor = Colors.deepPurple;

    if (_isDarkMode) {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
      );
    } else {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
      );
    }
  }
}
