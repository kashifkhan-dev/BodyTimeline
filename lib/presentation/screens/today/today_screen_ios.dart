import 'dart:io';
import 'dart:ui';
import '../camera/camera_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
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
import 'package:workout/l10n/generated/app_localizations.dart';
import 'package:cupertino_native_better/cupertino_native_better.dart';

enum ActiveSheet { none, macros, measurements }

class TodayScreenIOS extends StatefulWidget {
  const TodayScreenIOS({super.key});

  @override
  State<TodayScreenIOS> createState() => _TodayScreenIOSState();
}

class _TodayScreenIOSState extends State<TodayScreenIOS> {
  ActiveSheet _activeSheet = ActiveSheet.none;

  void _showSheet(ActiveSheet sheet) {
    setState(() {
      _activeSheet = sheet;
    });
  }

  void _hideSheet() {
    setState(() {
      _activeSheet = ActiveSheet.none;
    });
  }

  void _navigateToProfile() {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => const ProfileScreen(), fullscreenDialog: true));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TodayViewModel>();
    final settingsVm = context.watch<SettingsViewModel>();
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);
    final today = vm.today;

    if (vm.isLoading || today == null || settingsVm.config == null) {
      return Container(
        color: colors.background,
        child: Center(child: CupertinoActivityIndicator(color: colors.primary)),
      );
    }

    final config = settingsVm.config!;
    final activePhotoZones = today.activeZones.where((z) {
      return config.isEnabled(z) && z != ZoneType.macronutrients && z != ZoneType.measurements;
    }).toList();

    // The PRD says completion should be based ONLY on enabled settings.
    // WorkoutDay already handles this in completionPercentage if initialized
    // with correct activeZones (which it is, see TodayViewModel).
    final completion = vm.completionPercentage;

    return Stack(
      children: [
        CupertinoPageScaffold(
          backgroundColor: colors.background,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              CupertinoSliverNavigationBar(
                transitionBetweenRoutes: false,
                largeTitle: Text(AppLocalizations.of(context)!.today, style: TextStyle(color: colors.textPrimary)),
                backgroundColor: colors.background.withAlpha(200),
                border: Border(bottom: BorderSide(color: colors.border)),
                trailing: _buildProfileAvatar(colors),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),
                    Text(
                      _getFormattedLongDate(context, today),
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: colors.textSecondary),
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
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (config.isEnabled(ZoneType.macronutrients))
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showSheet(ActiveSheet.macros),
                                child: _buildLogCard(
                                  icon: CupertinoIcons.lab_flask,
                                  title: AppLocalizations.of(context)!.macros,
                                  subtitle: vm.isZoneCompleted(ZoneType.macronutrients)
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
                              child: GestureDetector(
                                onTap: () => _showSheet(ActiveSheet.measurements),
                                child: _buildLogCard(
                                  icon: CupertinoIcons.gauge,
                                  title: AppLocalizations.of(context)!.measurements,
                                  subtitle: vm.isZoneCompleted(ZoneType.measurements)
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
                  ]),
                ),
              ),
            ],
          ),
        ),

        IgnorePointer(
          ignoring: _activeSheet == ActiveSheet.none,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: _activeSheet == ActiveSheet.none ? 0.0 : 1.0,
            curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: _hideSheet,
              child: Container(color: CupertinoColors.black.withAlpha(100)),
            ),
          ),
        ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutExpo,
          left: 0,
          right: 0,
          bottom: _activeSheet == ActiveSheet.none ? -MediaQuery.of(context).size.height : 0,
          child: _buildActiveSheet(),
        ),
      ],
    );
  }

  Widget _buildActiveSheet() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _buildSheetContent(),
    );
  }

  Widget _buildSheetContent() {
    switch (_activeSheet) {
      case ActiveSheet.macros:
        return MacroEntrySheet(key: const ValueKey('macros'), onDismiss: _hideSheet);
      case ActiveSheet.measurements:
        return MeasurementEntrySheet(key: const ValueKey('measurements'), onDismiss: _hideSheet);
      case ActiveSheet.none:
        return const SizedBox.shrink(key: ValueKey('none'));
    }
  }

  Widget _buildProfileAvatar(AppColors colors) {
    final profileVm = context.watch<ProfileViewModel>();
    final path = profileVm.avatarPath;

    return GestureDetector(
      onTap: () => _showProfileMenu(context, colors),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: colors.primary.withAlpha(30), width: 1),
          boxShadow: [BoxShadow(color: colors.textPrimary.withAlpha(5), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: ClipOval(child: _buildAvatarImage(path)),
      ),
    );
  }

  void _showProfileMenu(BuildContext context, AppColors colors) {
    _navigateToProfile();
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: colors.textPrimary.withAlpha(15), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.dailyGoal,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: lightGreen, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  '${(percentage * 100).toInt()}% ${AppLocalizations.of(context)!.done}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkGreenText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            percentage >= 1.0 ? AppLocalizations.of(context)!.greatJob : AppLocalizations.of(context)!.almostThere,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            percentage >= 1.0
                ? AppLocalizations.of(context)!.dailyGoalReached
                : AppLocalizations.of(context)!.completeOneMoreTask,
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 8,
              width: double.infinity,
              color: colors.progressBackground,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage.clamp(0.0, 1.0),
                child: Container(color: lightGreen),
              ),
            ),
          ),
        ],
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: colors.textPrimary.withAlpha(8), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(14)),
              child: Icon(_getZoneIcon(zone), size: 24, color: colors.textPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getZoneLabel(context, zone),
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isCompleted && photo != null
                        ? AppLocalizations.of(context)!.capturedAt(
                            '${photo.capturedAt.hour.toString().padLeft(2, '0')}:${photo.capturedAt.minute.toString().padLeft(2, '0')}',
                          )
                        : _getZoneSubtitle(context, zone),
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.checkmark_alt_circle_fill, size: 28, color: CupertinoColors.systemGreen),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      await CameraScreen.show(context, zone);
                      vm.refresh();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.border),
                      ),
                      child: Icon(CupertinoIcons.camera_rotate, size: 18, color: colors.textPrimary),
                    ),
                  ),
                ],
              )
            else
              CNButton.icon(
                icon: const CNSymbol('camera.fill', size: 20),
                config: const CNButtonConfig(style: CNButtonStyle.prominentGlass),
                onPressed: () async {
                  await CameraScreen.show(context, zone);
                  vm.refresh();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard({
    required IconData icon,
    required String title,
    required String subtitle,
    bool hasIndicator = false,
    required AppColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 140,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: colors.textPrimary.withAlpha(8), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: colors.textPrimary),
              const Spacer(),
              _buildLogCardContent(title, subtitle, colors),
            ],
          ),
          if (hasIndicator)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Color(0xFFD0F288), shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogCardContent(String title, String subtitle, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
      ],
    );
  }

  IconData _getZoneIcon(ZoneType zone) {
    switch (zone) {
      case ZoneType.face:
        return CupertinoIcons.person_crop_circle;
      case ZoneType.measurements:
        return CupertinoIcons.gauge;
      case ZoneType.macronutrients:
        return CupertinoIcons.lab_flask;
      default:
        return CupertinoIcons.person_alt;
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

  String _getFormattedLongDate(BuildContext context, WorkoutDay day) {
    final l10n = AppLocalizations.of(context)!;
    final date = day.date;
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
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}
