import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'app_theme.dart';
import 'color_palette.dart';
import 'theme_persistence.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider(ThemeMode initialMode) {
    _themeMode = initialMode;
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await ThemePersistence.saveThemeMode(mode);
    notifyListeners();
  }

  /// Returns the appropriate [AppColors] based on current theme mode and context.
  AppColors colors(BuildContext context) {
    final brightness = _getCurrentBrightness(context);
    return brightness == Brightness.light ? AppColors.light() : AppColors.dark();
  }

  /// Material ThemeData
  ThemeData materialTheme(BuildContext context) {
    return AppTheme.materialTheme(colors(context));
  }

  /// Cupertino Theme
  CupertinoThemeData cupertinoTheme(BuildContext context) {
    return AppTheme.cupertinoTheme(colors(context));
  }

  Brightness _getCurrentBrightness(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context);
    }
    return _themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light;
  }

  /// Helper to toggle theme
  void toggleTheme(BuildContext context) {
    final currentBrightness = _getCurrentBrightness(context);
    setThemeMode(currentBrightness == Brightness.light ? ThemeMode.dark : ThemeMode.light);
  }
}
