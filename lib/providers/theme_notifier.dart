import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Color theme options
enum ColorTheme {
  purple('Purple', 0xFF9333ea),
  blue('Blue', 0xFF2563eb),
  green('Green', 0xFF16a34a),
  pink('Pink', 0xFFec4899),
  indigo('Indigo', 0xFF4f46e5),
  amber('Amber', 0xFFd97706);

  final String label;
  final int color;

  const ColorTheme(this.label, this.color);

  Color get colorValue => Color(color);
}

/// Provider for managing app theme (light/dark mode and color scheme)
class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;
  ColorTheme _colorTheme = ColorTheme.purple;
  static const String _themeKey = 'theme_color';
  static const String _darkModeKey = 'dark_mode';
  late SharedPreferences _prefs;

  bool get isDarkMode => _isDarkMode;
  ColorTheme get colorTheme => _colorTheme;

  ThemeNotifier() {
    _loadTheme();
  }

  /// Load saved theme preferences
  Future<void> _loadTheme() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedTheme = _prefs.getString(_themeKey);
      if (savedTheme != null) {
        _colorTheme = ColorTheme.values.firstWhere(
          (theme) => theme.name == savedTheme,
          orElse: () => ColorTheme.purple,
        );
      }
      _isDarkMode = _prefs.getBool(_darkModeKey) ?? false;
      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print('Error loading theme: $e');
    }
  }

  /// Set color theme
  Future<void> setColorTheme(ColorTheme theme) async {
    _colorTheme = theme;
    try {
      await _prefs.setString(_themeKey, theme.name);
    } catch (e) {
      // ignore: avoid_print
      print('Error saving color theme: $e');
    }
    notifyListeners();
  }

  /// Set theme mode
  void setThemeMode(bool isDark) {
    _isDarkMode = isDark;
    _prefs.setBool(_darkModeKey, isDark);
    notifyListeners();
  }

  /// Toggle between light and dark mode
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs.setBool(_darkModeKey, _isDarkMode);
    notifyListeners();
  }

  /// Get the appropriate theme data
  ThemeData getThemeData() {
    final seedColor = _colorTheme.colorValue;

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
