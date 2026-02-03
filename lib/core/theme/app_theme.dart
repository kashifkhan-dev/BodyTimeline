import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'color_palette.dart';

class AppTheme {
  static ThemeData materialTheme(AppColors colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: colors.brightness,
      scaffoldBackgroundColor: colors.background,

      // Dynamic ColorScheme is key for M3 consistency
      colorScheme: ColorScheme(
        brightness: colors.brightness,
        primary: colors.primary,
        onPrimary: _onColor(colors.primary, colors.brightness),
        secondary: colors.primary.withAlpha(20), // Subtle tint
        onSecondary: colors.textPrimary,
        error: colors.error,
        onError: Colors.white,
        surface: colors.card,
        onSurface: colors.textPrimary,
        surfaceContainerHighest: colors.surface, // Used for inputs/cards
        outline: colors.border,
        outlineVariant: colors.divider,
      ),

      // Text Theme with proper fallback for all platforms
      textTheme: TextTheme(
        headlineMedium: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        titleLarge: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: colors.textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: colors.textSecondary, fontSize: 14),
        labelSmall: TextStyle(color: colors.textMuted, fontSize: 11, letterSpacing: 0.5),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0, // Prevents ugly color shifts on scroll
        centerTitle: true,
        titleTextStyle: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
      ),

      // Enhanced Switch for "Workout" zones [cite: 31]
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return colors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.primary;
          return colors.border;
        }),
      ),

      // Custom card styling for the "Hoy" (Today) tasks [cite: 52]
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border, width: 1),
        ),
      ),
    );
  }

  static CupertinoThemeData cupertinoTheme(AppColors colors) {
    return CupertinoThemeData(
      brightness: colors.brightness,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.background,
      barBackgroundColor: colors.background.withOpacity(0.8),
      textTheme: CupertinoTextThemeData(
        primaryColor: colors.textPrimary,
        textStyle: TextStyle(color: colors.textPrimary, fontFamily: '.SF Pro Text'),
        navActionTextStyle: TextStyle(color: colors.primary),
        navTitleTextStyle: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Helper to determine text color on top of a colored background
  static Color _onColor(Color background, Brightness brightness) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
