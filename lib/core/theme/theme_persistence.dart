import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePersistence {
  static const String _themeKey = 'user_theme_mode';

  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeKey);

    if (themeName == null) return ThemeMode.system;

    return ThemeMode.values.firstWhere((m) => m.name == themeName, orElse: () => ThemeMode.system);
  }
}
