import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:provider/provider.dart';
import '../view_models/settings_view_model.dart';
import '../../domain/value_objects/zone_type.dart';
import '../../core/theme/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);
    final config = vm.config;

    if (config == null) {
      return Center(child: CupertinoActivityIndicator(color: colors.primary));
    }

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text('Settings', style: TextStyle(color: colors.textPrimary)),
            backgroundColor: colors.background.withAlpha(200),
            border: Border(bottom: BorderSide(color: colors.border)),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 24),
                Text(
                  'TRACKING ZONES',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildZoneTile(context, colors, vm, ZoneType.face, 'Face', '👤'),
                _buildZoneTile(context, colors, vm, ZoneType.bodyFront, 'Body Front', '🧍'),
                _buildZoneTile(context, colors, vm, ZoneType.bodySide, 'Body Side', '🧍‍♂️'),
                _buildZoneTile(context, colors, vm, ZoneType.bodyBack, 'Body Back', '🧍‍♀️'),
                const SizedBox(height: 32),
                Text(
                  'ADDITIONAL TRACKING',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildZoneTile(context, colors, vm, ZoneType.measurements, 'Measurements', '📏'),
                _buildZoneTile(context, colors, vm, ZoneType.macronutrients, 'Macronutrients', '🍎'),
                const SizedBox(height: 48),
                Text(
                  'APPEARANCE',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildThemeToggle(context, colors, theme),
                const SizedBox(height: 120), // Bottom padding for tab bar
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneTile(
    BuildContext context,
    dynamic colors,
    SettingsViewModel vm,
    ZoneType zone,
    String label,
    String emoji,
  ) {
    final isEnabled = vm.config?.isEnabled(zone) ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 17, color: colors.textPrimary, fontWeight: FontWeight.w500),
              ),
            ),
            CNSwitch(value: isEnabled, onChanged: (val) => vm.toggleZone(zone, val)),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, dynamic colors, ThemeProvider theme) {
    final isDark = theme.themeMode == ThemeMode.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Icon(
              isDark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
              color: colors.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Dark Mode',
              style: TextStyle(fontSize: 17, color: colors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
          CNSwitch(value: isDark, onChanged: (val) => theme.setThemeMode(val ? ThemeMode.dark : ThemeMode.light)),
        ],
      ),
    );
  }
}
