import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workout/l10n/generated/app_localizations.dart';
import '../../view_models/profile_view_model.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_palette.dart';

class ProfileScreenAndroid extends StatefulWidget {
  const ProfileScreenAndroid({super.key});

  @override
  State<ProfileScreenAndroid> createState() => _ProfileScreenAndroidState();
}

class _ProfileScreenAndroidState extends State<ProfileScreenAndroid> {
  int _selectedOption = 0; // 0: progress, 1: gallery

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors(context);
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileSettings),
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarPreview(colors),
            const SizedBox(height: 40),
            Text(
              AppLocalizations.of(context)!.avatarSelection,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            const SizedBox(height: 16),
            Card(
              color: colors.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
              child: Column(
                children: [
                  RadioListTile<int>(
                    value: 0,
                    groupValue: _selectedOption,
                    onChanged: (v) => setState(() => _selectedOption = v!),
                    title: Text(
                      AppLocalizations.of(context)!.latestProgressImage,
                      style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.syncsWithLatestBodyPhoto,
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    activeColor: colors.primary,
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  RadioListTile<int>(
                    value: 1,
                    groupValue: _selectedOption,
                    onChanged: (v) => setState(() => _selectedOption = v!),
                    title: Text(
                      AppLocalizations.of(context)!.chooseFromGallery,
                      style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.uploadCustomPicture,
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    activeColor: colors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: vm.isLoading ? null : () => _handleSave(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: vm.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        AppLocalizations.of(context)!.saveProfileChanges.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPreview(AppColors colors) {
    final vm = context.watch<ProfileViewModel>();
    final path = vm.avatarPath;

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface,
              border: Border.all(color: colors.primary.withAlpha(50), width: 4),
            ),
            child: ClipOval(child: _buildImage(path)),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: colors.background, width: 3),
            ),
            child: const Icon(Icons.edit, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? path) {
    if (path == null) {
      return Image.asset('assets/images/front.png', fit: BoxFit.cover);
    }
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset('assets/images/front.png', fit: BoxFit.cover);
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
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
