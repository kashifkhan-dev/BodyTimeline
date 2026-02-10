import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workout/l10n/generated/app_localizations.dart';
import '../../view_models/locale_view_model.dart';
import '../../../domain/entities/app_language.dart';
import '../../view_models/settings_view_model.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_palette.dart';
import '../profile/delete_data_screen.dart';
import '../common/webview_page.dart';
import '../../widgets/prominent_document_button.dart';

class SettingsScreenAndroid extends StatelessWidget {
  const SettingsScreenAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = context.watch<SettingsViewModel>();
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);
    final config = vm.config;

    if (config == null || l10n == null) {
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
          _buildHeader(AppLocalizations.of(context)!.appearance, colors),
          const SizedBox(height: 12),
          _buildThemeToggle(context, colors, theme),
          const SizedBox(height: 12),
          _buildLanguageTile(context, colors),
          const SizedBox(height: 32),
          _buildHeader(AppLocalizations.of(context)!.dangerZone, colors),
          const SizedBox(height: 12),
          _buildActionTile(
            context,
            colors,
            label: AppLocalizations.of(context)!.deleteData,
            icon: Icons.delete_outline,
            isDestructive: true,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DeleteDataScreen())),
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
                title: "WIN REWARDS",
              ),
            ),
          ),
          const SizedBox(height: 60),
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

  Widget _buildActionTile(
    BuildContext context,
    AppColors colors, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 0,
      color: colors.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.border),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: CircleAvatar(
          backgroundColor: isDestructive ? colors.error.withAlpha(20) : colors.surface,
          child: Icon(icon, color: isDestructive ? colors.error : colors.textPrimary, size: 20),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 17,
            color: isDestructive ? colors.error : colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: isDestructive ? colors.error.withAlpha(150) : colors.textMuted),
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
              child: Text('🇺🇸 ${AppLocalizations.of(context)!.english}'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              localeVm.setLanguage(AppLanguage.french);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('🇫🇷 ${AppLocalizations.of(context)!.french}'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              localeVm.setLanguage(AppLanguage.spanish);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('🇪🇸 ${AppLocalizations.of(context)!.spanish}'),
            ),
          ),
        ],
      ),
    );
  }
}
