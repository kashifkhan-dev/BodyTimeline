import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../camera/camera_screen.dart';
import '../../view_models/today_view_model.dart';
import '../../../domain/entities/workout_day.dart';
import '../../../domain/value_objects/zone_type.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_palette.dart';
import '../../widgets/macro_entry_sheet.dart';
import '../../widgets/measurement_entry_sheet.dart';
import '../../../domain/entities/tracking_config.dart';
import '../../view_models/settings_view_model.dart';

enum ActiveSheet { none, macros, measurements }

class TodayScreenAndroid extends StatefulWidget {
  const TodayScreenAndroid({super.key});

  @override
  State<TodayScreenAndroid> createState() => _TodayScreenAndroidState();
}

class _TodayScreenAndroidState extends State<TodayScreenAndroid> {
  final Set<ZoneType> _localCompletedZones = {};

  void _showSheet(ActiveSheet sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSheetContent(sheet),
    );
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
    final int localCompletedCount = enabledZones.where((z) {
      if (z == ZoneType.macronutrients || z == ZoneType.measurements) {
        return today.isZoneCompleted(z);
      }
      return _localCompletedZones.contains(z);
    }).length;
    final completion = totalZones > 0 ? localCompletedCount / totalZones : 1.0;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Today'),
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
                      child: InkWell(
                        onTap: () => _showSheet(ActiveSheet.measurements),
                        borderRadius: BorderRadius.circular(24),
                        child: _buildLogCard(
                          icon: Icons.straighten,
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
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(AppColors colors) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: colors.card,
      backgroundImage: const AssetImage('assets/images/transformation/1.png'),
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

  Widget _buildTaskCard(BuildContext context, AppColors colors, WorkoutDay day, ZoneType zone) {
    final isCompleted = _localCompletedZones.contains(zone);

    return Card(
      elevation: 0,
      color: colors.card,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(14)),
          child: Icon(_getZoneIcon(zone), size: 24, color: colors.textPrimary),
        ),
        title: Text(
          _getZoneLabel(zone),
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        subtitle: Text(
          isCompleted
              ? 'Captured at ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}'
              : _getZoneSubtitle(zone),
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
        trailing: isCompleted
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 28, color: Colors.green),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.flip_camera_ios),
                    onPressed: () => CameraScreen.show(context, zone),
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: () {
                  setState(() {
                    _localCompletedZones.add(zone);
                  });
                  CameraScreen.show(context, zone);
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
