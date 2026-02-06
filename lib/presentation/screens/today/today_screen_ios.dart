import 'dart:io';
import 'dart:ui';
import 'package:cupertino_native/components/button.dart';
import 'package:cupertino_native/style/sf_symbol.dart';
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
import 'package:cupertino_native/cupertino_native.dart';

enum ActiveSheet { none, macros, measurements }

class TodayScreenIOS extends StatefulWidget {
  const TodayScreenIOS({super.key});

  @override
  State<TodayScreenIOS> createState() => _TodayScreenIOSState();
}

class _TodayScreenIOSState extends State<TodayScreenIOS> {
  ActiveSheet _activeSheet = ActiveSheet.none;

  final Set<ZoneType> _localCompletedZones = {};

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
    Navigator.push(context, CupertinoPageRoute(builder: (context) => const ProfileScreen()));
  }

  void _navigateToDeleteData() {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => const DeleteDataScreen()));
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

    final enabledZones = today.activeZones.where((z) => config.isEnabled(z)).toList();
    final int totalZones = enabledZones.length;
    final int localCompletedCount = enabledZones.where((z) {
      if (z == ZoneType.macronutrients || z == ZoneType.measurements) {
        return today.isZoneCompleted(z);
      }
      return _localCompletedZones.contains(z);
    }).length;
    final completion = totalZones > 0 ? localCompletedCount / totalZones : 1.0;

    return Stack(
      children: [
        CupertinoPageScaffold(
          backgroundColor: colors.background,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: Text('Today', style: TextStyle(color: colors.textPrimary)),
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
                      _getFormattedLongDate(),
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: colors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    _buildDailyGoalCard(context, colors, completion),
                    const SizedBox(height: 32),

                    if (activePhotoZones.isNotEmpty) ...[
                      _buildSectionHeader(
                        title: 'Today’s Tasks',
                        subtext: _getTasksRemainingText(today, config, isTaskOnly: true),
                        colors: colors,
                      ),
                      const SizedBox(height: 12),
                      ...activePhotoZones.map((zone) => _buildTaskCard(context, colors, today, zone)),
                      const SizedBox(height: 32),
                    ],

                    if (config.isEnabled(ZoneType.macronutrients) || config.isEnabled(ZoneType.measurements)) ...[
                      Text(
                        'Log Day',
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
                                  title: 'Macros',
                                  subtitle: today.isZoneCompleted(ZoneType.macronutrients) ? 'Logged' : 'Pending',
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
                                  title: 'Measurements',
                                  subtitle: today.isZoneCompleted(ZoneType.measurements) ? 'Recorded' : 'Not recorded',
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
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          image: DecorationImage(image: _provideAvatar(path), fit: BoxFit.cover),
          border: Border.all(color: colors.primary.withAlpha(30), width: 1),
          boxShadow: [BoxShadow(color: colors.textPrimary.withAlpha(5), blurRadius: 4, offset: const Offset(0, 2))],
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context, AppColors colors) {
    showCupertinoModalPopup(
      context: context,
      barrierColor: CupertinoColors.black.withAlpha(20),
      builder: (context) =>
          _LiquidGlassMenu(onProfile: _navigateToProfile, onDelete: _navigateToDeleteData, colors: colors),
    );
  }

  ImageProvider _provideAvatar(String? path) {
    if (path == null) return const AssetImage('assets/images/transformation/1.png');
    if (path.startsWith('assets/')) return AssetImage(path);
    return FileImage(File(path));
  }

  Widget _buildDailyGoalCard(BuildContext context, AppColors colors, double percentage) {
    final lightGreen = const Color(0xFFD0F288);
    const darkGreenText = Color(0xFF3A5A1A);

    return Container(
      padding: const EdgeInsets.all(20),
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
                'DAILY GOAL',
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
                  '${(percentage * 100).toInt()}% Done',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkGreenText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            percentage >= 1.0 ? 'Great job!' : 'Almost there!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            percentage >= 1.0 ? 'You have reached your daily goal.' : 'Complete 1 more task to reach your goal.',
            style: TextStyle(fontSize: 15, color: colors.textSecondary),
          ),
          const SizedBox(height: 20),
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

  Widget _buildTaskCard(BuildContext context, AppColors colors, WorkoutDay day, ZoneType zone) {
    final isCompleted = _localCompletedZones.contains(zone);

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
                    _getZoneLabel(zone),
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isCompleted
                        ? 'Captured at ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}'
                        : _getZoneSubtitle(zone),
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
                    onPressed: () {
                      CameraScreen.show(context, zone);
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
                size: 60,
                onPressed: () {
                  setState(() {
                    _localCompletedZones.add(zone);
                  });
                  CameraScreen.show(context, zone);
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

  String _getZoneLabel(ZoneType zone) {
    switch (zone) {
      case ZoneType.face:
        return 'Face Photo';
      case ZoneType.bodyFront:
        return 'Body Front Photo';
      case ZoneType.bodySide:
        return 'Body Side Photo';
      case ZoneType.bodyBack:
        return 'Body Back Photo';
      case ZoneType.measurements:
        return 'Body Measurements';
      case ZoneType.macronutrients:
        return 'Macronutrients';
    }
  }

  String _getZoneSubtitle(ZoneType zone) {
    switch (zone) {
      case ZoneType.measurements:
        return 'Not recorded yet';
      default:
        return 'Pending registration';
    }
  }

  String _getTasksRemainingText(WorkoutDay day, TrackingConfig config, {bool isTaskOnly = false}) {
    final zones = isTaskOnly
        ? day.activeZones.where(
            (z) => config.isEnabled(z) && z != ZoneType.macronutrients && z != ZoneType.measurements,
          )
        : day.activeZones.where((z) => config.isEnabled(z));

    final total = zones.length;
    final completed = zones.where((z) {
      if (z == ZoneType.macronutrients || z == ZoneType.measurements) {
        return day.isZoneCompleted(z);
      }
      return _localCompletedZones.contains(z);
    }).length;
    final remaining = total - completed;
    return '$remaining of $total tasks remaining';
  }

  String _getFormattedLongDate() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

class _LiquidGlassMenu extends StatelessWidget {
  final VoidCallback onProfile;
  final VoidCallback onDelete;
  final AppColors colors;

  const _LiquidGlassMenu({required this.onProfile, required this.onDelete, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 100, // Adjusted for Sliver Nav Bar height
          right: 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: 220,
                decoration: BoxDecoration(
                  color: colors.background.withAlpha(150),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border.withAlpha(80)),
                  boxShadow: [
                    BoxShadow(color: CupertinoColors.black.withAlpha(30), blurRadius: 30, offset: const Offset(0, 15)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildItem('Profile', CupertinoIcons.person_circle, () {
                      Navigator.pop(context);
                      onProfile();
                    }, false),
                    Container(height: 0.5, color: colors.border.withAlpha(80)),
                    _buildItem('Delete Data', CupertinoIcons.trash, () {
                      Navigator.pop(context);
                      onDelete();
                    }, true),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(String label, IconData icon, VoidCallback onTap, bool isDestructive) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: const Color(0x00000000),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isDestructive ? CupertinoColors.destructiveRed : colors.textPrimary),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 17,
                color: isDestructive ? CupertinoColors.destructiveRed : colors.textPrimary,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w400,
                fontFamily: '.SF Pro Text',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
