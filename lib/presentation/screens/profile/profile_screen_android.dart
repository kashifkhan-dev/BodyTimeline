import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workout/l10n/generated/app_localizations.dart';
import '../../view_models/profile_view_model.dart';
import '../../view_models/settings_view_model.dart';
import '../../../domain/value_objects/zone_type.dart';
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
    final profileVm = context.watch<ProfileViewModel>();
    final settingsVm = context.watch<SettingsViewModel>();
    final config = settingsVm.config;
    final l10n = AppLocalizations.of(context)!;

    if (config == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l10n.profileSettings),
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
              l10n.avatarSelection,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            const SizedBox(height: 16),
            _buildCardSelection(context, colors),
            const SizedBox(height: 40),
            Text(
              l10n.trackingZones,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            const SizedBox(height: 16),
            _buildZoneTile(context, colors, settingsVm, ZoneType.face, l10n.face, '👤'),
            _buildZoneTile(context, colors, settingsVm, ZoneType.bodyFront, l10n.bodyFront, '🧍'),
            _buildZoneTile(context, colors, settingsVm, ZoneType.bodySide, l10n.bodySide, '🧍‍♂️'),
            _buildZoneTile(context, colors, settingsVm, ZoneType.bodyBack, l10n.bodyBack, '🧍‍♀️'),
            const SizedBox(height: 32),
            Text(
              l10n.additionalTracking,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            const SizedBox(height: 16),
            _buildZoneTile(context, colors, settingsVm, ZoneType.measurements, l10n.measurements, '📏'),
            _buildZoneTile(context, colors, settingsVm, ZoneType.macronutrients, l10n.macronutrients, '🍎'),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: profileVm.isLoading ? null : () => _handleSave(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: profileVm.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        l10n.saveProfileChanges.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSelection(BuildContext context, AppColors colors) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.border),
      ),
      elevation: 0,
      child: Column(
        children: [
          RadioListTile<int>(
            value: 0,
            groupValue: _selectedOption,
            onChanged: (v) => setState(() => _selectedOption = v!),
            title: Text(
              l10n.latestProgressImage,
              style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(l10n.syncsWithLatestBodyPhoto, style: TextStyle(color: colors.textSecondary)),
            activeColor: colors.primary,
          ),
          const Divider(indent: 16, endIndent: 16),
          RadioListTile<int>(
            value: 1,
            groupValue: _selectedOption,
            onChanged: (v) => setState(() => _selectedOption = v!),
            title: Text(
              l10n.chooseFromGallery,
              style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(l10n.uploadCustomPicture, style: TextStyle(color: colors.textSecondary)),
            activeColor: colors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildZoneTile(
    BuildContext context,
    AppColors colors,
    SettingsViewModel vm,
    ZoneType zone,
    String label,
    String emoji,
  ) {
    final isEnabled = vm.config?.isEnabled(zone) ?? false;
    return Card(
      elevation: 0,
      color: colors.card,
      margin: const EdgeInsets.symmetric(vertical: 4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.border),
      ),
      child: SwitchListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        secondary: CircleAvatar(
          backgroundColor: colors.surface,
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(
          label,
          style: TextStyle(fontSize: 17, color: colors.textPrimary, fontWeight: FontWeight.w500),
        ),
        value: isEnabled,
        onChanged: (val) => vm.toggleZone(zone, val),
        activeThumbColor: colors.primary,
        activeTrackColor: colors.primary.withAlpha(50),
        inactiveTrackColor: colors.surface,
        inactiveThumbColor: colors.textMuted,
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
