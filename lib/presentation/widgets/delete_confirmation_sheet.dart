import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../view_models/profile_view_model.dart';
import '../../core/theme/color_palette.dart';
import '../../core/theme/theme_provider.dart';

class DeleteConfirmationSheet extends StatefulWidget {
  final bool isIOS;
  final VoidCallback onDismiss;
  final VoidCallback onDeleted;

  const DeleteConfirmationSheet({super.key, required this.isIOS, required this.onDismiss, required this.onDeleted});

  @override
  State<DeleteConfirmationSheet> createState() => _DeleteConfirmationSheetState();
}

class _DeleteConfirmationSheetState extends State<DeleteConfirmationSheet> {
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

    return widget.isIOS ? _buildIOS(context, colors) : _buildAndroid(context, colors);
  }

  Widget _buildIOS(BuildContext context, AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delete All Data',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: CupertinoColors.destructiveRed),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: widget.onDismiss,
                child: const Icon(CupertinoIcons.xmark_circle_fill, color: CupertinoColors.systemGrey, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'This action is irreversible. All photos, logs, and progress will be permanently removed.',
            style: TextStyle(fontSize: 15, color: CupertinoColors.systemGrey),
          ),
          const SizedBox(height: 24),
          const Text(
            'Type "delete all" to confirm:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CupertinoColors.systemGrey),
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: _controller,
            placeholder: 'delete all',
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            style: TextStyle(color: colors.textPrimary),
            autofocus: true,
          ),
          const SizedBox(height: 32),
          SliverActionIOS(
            label: 'Delete All',
            color: CupertinoColors.destructiveRed,
            isEnabled: _canDelete,
            onPressed: () => _handleDelete(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAndroid(BuildContext context, AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Critical Confirmation',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 16),
          Text(
            'Are you absolutely sure? This will erase everything and reset the app.',
            style: TextStyle(color: colors.textSecondary),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Type "delete all" to confirm',
              labelStyle: TextStyle(color: colors.textMuted),
              filled: true,
              fillColor: colors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
            style: TextStyle(color: colors.textPrimary),
            autofocus: true,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onDismiss,
                child: Text('CANCEL', style: TextStyle(color: colors.textMuted)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _canDelete ? () => _handleDelete(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.red.withAlpha(50),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('DELETE ALL'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final vm = context.read<ProfileViewModel>();
    await vm.deleteAllData();
    widget.onDeleted();
  }
}

class SliverActionIOS extends StatelessWidget {
  final String label;
  final Color color;
  final bool isEnabled;
  final VoidCallback onPressed;

  const SliverActionIOS({
    super.key,
    required this.label,
    required this.color,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 16),
        color: color,
        disabledColor: color.withAlpha(50),
        borderRadius: BorderRadius.circular(16),
        onPressed: isEnabled ? onPressed : null,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
