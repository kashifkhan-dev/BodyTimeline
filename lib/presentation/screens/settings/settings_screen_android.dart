import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/settings_view_model.dart';
import '../../../domain/value_objects/zone_type.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_palette.dart';

class SettingsScreenAndroid extends StatelessWidget {
  const SettingsScreenAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);
    final config = vm.config;

    if (config == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 24),
          _buildHeader('Tracking Zones', colors),
          const SizedBox(height: 12),
          _buildZoneTile(context, colors, vm, ZoneType.face, 'Face', '👤'),
          _buildZoneTile(context, colors, vm, ZoneType.bodyFront, 'Body Front', '🧍'),
          _buildZoneTile(context, colors, vm, ZoneType.bodySide, 'Body Side', '🧍‍♂️'),
          _buildZoneTile(context, colors, vm, ZoneType.bodyBack, 'Body Back', '🧍‍♀️'),
          const SizedBox(height: 32),
          _buildHeader('Additional Tracking', colors),
          const SizedBox(height: 12),
          _buildZoneTile(context, colors, vm, ZoneType.measurements, 'Measurements', '📏'),
          _buildZoneTile(context, colors, vm, ZoneType.macronutrients, 'Macronutrients', '🍎'),
          const SizedBox(height: 32),
          _buildHeader('Appearance', colors),
          const SizedBox(height: 12),
          _buildThemeToggle(context, colors, theme),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, AppColors colors) {
    return Text(
      title,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.primary, letterSpacing: 0.5),
    );
  }

  Widget _buildZoneTile(
    BuildContext context,
    AppColors colors,
    SettingsViewModel vm,
    ZoneType zone,
    String label,
    String emoji,
  ) {
    final isEnabled = vm.config?.isEnabled(zone) ?? false;
    return Card(
      elevation: 0,
      color: colors.card,
      margin: const EdgeInsets.symmetric(vertical: 4),
      clipBehavior: Clip.antiAlias, // Ensures splash is clipped to card boundaries
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.border),
      ),
      child: SwitchListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), // Matches splash to corner radius
        secondary: CircleAvatar(
          backgroundColor: colors.surface,
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(
          label,
          style: TextStyle(fontSize: 17, color: colors.textPrimary, fontWeight: FontWeight.w500),
        ),
        value: isEnabled,
        onChanged: (val) => vm.toggleZone(zone, val),
        activeThumbColor: colors.primary,
        activeTrackColor: colors.primary.withAlpha(50),
        inactiveTrackColor: colors.surface,
        inactiveThumbColor: colors.textMuted,
        trackOutlineColor: WidgetStateProperty.all(colors.border),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, AppColors colors, ThemeProvider theme) {
    final isDark = theme.themeMode == ThemeMode.dark;
    return Card(
      elevation: 0,
      color: colors.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.border),
      ),
      child: SwitchListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        secondary: CircleAvatar(
          backgroundColor: colors.surface,
          child: Icon(isDark ? Icons.brightness_3 : Icons.brightness_7, color: colors.textPrimary, size: 20),
        ),
        title: Text(
          'Dark Mode',
          style: TextStyle(fontSize: 17, color: colors.textPrimary, fontWeight: FontWeight.w500),
        ),
        value: isDark,
        onChanged: (val) => theme.setThemeMode(val ? ThemeMode.dark : ThemeMode.light),
        activeThumbColor: colors.primary,
        activeTrackColor: colors.primary.withAlpha(50),
        inactiveTrackColor: colors.surface,
        inactiveThumbColor: colors.textMuted,
        trackOutlineColor: WidgetStateProperty.all(colors.border),
      ),
    );
  }
}
