import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workout/l10n/generated/app_localizations.dart';
import '../camera/camera_screen.dart';
import '../../../domain/entities/workout_day.dart';
import '../../../domain/value_objects/zone_type.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_palette.dart';
import '../../widgets/macro_entry_sheet.dart';
import '../../widgets/measurement_entry_sheet.dart';
import '../../../domain/entities/tracking_config.dart';
import '../../view_models/today_view_model.dart';
import '../../view_models/history_view_model.dart';
import '../../view_models/progress_view_model.dart';
import '../../view_models/stats_view_model.dart';
import '../../view_models/settings_view_model.dart';
import '../../view_models/profile_view_model.dart';
import '../profile/profile_screen.dart';
import '../profile/delete_data_screen.dart';
import '../settings/language_screen.dart';

enum ActiveSheet { none, macros, measurements }

class TodayScreenAndroid extends StatefulWidget {
  const TodayScreenAndroid({super.key});

  @override
  State<TodayScreenAndroid> createState() => _TodayScreenAndroidState();
}

class _TodayScreenAndroidState extends State<TodayScreenAndroid> {
  // No local state needed, using TodayViewModel

  void _showSheet(ActiveSheet sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSheetContent(sheet),
    );
  }

  void _navigateToProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
  }

  void _navigateToDeleteData() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const DeleteDataScreen()));
  }

  void _navigateToLanguage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguageScreen()));
  }

  Widget _buildSheetContent(ActiveSheet sheet) {
    switch (sheet) {
      case ActiveSheet.macros:
        return MacroEntrySheet(onDismiss: () => Navigator.pop(context));
      case ActiveSheet.measurements:
        return MeasurementEntrySheet(onDismiss: () => Navigator.pop(context));
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TodayViewModel>();
    final settingsVm = context.watch<SettingsViewModel>();
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);
    final today = vm.today;

    if (vm.isLoading || today == null || settingsVm.config == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
      );
    }

    final config = settingsVm.config!;
    final activePhotoZones = today.activeZones.where((z) {
      return config.isEnabled(z) && z != ZoneType.macronutrients && z != ZoneType.measurements;
    }).toList();

    final enabledZones = today.activeZones.where((z) => config.isEnabled(z)).toList();
    final int totalZones = enabledZones.length;
    final completion = vm.completionPercentage;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.today),
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        actions: [Padding(padding: const EdgeInsets.only(right: 16), child: _buildProfileAvatar(colors))],
      ),
      body: RefreshIndicator(
        onRefresh: () => vm.refresh(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 16),
            Text(
              _getFormattedLongDate(context),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            _buildDailyGoalCard(context, colors, completion),
            const SizedBox(height: 32),

            if (activePhotoZones.isNotEmpty) ...[
              _buildSectionHeader(
                title: AppLocalizations.of(context)!.todaysTasks,
                subtext: _getTasksRemainingText(context, vm, today, config, isTaskOnly: true),
                colors: colors,
              ),
              const SizedBox(height: 12),
              ...activePhotoZones.map((zone) => _buildTaskCard(context, colors, vm, today, zone)),
              const SizedBox(height: 32),
            ],

            if (config.isEnabled(ZoneType.macronutrients) || config.isEnabled(ZoneType.measurements)) ...[
              Text(
                AppLocalizations.of(context)!.logDay,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (config.isEnabled(ZoneType.macronutrients))
                    Expanded(
                      child: InkWell(
                        onTap: () => _showSheet(ActiveSheet.macros),
                        borderRadius: BorderRadius.circular(24),
                        child: _buildLogCard(
                          icon: Icons.restaurant_menu,
                          title: AppLocalizations.of(context)!.macros,
                          subtitle: today.isZoneCompleted(ZoneType.macronutrients)
                              ? AppLocalizations.of(context)!.logged
                              : AppLocalizations.of(context)!.pending,
                          colors: colors,
                        ),
                      ),
                    ),
                  if (config.isEnabled(ZoneType.macronutrients) && config.isEnabled(ZoneType.measurements))
                    const SizedBox(width: 12),
                  if (config.isEnabled(ZoneType.measurements))
                    Expanded(
                      child: InkWell(
                        onTap: () => _showSheet(ActiveSheet.measurements),
                        borderRadius: BorderRadius.circular(24),
                        child: _buildLogCard(
                          icon: Icons.straighten,
                          title: AppLocalizations.of(context)!.measurements,
                          subtitle: today.isZoneCompleted(ZoneType.measurements)
                              ? AppLocalizations.of(context)!.recorded
                              : AppLocalizations.of(context)!.notRecorded,
                          colors: colors,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(AppColors colors) {
    final profileVm = context.watch<ProfileViewModel>();
    final path = profileVm.avatarPath;

    return PopupMenuButton<int>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: colors.background,
      elevation: 8,
      onSelected: (value) {
        if (value == 1) {
          _navigateToProfile();
        } else if (value == 2) {
          _navigateToLanguage();
        } else if (value == 3) {
          _navigateToDeleteData();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 20, color: colors.textPrimary),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.profile, style: TextStyle(color: colors.textPrimary)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.language_outlined, size: 20, color: colors.textPrimary),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.language, style: TextStyle(color: colors.textPrimary)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: [
              const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.deleteData,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
      child: CircleAvatar(
        radius: 20,
        backgroundColor: colors.surface,
        child: ClipOval(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildAvatarImage(path),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.primary.withAlpha(40), width: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage(String? path) {
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

  Widget _buildDailyGoalCard(BuildContext context, AppColors colors, double percentage) {
    final lightGreen = const Color(0xFFD0F288);
    const darkGreenText = Color(0xFF3A5A1A);

    return Card(
      elevation: 0,
      color: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.dailyGoal,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.textMuted,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: lightGreen, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '${(percentage * 100).toInt()}% ${AppLocalizations.of(context)!.done}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkGreenText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              percentage >= 1.0 ? AppLocalizations.of(context)!.greatJob : AppLocalizations.of(context)!.almostThere,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              percentage >= 1.0
                  ? AppLocalizations.of(context)!.dailyGoalReached
                  : AppLocalizations.of(context)!.completeOneMoreTask,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              backgroundColor: colors.progressBackground,
              valueColor: AlwaysStoppedAnimation<Color>(lightGreen),
              borderRadius: BorderRadius.circular(10),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String subtext, required AppColors colors}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(subtext, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, AppColors colors, TodayViewModel vm, WorkoutDay day, ZoneType zone) {
    final photo = vm.getSessionPhoto(zone);
    final isCompleted = vm.isZoneCompleted(zone);

    return Card(
      elevation: 0,
      color: colors.card,
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(14)),
          child: Icon(_getZoneIcon(zone), size: 24, color: colors.textPrimary),
        ),
        title: Text(
          _getZoneLabel(context, zone),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        subtitle: Text(
          isCompleted && photo != null
              ? AppLocalizations.of(context)!.capturedAt(
                  '${photo.capturedAt.hour.toString().padLeft(2, '0')}:${photo.capturedAt.minute.toString().padLeft(2, '0')}',
                )
              : _getZoneSubtitle(context, zone),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
        ),
        trailing: isCompleted
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 28, color: colors.success),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.flip_camera_ios),
                    onPressed: () async {
                      await CameraScreen.show(context, zone);
                      vm.refresh();
                    },
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: () async {
                  await CameraScreen.show(context, zone);
                  vm.refresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                ),
                child: const Icon(Icons.camera_alt),
              ),
      ),
    );
  }

  Widget _buildLogCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required AppColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 140,
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: colors.textPrimary),
          const Spacer(),
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
        ],
      ),
    );
  }

  IconData _getZoneIcon(ZoneType zone) {
    switch (zone) {
      case ZoneType.face:
        return Icons.portrait;
      case ZoneType.measurements:
        return Icons.speed;
      case ZoneType.macronutrients:
        return Icons.science;
      default:
        return Icons.person;
    }
  }

  String _getZoneLabel(BuildContext context, ZoneType zone) {
    final l10n = AppLocalizations.of(context)!;
    switch (zone) {
      case ZoneType.face:
        return l10n.facePhoto;
      case ZoneType.bodyFront:
        return l10n.bodyFrontPhoto;
      case ZoneType.bodySide:
        return l10n.bodySidePhoto;
      case ZoneType.bodyBack:
        return l10n.bodyBackPhoto;
      case ZoneType.measurements:
        return l10n.bodyMeasurements;
      case ZoneType.macronutrients:
        return l10n.macronutrients;
    }
  }

  String _getZoneSubtitle(BuildContext context, ZoneType zone) {
    final l10n = AppLocalizations.of(context)!;
    switch (zone) {
      case ZoneType.measurements:
        return l10n.notRecorded;
      default:
        return l10n.pendingRegistration;
    }
  }

  String _getTasksRemainingText(
    BuildContext context,
    TodayViewModel vm,
    WorkoutDay day,
    TrackingConfig config, {
    bool isTaskOnly = false,
  }) {
    final zones = isTaskOnly
        ? day.activeZones.where(
            (z) => config.isEnabled(z) && z != ZoneType.macronutrients && z != ZoneType.measurements,
          )
        : day.activeZones.where((z) => config.isEnabled(z));

    final total = zones.length;
    final completed = zones.where((z) => vm.isZoneCompleted(z)).length;
    final remaining = total - completed;

    return AppLocalizations.of(context)!.tasksRemaining(remaining, total);
  }

  String _getFormattedLongDate(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final weekdays = [
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
      l10n.sunday,
    ];
    final months = [
      l10n.january,
      l10n.february,
      l10n.march,
      l10n.april,
      l10n.may,
      l10n.june,
      l10n.july,
      l10n.august,
      l10n.september,
      l10n.october,
      l10n.november,
      l10n.december,
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}
