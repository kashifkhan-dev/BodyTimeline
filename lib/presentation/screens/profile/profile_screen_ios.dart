import 'dart:io';

import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/profile_view_model.dart';
import '../../view_models/settings_view_model.dart';
import '../../../domain/value_objects/zone_type.dart';
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
    final theme = context.watch<ThemeProvider>();
    final settingsVm = context.watch<SettingsViewModel>();
    final config = settingsVm.config;
    final l10n = AppLocalizations.of(context)!;

    if (config == null) {
      return Container(
        color: colors.background,
        child: const Center(child: CupertinoActivityIndicator()),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text(l10n.close, style: TextStyle(color: colors.primary)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Text(l10n.profile, style: TextStyle(color: colors.textPrimary)),
        backgroundColor: colors.background.withOpacity(0.7),
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatarPreview(context, colors),
              const SizedBox(height: 48),

              _buildHeader(l10n.changeAvatar, colors),
              const SizedBox(height: 12),
              _buildIOSOption(0, l10n.latestProgressImage, l10n.useRecentFrontPhoto, colors),
              const SizedBox(height: 12),
              _buildIOSOption(1, l10n.chooseFromGallery, l10n.pickImageFromDevice, colors),

              const SizedBox(height: 48),
              _buildActionButtons(context, colors),

              const SizedBox(height: 40),
              _buildHeader(l10n.trackingZones.toUpperCase(), colors),
              const SizedBox(height: 12),
              _buildZoneTile(context, colors, settingsVm, ZoneType.face, l10n.face, CupertinoIcons.person_crop_circle),

              _buildZoneTile(
                context,
                colors,
                settingsVm,
                ZoneType.bodyFront,
                l10n.bodyFront,
                CupertinoIcons.person_alt,
              ),
              _buildZoneTile(
                context,
                colors,
                settingsVm,
                ZoneType.bodySide,
                l10n.bodySide,
                CupertinoIcons.person_alt_circle,
              ),
              _buildZoneTile(
                context,
                colors,
                settingsVm,
                ZoneType.bodyBack,
                l10n.bodyBack,
                CupertinoIcons.person_alt_circle_fill,
              ),

              const SizedBox(height: 32),
              _buildHeader(l10n.additionalTracking.toUpperCase(), colors),
              const SizedBox(height: 12),
              _buildZoneTile(
                context,
                colors,
                settingsVm,
                ZoneType.measurements,
                l10n.measurements,
                CupertinoIcons.envelope,
              ),
              _buildZoneTile(
                context,
                colors,
                settingsVm,
                ZoneType.macronutrients,
                l10n.macronutrients,
                CupertinoIcons.metronome,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title, AppColors colors) {
    return Text(
      title,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textMuted, letterSpacing: 0.5),
    );
  }

  Widget _buildZoneTile(
    BuildContext context,
    AppColors colors,
    SettingsViewModel vm,
    ZoneType zone,
    String label,
    IconData icon,
  ) {
    final isEnabled = vm.config?.isEnabled(zone) ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Icon(icon, color: colors.textPrimary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 17, color: colors.textPrimary, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            CNSwitch(value: isEnabled, onChanged: (val) => vm.toggleZone(zone, val)),
          ],
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
            width: 170,
            height: 170,
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
          child: CNButton(
            label: AppLocalizations.of(context)!.updateProfilePicture,
            config: const CNButtonConfig(style: CNButtonStyle.prominentGlass),
            onPressed: vm.isLoading ? null : () => _handleSave(context),
          ),
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
