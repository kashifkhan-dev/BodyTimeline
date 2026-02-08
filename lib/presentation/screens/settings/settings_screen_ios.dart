import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:provider/provider.dart';
import '../../view_models/profile_view_model.dart';
import '../../view_models/settings_view_model.dart';

import '../../../domain/value_objects/zone_type.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_palette.dart';
import 'package:workout/l10n/generated/app_localizations.dart';
import '../../view_models/locale_view_model.dart';
import '../../../domain/entities/app_language.dart';
import '../profile/delete_data_screen.dart';
import '../common/webview_page.dart';
import '../../widgets/prominent_document_button.dart';

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
            transitionBetweenRoutes: false,
            largeTitle: Text(AppLocalizations.of(context)!.settings, style: TextStyle(color: colors.textPrimary)),
            backgroundColor: colors.background.withOpacity(0.7),
            border: null,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 12),
                _buildHeader(AppLocalizations.of(context)!.appearance.toUpperCase(), colors),
                const SizedBox(height: 8),
                _buildThemeToggle(context, colors, theme),
                const SizedBox(height: 8),
                _buildLanguageTile(context, colors),
                const SizedBox(height: 32),
                _buildHeader(AppLocalizations.of(context)!.dangerZone.toUpperCase(), colors),
                const SizedBox(height: 8),
                _buildActionTile(
                  context,
                  colors,
                  label: AppLocalizations.of(context)!.deleteData,
                  icon: CupertinoIcons.trash,
                  isDestructive: true,
                  onTap: () =>
                      Navigator.push(context, CupertinoPageRoute(builder: (context) => const DeleteDataScreen())),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ProminentDocumentButton(
                    label: AppLocalizations.of(context)!.claimMembershipRewards,
                    colors: colors,
                    onTap: () => showWebViewSheet(
                      context,
                      url: "https://docs.google.com/document/d/1-AkL6m-7NdHOXM2Pw7-a6QTgPR7Ro0Ofq5K-WEQWeFY/edit",
                      title: "App Documentation",
                    ),
                  ),
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
                  color: isDestructive ? colors.error.withAlpha(20) : colors.surface,
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
                color: isDestructive ? colors.error.withAlpha(150) : colors.textMuted,
              ),
            ],
          ),
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
      CNPopupMenuItem(
        label: '🇺🇸 ${AppLocalizations.of(context)!.english}',
        icon: const CNSymbol('textformat', size: 12),
      ),
      CNPopupMenuItem(
        label: '🇫🇷 ${AppLocalizations.of(context)!.french}',
        icon: const CNSymbol('textformat', size: 12),
      ),
      CNPopupMenuItem(
        label: '🇪🇸 ${AppLocalizations.of(context)!.spanish}',
        icon: const CNSymbol('textformat', size: 12),
      ),
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
}
