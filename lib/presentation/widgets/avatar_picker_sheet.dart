import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../view_models/profile_view_model.dart';
import '../../core/theme/color_palette.dart';
import '../../core/theme/theme_provider.dart';

class AvatarPickerSheet extends StatefulWidget {
  final bool isIOS;
  final VoidCallback onDismiss;

  const AvatarPickerSheet({super.key, required this.isIOS, required this.onDismiss});

  @override
  State<AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<AvatarPickerSheet> {
  int _selectedOption = 0; // 0: progress, 1: gallery

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
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Picture',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.textPrimary),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: widget.onDismiss,
                child: const Icon(CupertinoIcons.xmark_circle_fill, color: CupertinoColors.systemGrey, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildAvatarPreview(colors),
          const SizedBox(height: 32),
          _buildIOSOption(0, 'Latest Progress Image', 'Use your most recent front body photo', colors),
          const SizedBox(height: 12),
          _buildIOSOption(1, 'Choose from Gallery', 'Pick an image from your device', colors),
          const SizedBox(height: 40),
          _buildIOSActionButtons(context, colors),
          const SizedBox(height: 20),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Change Profile Match',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
          ),
          const SizedBox(height: 24),
          _buildAvatarPreview(colors),
          const SizedBox(height: 32),
          RadioListTile<int>(
            value: 0,
            groupValue: _selectedOption,
            onChanged: (v) => setState(() => _selectedOption = v!),
            title: Text(
              'Latest Progress Image',
              style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
            ),
            subtitle: Text('Best for tracking results', style: TextStyle(color: colors.textSecondary)),
            activeColor: colors.primary,
          ),
          RadioListTile<int>(
            value: 1,
            groupValue: _selectedOption,
            onChanged: (v) => setState(() => _selectedOption = v!),
            title: Text(
              'Choose from Gallery',
              style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
            ),
            subtitle: Text('Pick from your photos', style: TextStyle(color: colors.textSecondary)),
            activeColor: colors.primary,
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
                onPressed: () => _handleSave(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('SAVE CHANGES'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIOSOption(int index, String title, String subtitle, AppColors colors) {
    final isSelected = _selectedOption == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? colors.primary : colors.border, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? colors.primary : colors.textMuted, width: 2),
                color: isSelected ? colors.primary : Colors.transparent,
              ),
              child: isSelected ? const Icon(CupertinoIcons.checkmark, size: 14, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIOSActionButtons(BuildContext context, AppColors colors) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        color: colors.primary,
        borderRadius: BorderRadius.circular(16),
        onPressed: () => _handleSave(context),
        child: const Text('Update Avatar', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAvatarPreview(AppColors colors) {
    final vm = context.watch<ProfileViewModel>();
    final path = vm.avatarPath;

    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.surface,
          border: Border.all(color: colors.primary.withAlpha(50), width: 4),
          boxShadow: [BoxShadow(color: colors.textPrimary.withAlpha(20), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: ClipOval(child: _buildImage(path)),
      ),
    );
  }

  Widget _buildImage(String? path) {
    if (path == null) {
      return Image.asset('assets/images/transformation/1.png', fit: BoxFit.cover);
    }
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset('assets/images/transformation/1.png', fit: BoxFit.cover);
      },
    );
  }

  Future<void> _handleSave(BuildContext context) async {
    final vm = context.read<ProfileViewModel>();
    if (_selectedOption == 0) {
      await vm.setLatestFrontBodyAsAvatar();
    } else {
      await vm.pickFromGallery();
    }
    widget.onDismiss();
  }
}
