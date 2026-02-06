import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workout/l10n/generated/app_localizations.dart';
import '../../view_models/locale_view_model.dart';
import '../../../domain/entities/app_language.dart';
import '../../../core/theme/theme_provider.dart';

class LanguageScreenAndroid extends StatelessWidget {
  const LanguageScreenAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);
    final localeVm = context.watch<LocaleViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l10n.language, style: TextStyle(color: colors.textPrimary)),
        backgroundColor: colors.background,
        elevation: 0,
        foregroundColor: colors.textPrimary,
      ),
      body: ListView(
        children: [
          RadioListTile<AppLanguage>(
            title: Text(l10n.spanish, style: TextStyle(color: colors.textPrimary)),
            value: AppLanguage.spanish,
            groupValue: localeVm.currentLanguage,
            onChanged: (value) {
              if (value != null) localeVm.setLanguage(value);
            },
            activeColor: colors.primary,
          ),
          RadioListTile<AppLanguage>(
            title: Text(l10n.english, style: TextStyle(color: colors.textPrimary)),
            value: AppLanguage.english,
            groupValue: localeVm.currentLanguage,
            onChanged: (value) {
              if (value != null) localeVm.setLanguage(value);
            },
            activeColor: colors.primary,
          ),
        ],
      ),
    );
  }
}
