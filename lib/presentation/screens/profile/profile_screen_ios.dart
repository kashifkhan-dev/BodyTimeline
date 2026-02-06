import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/profile_view_model.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_palette.dart';
import 'package:workout/l10n/generated/app_localizations.dart';

class ProfileScreenIOS extends StatefulWidget {
  const ProfileScreenIOS({super.key});

  @override
  State<ProfileScreenIOS> createState() => _ProfileScreenIOSState();
}

class _ProfileScreenIOSState extends State<ProfileScreenIOS> {
  int _selectedOption = 0; // 0: progress, 1: gallery

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors(context);

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(AppLocalizations.of(context)!.profile, style: TextStyle(color: colors.textPrimary)),
        backgroundColor: colors.background.withAlpha(200),
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatarPreview(context, colors),
              const SizedBox(height: 40),
              Text(
                AppLocalizations.of(context)!.changeAvatar,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              _buildIOSOption(
                0,
                AppLocalizations.of(context)!.latestProgressImage,
                AppLocalizations.of(context)!.useRecentFrontPhoto,
                colors,
              ),
              const SizedBox(height: 12),
              _buildIOSOption(
                1,
                AppLocalizations.of(context)!.chooseFromGallery,
                AppLocalizations.of(context)!.pickImageFromDevice,
                colors,
              ),
              const SizedBox(height: 48),
              _buildActionButtons(context, colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPreview(BuildContext context, AppColors colors) {
    final vm = context.watch<ProfileViewModel>();
    final path = vm.avatarPath;

    return Center(
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface,
              border: Border.all(color: colors.primary.withAlpha(50), width: 4),
              boxShadow: [
                BoxShadow(color: colors.textPrimary.withAlpha(20), blurRadius: 30, offset: const Offset(0, 15)),
              ],
            ),
            child: ClipOval(child: _buildImage(path)),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.preview,
            style: TextStyle(color: colors.textSecondary, fontSize: 15, fontWeight: FontWeight.w500),
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

  Widget _buildIOSOption(int index, String title, String subtitle, AppColors colors) {
    final isSelected = _selectedOption == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = index),
      child: Container(
        padding: const EdgeInsets.all(20),
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
                color: isSelected ? colors.primary : const Color(0x00000000),
              ),
              child: isSelected ? const Icon(CupertinoIcons.checkmark, size: 14, color: Color(0xFFFFFFFF)) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppColors colors) {
    final vm = context.watch<ProfileViewModel>();

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: colors.primary,
            borderRadius: BorderRadius.circular(16),
            onPressed: vm.isLoading ? null : () => _handleSave(context),
            child: vm.isLoading
                ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                : Text(
                    AppLocalizations.of(context)!.updateProfilePicture,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: CupertinoColors.white),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        CupertinoButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: colors.textMuted)),
        ),
      ],
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
