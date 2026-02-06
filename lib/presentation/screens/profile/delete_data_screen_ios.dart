import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workout/l10n/generated/app_localizations.dart';
import '../../view_models/profile_view_model.dart';
import '../../view_models/today_view_model.dart';
import '../../view_models/history_view_model.dart';
import '../../view_models/progress_view_model.dart';
import '../../view_models/stats_view_model.dart';
import '../../view_models/settings_view_model.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_palette.dart';

class DeleteDataScreenIOS extends StatefulWidget {
  const DeleteDataScreenIOS({super.key});

  @override
  State<DeleteDataScreenIOS> createState() => _DeleteDataScreenIOSState();
}

class _DeleteDataScreenIOSState extends State<DeleteDataScreenIOS> {
  final TextEditingController _controller = TextEditingController();
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final confirmationWord = AppLocalizations.of(context)!.deleteConfirmation.toLowerCase();
      setState(() {
        _canDelete = _controller.text.trim().toLowerCase() == confirmationWord;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors(context);

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          AppLocalizations.of(context)!.deleteData,
          style: const TextStyle(color: CupertinoColors.destructiveRed),
        ),
        backgroundColor: colors.background.withAlpha(200),
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: CupertinoColors.systemRed, size: 48),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.nuclearOption,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: CupertinoColors.label),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.deleteDataLongWarning,
                style: const TextStyle(fontSize: 17, color: CupertinoColors.secondaryLabel, height: 1.4),
              ),
              const SizedBox(height: 48),
              Text(
                AppLocalizations.of(context)!.typeToDelete(AppLocalizations.of(context)!.deleteConfirmation),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _controller,
                placeholder: AppLocalizations.of(context)!.deleteConfirmation,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                style: TextStyle(color: colors.textPrimary),
                autofocus: true,
              ),
              const SizedBox(height: 48),
              _buildDeleteButton(context, colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, AppColors colors) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 16),
        color: CupertinoColors.destructiveRed,
        disabledColor: CupertinoColors.destructiveRed.withAlpha(60),
        borderRadius: BorderRadius.circular(16),
        onPressed: _canDelete ? () => _handleDelete(context) : null,
        child: Text(
          AppLocalizations.of(context)!.deleteDataTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final vm = context.read<ProfileViewModel>();
    await vm.deleteAllData();

    if (mounted) {
      context.read<TodayViewModel>().refresh();
      context.read<HistoryViewModel>().refresh();
      context.read<ProgressViewModel>().refresh();
      context.read<StatsViewModel>().clearCache();
      context.read<SettingsViewModel>().loadConfig();

      Navigator.pop(context);
    }
  }
}
