import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:workout/core/theme/color_palette.dart';
import 'package:workout/l10n/generated/app_localizations.dart';
import '../../view_models/locale_view_model.dart';
import '../../../domain/entities/app_language.dart';
import '../../../core/theme/theme_provider.dart';

class LanguageScreenIOS extends StatelessWidget {
  const LanguageScreenIOS({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);
    final localeVm = context.watch<LocaleViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(l10n.language, style: TextStyle(color: colors.textPrimary)),
        backgroundColor: colors.background.withAlpha(200),
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            _buildLanguageItem(
              context,
              colors: colors,
              title: l10n.spanish,
              language: AppLanguage.spanish,
              currentLanguage: localeVm.currentLanguage,
              onTap: () => localeVm.setLanguage(AppLanguage.spanish),
            ),
            Container(height: 0.5, color: colors.border.withAlpha(80), margin: const EdgeInsets.only(left: 60)),
            _buildLanguageItem(
              context,
              colors: colors,
              title: l10n.english,
              language: AppLanguage.english,
              currentLanguage: localeVm.currentLanguage,
              onTap: () => localeVm.setLanguage(AppLanguage.english),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(
    BuildContext context, {
    required AppColors colors,
    required String title,
    required AppLanguage language,
    required AppLanguage currentLanguage,
    required VoidCallback onTap,
  }) {
    final isSelected = language == currentLanguage;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: const Color(0x00000000),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? colors.primary : colors.textSecondary.withAlpha(50), width: 2),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                color: colors.textPrimary,
                decoration: TextDecoration.none,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (isSelected) Icon(CupertinoIcons.check_mark, color: colors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
