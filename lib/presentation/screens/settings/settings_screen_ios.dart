import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:provider/provider.dart';
import '../../view_models/settings_view_model.dart';
import '../../../domain/value_objects/zone_type.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_palette.dart';
import 'package:workout/l10n/generated/app_localizations.dart';
import '../../view_models/locale_view_model.dart';
import '../../../domain/entities/app_language.dart';

class SettingsScreenIOS extends StatelessWidget {
  const SettingsScreenIOS({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);
    final config = vm.config;

    if (config == null) {
      return Container(
        color: colors.background,
        child: const Center(child: CupertinoActivityIndicator()),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(AppLocalizations.of(context)!.settings, style: TextStyle(color: colors.textPrimary)),
            backgroundColor: colors.background.withAlpha(200),
            border: Border(bottom: BorderSide(color: colors.border)),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 24),
                _buildHeader(AppLocalizations.of(context)!.trackingZones.toUpperCase(), colors),
                const SizedBox(height: 12),
                _buildZoneTile(context, colors, vm, ZoneType.face, AppLocalizations.of(context)!.face, '👤'),
                _buildZoneTile(context, colors, vm, ZoneType.bodyFront, AppLocalizations.of(context)!.bodyFront, '🧍'),
                _buildZoneTile(context, colors, vm, ZoneType.bodySide, AppLocalizations.of(context)!.bodySide, '🧍‍♂️'),
                _buildZoneTile(context, colors, vm, ZoneType.bodyBack, AppLocalizations.of(context)!.bodyBack, '🧍‍♀️'),
                const SizedBox(height: 32),
                _buildHeader(AppLocalizations.of(context)!.additionalTracking.toUpperCase(), colors),
                const SizedBox(height: 12),
                _buildZoneTile(
                  context,
                  colors,
                  vm,
                  ZoneType.measurements,
                  AppLocalizations.of(context)!.measurements,
                  '📏',
                ),
                _buildZoneTile(
                  context,
                  colors,
                  vm,
                  ZoneType.macronutrients,
                  AppLocalizations.of(context)!.macronutrients,
                  '🍎',
                ),
                const SizedBox(height: 48),
                _buildHeader(AppLocalizations.of(context)!.appearance.toUpperCase(), colors),
                const SizedBox(height: 12),
                _buildThemeToggle(context, colors, theme),
                const SizedBox(height: 12),
                _buildLanguageTile(context, colors),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, AppColors colors) {
    return Text(
      title,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textMuted, letterSpacing: 0.5),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            CNSwitch(value: isEnabled, onChanged: (val) => vm.toggleZone(zone, val)),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, AppColors colors, ThemeProvider theme) {
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
              AppLocalizations.of(context)!.darkMode,
              style: TextStyle(fontSize: 17, color: colors.textPrimary, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          CNSwitch(value: isDark, onChanged: (val) => theme.setThemeMode(val ? ThemeMode.dark : ThemeMode.light)),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, AppColors colors) {
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
            child: const Text('🌍', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.language,
              style: TextStyle(fontSize: 17, color: colors.textPrimary, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildLanguageMenu(context, colors),
        ],
      ),
    );
  }

  Widget _buildLanguageMenu(BuildContext context, AppColors colors) {
    final localeVm = context.read<LocaleViewModel>();

    final items = [
      CNPopupMenuItem(label: AppLocalizations.of(context)!.english, icon: const CNSymbol('textformat', size: 12)),
      CNPopupMenuItem(label: AppLocalizations.of(context)!.spanish, icon: const CNSymbol('textformat', size: 12)),
    ];

    return CNPopupMenuButton(
      buttonLabel: 'Change',
      items: items,
      onSelected: (index) {
        if (index == 0) {
          localeVm.setLanguage(AppLanguage.english);
        } else if (index == 1) {
          localeVm.setLanguage(AppLanguage.spanish);
        }
      },
    );
  }
}
