import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// App-wide color palette defining raw color values.
/// No widget should use these directly; use [AppColors] via the theme instead.
class AppColorsRaw {
  // --- BASE NEUTRALS (Light) ---
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  static const Color black = Color(0xFF000000);

  // --- SEMANTIC COLORS ---

  // Semantic Green (Primary Action, Success, Completion)
  // We use a premium, deep emerald/forest green
  static const Color green50 = Color(0xFFECFDF5);
  static const Color green100 = Color(0xFFD1FAE5);
  static const Color green500 = Color(0xFF10B981);
  static const Color green600 = Color(0xFF059669);
  static const Color green700 = Color(0xFF047857);
  static const Color green800 = Color(0xFF065F46);

  // Warning (Amber)
  static const Color amber500 = Color(0xFFF59E0B);

  // Error (Red)
  static const Color red500 = Color(0xFFEF4444);

  // Info (Blue)
  static const Color blue500 = Color(0xFF3B82F6);
}

/// A structured palette that changes based on brightness.
class AppColors {
  final Brightness brightness;

  // A. Neutral Palette
  final Color background;
  final Color surface;
  final Color card;
  final Color divider;
  final Color border;

  // B. Text Palette
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;

  // C. Semantic Palette
  final Color primary;
  final Color primaryMuted;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  // D. Workout Tokens
  final Color progressActive;
  final Color progressInactive;
  final Color progressBackground;
  final Color zoneEnabled;
  final Color zoneDisabled;
  final Color completionHighlight;

  AppColors({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.card,
    required this.divider,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.primary,
    required this.primaryMuted,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.progressActive,
    required this.progressInactive,
    required this.progressBackground,
    required this.zoneEnabled,
    required this.zoneDisabled,
    required this.completionHighlight,
  });

  factory AppColors.light() {
    return AppColors(
      brightness: Brightness.light,
      background: AppColorsRaw.white,
      surface: AppColorsRaw.gray50,
      card: AppColorsRaw.white,
      divider: AppColorsRaw.gray200,
      border: AppColorsRaw.gray200,
      textPrimary: AppColorsRaw.gray900,
      textSecondary: AppColorsRaw.gray600,
      textMuted: AppColorsRaw.gray400,
      textDisabled: AppColorsRaw.gray300,
      primary: AppColorsRaw.green600,
      primaryMuted: AppColorsRaw.green100,
      success: AppColorsRaw.green600,
      warning: AppColorsRaw.amber500,
      error: AppColorsRaw.red500,
      info: AppColorsRaw.blue500,
      progressActive: AppColorsRaw.green600,
      progressInactive: AppColorsRaw.gray300,
      progressBackground: AppColorsRaw.gray100,
      zoneEnabled: AppColorsRaw.gray900,
      zoneDisabled: AppColorsRaw.gray400,
      completionHighlight: AppColorsRaw.green600,
    );
  }

  factory AppColors.dark() {
    return AppColors(
      brightness: Brightness.dark,
      background: AppColorsRaw.black,
      surface: AppColorsRaw.gray900,
      card: AppColorsRaw.gray800,
      divider: AppColorsRaw.gray800,
      border: AppColorsRaw.gray700,
      textPrimary: AppColorsRaw.gray100,
      textSecondary: AppColorsRaw.gray400,
      textMuted: AppColorsRaw.gray500,
      textDisabled: AppColorsRaw.gray600,
      primary: AppColorsRaw.green500,
      primaryMuted: AppColorsRaw.green800.withAlpha(77),
      success: AppColorsRaw.green500,
      warning: AppColorsRaw.amber500,
      error: AppColorsRaw.red500,
      info: AppColorsRaw.blue500,
      progressActive: AppColorsRaw.green500,
      progressInactive: AppColorsRaw.gray700,
      progressBackground: AppColorsRaw.gray800,
      zoneEnabled: AppColorsRaw.white,
      zoneDisabled: AppColorsRaw.gray600,
      completionHighlight: AppColorsRaw.green500,
    );
  }
}
