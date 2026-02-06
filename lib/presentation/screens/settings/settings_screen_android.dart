import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workout/l10n/generated/app_localizations.dart';
import '../../view_models/locale_view_model.dart';
import '../../../domain/entities/app_language.dart';
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
        title: Text(AppLocalizations.of(context)!.settings),
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 24),
          _buildHeader(AppLocalizations.of(context)!.trackingZones, colors),
          const SizedBox(height: 12),
          _buildZoneTile(context, colors, vm, ZoneType.face, AppLocalizations.of(context)!.face, '👤'),
          _buildZoneTile(context, colors, vm, ZoneType.bodyFront, AppLocalizations.of(context)!.bodyFront, '🧍'),
          _buildZoneTile(context, colors, vm, ZoneType.bodySide, AppLocalizations.of(context)!.bodySide, '🧍‍♂️'),
          _buildZoneTile(context, colors, vm, ZoneType.bodyBack, AppLocalizations.of(context)!.bodyBack, '🧍‍♀️'),
          const SizedBox(height: 32),
          _buildHeader(AppLocalizations.of(context)!.additionalTracking, colors),
          const SizedBox(height: 12),
          _buildZoneTile(context, colors, vm, ZoneType.measurements, AppLocalizations.of(context)!.measurements, '📏'),
          _buildZoneTile(
            context,
            colors,
            vm,
            ZoneType.macronutrients,
            AppLocalizations.of(context)!.macronutrients,
            '🍎',
          ),
          const SizedBox(height: 32),
          _buildHeader(AppLocalizations.of(context)!.appearance, colors),
          const SizedBox(height: 12),
          _buildThemeToggle(context, colors, theme),
          const SizedBox(height: 12),
          _buildLanguageTile(context, colors),
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
          AppLocalizations.of(context)!.darkMode,
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

  Widget _buildLanguageTile(BuildContext context, AppColors colors) {
    return Card(
      elevation: 0,
      color: colors.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.border),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: () => _showLanguageDialog(context),
        leading: CircleAvatar(
          backgroundColor: colors.surface,
          child: const Text('🌍', style: TextStyle(fontSize: 20)),
        ),
        title: Text(
          AppLocalizations.of(context)!.language,
          style: TextStyle(fontSize: 17, color: colors.textPrimary, fontWeight: FontWeight.w500),
        ),
        trailing: Text(
          'Change',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.primary),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localeVm = context.read<LocaleViewModel>();
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(AppLocalizations.of(context)!.language),
        children: [
          SimpleDialogOption(
            onPressed: () {
              localeVm.setLanguage(AppLanguage.english);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(AppLocalizations.of(context)!.english),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              localeVm.setLanguage(AppLanguage.spanish);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(AppLocalizations.of(context)!.spanish),
            ),
          ),
        ],
      ),
    );
  }
}
