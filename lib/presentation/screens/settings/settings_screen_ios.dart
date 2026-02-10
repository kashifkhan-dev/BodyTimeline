import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:provider/provider.dart';
import '../../view_models/settings_view_model.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_palette.dart';
import 'package:workout/l10n/generated/app_localizations.dart';
import '../../view_models/locale_view_model.dart';
import '../../../domain/entities/app_language.dart';
import '../profile/delete_data_screen.dart';
import '../common/webview_page.dart';
import '../../widgets/prominent_document_button.dart';
import '../../../core/providers/units_provider.dart';

class SettingsScreenIOS extends StatelessWidget {
  const SettingsScreenIOS({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = context.watch<SettingsViewModel>();
    final theme = context.watch<ThemeProvider>();
    final units = context.watch<UnitsProvider>();
    final localeVm = context.watch<LocaleViewModel>();
    final colors = theme.colors(context);
    final config = vm.config;

    if (config == null || l10n == null) {
      return CupertinoPageScaffold(
        backgroundColor: colors.background,
        child: const Center(child: CupertinoActivityIndicator()),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            transitionBetweenRoutes: false,
            largeTitle: Text(l10n.settings, style: TextStyle(color: colors.textPrimary)),
            backgroundColor: colors.background.withValues(alpha: 0.7),
            border: null,
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: ProminentDocumentButton(
                label: l10n.claimMembershipRewards,
                colors: colors,
                onTap: () => showWebViewSheet(
                  context,
                  url: "https://docs.google.com/document/d/1-AkL6m-7NdHOXM2Pw7-a6QTgPR7Ro0Ofq5K-WEQWeFY/edit",
                  title: "App Documentation",
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 32),
                _buildHeader(l10n.appearance.toUpperCase(), colors),
                const SizedBox(height: 8),
                _buildThemeToggle(context, colors, theme, l10n),
                const SizedBox(height: 8),
                _buildLanguageTile(context, colors, localeVm, l10n),
                const SizedBox(height: 8),
                _buildUnitToggle(context, colors, units, l10n),
                const SizedBox(height: 32),
                _buildHeader(l10n.dangerZone.toUpperCase(), colors),
                const SizedBox(height: 8),
                _buildActionTile(
                  context,
                  colors,
                  label: l10n.deleteData,
                  icon: CupertinoIcons.trash,
                  isDestructive: true,
                  onTap: () =>
                      Navigator.push(context, CupertinoPageRoute(builder: (context) => const DeleteDataScreen())),
                ),
                const SizedBox(height: 100),
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

  Widget _buildActionTile(
    BuildContext context,
    AppColors colors, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: onTap,
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
                decoration: BoxDecoration(
                  color: isDestructive ? colors.error.withValues(alpha: 20 / 255) : colors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: isDestructive ? colors.error : colors.textPrimary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 17,
                    color: isDestructive ? colors.error : colors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: isDestructive ? colors.error.withValues(alpha: 150 / 255) : colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, AppColors colors, ThemeProvider theme, AppLocalizations l10n) {
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
              l10n.darkMode,
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

  Widget _buildLanguageTile(BuildContext context, AppColors colors, LocaleViewModel localeVm, AppLocalizations l10n) {
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
              l10n.language,
              style: TextStyle(fontSize: 17, color: colors.textPrimary, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildLanguageMenu(context, colors, localeVm, l10n),
        ],
      ),
    );
  }

  Widget _buildLanguageMenu(BuildContext context, AppColors colors, LocaleViewModel localeVm, AppLocalizations l10n) {
    final items = [
      CNPopupMenuItem(label: '🇺🇸 ${l10n.english}', icon: const CNSymbol('textformat', size: 12)),
      CNPopupMenuItem(label: '🇫🇷 ${l10n.french}', icon: const CNSymbol('textformat', size: 12)),
      CNPopupMenuItem(label: '🇪🇸 ${l10n.spanish}', icon: const CNSymbol('textformat', size: 12)),
    ];

    return CNPopupMenuButton(
      buttonLabel: 'Change',
      items: items,
      onSelected: (index) {
        if (index == 0) {
          localeVm.setLanguage(AppLanguage.english);
        } else if (index == 1) {
          localeVm.setLanguage(AppLanguage.french);
        } else if (index == 2) {
          localeVm.setLanguage(AppLanguage.spanish);
        }
      },
    );
  }

  Widget _buildUnitToggle(BuildContext context, AppColors colors, UnitsProvider units, AppLocalizations l10n) {
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
            child: Icon(CupertinoIcons.slider_horizontal_3, color: colors.textPrimary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Unit System",
              style: TextStyle(fontSize: 17, color: colors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            width: 160,
            child: CNSegmentedControl(
              labels: const ['Metric', 'Imperial'],
              selectedIndex: units.isMetric ? 0 : 1,
              onValueChanged: (index) => units.setUnitSystem(index == 0 ? UnitSystem.metric : UnitSystem.imperial),
              shrinkWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
