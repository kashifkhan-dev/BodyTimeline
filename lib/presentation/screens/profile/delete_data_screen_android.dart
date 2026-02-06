import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/profile_view_model.dart';
import '../../view_models/today_view_model.dart';
import '../../view_models/history_view_model.dart';
import '../../view_models/progress_view_model.dart';
import '../../view_models/stats_view_model.dart';
import '../../view_models/settings_view_model.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_palette.dart';

class DeleteDataScreenAndroid extends StatefulWidget {
  const DeleteDataScreenAndroid({super.key});

  @override
  State<DeleteDataScreenAndroid> createState() => _DeleteDataScreenAndroidState();
}

class _DeleteDataScreenAndroidState extends State<DeleteDataScreenAndroid> {
  final TextEditingController _controller = TextEditingController();
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _canDelete = _controller.text.trim().toLowerCase() == 'delete all';
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

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Danger Zone'),
        backgroundColor: colors.background,
        foregroundColor: Colors.red,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 64),
            const SizedBox(height: 24),
            Text(
              'Reset Application',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              'This will erase all photos, measurement history, and nutritional logs. This action cannot be undone.',
              style: TextStyle(color: colors.textSecondary, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Type "delete all" to proceed',
                labelStyle: TextStyle(color: colors.textMuted),
                filled: true,
                fillColor: colors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
              ),
              style: TextStyle(color: colors.textPrimary),
              autofocus: true,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _canDelete ? () => _handleDelete(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.red.withAlpha(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'CONFIRM COMPLETE DELETE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data has been cleared.')));
    }
  }
}
