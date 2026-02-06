import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/history_view_model.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_palette.dart';
import '../../../domain/entities/workout_day.dart';
import '../../../domain/value_objects/zone_type.dart';

class HistoryScreenAndroid extends StatelessWidget {
  const HistoryScreenAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);

    final monthNames = [
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
    final dateSubtext = '${monthNames[vm.selectedDate.month - 1]} ${vm.selectedDate.year}';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
      ),
      body: vm.isLoading
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : RefreshIndicator(
              onRefresh: () => vm.refresh(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  Text(
                    dateSubtext,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  _WeekSelector(vm: vm, colors: colors),
                  const SizedBox(height: 32),
                  _DayDetails(vm: vm, colors: colors),
                  const SizedBox(height: 48),
                  _buildSectionTitle('Streak', colors),
                  const SizedBox(height: 12),
                  _buildStreakHero(vm, colors),
                  const SizedBox(height: 32),
                  _buildSectionTitle('2026 Activity', colors),
                  const SizedBox(height: 12),
                  _buildHeatmapSection(vm, colors, 2026),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Nutrients Overview', colors),
                  const SizedBox(height: 12),
                  _buildNutrientsGrid(vm, colors),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Body Progress', colors),
                  const SizedBox(height: 12),
                  _buildMeasurementsCard(vm, colors),
                  const SizedBox(height: 120),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, AppColors colors) {
    return Text(
      title,
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.textPrimary),
    );
  }

  Widget _buildStreakHero(HistoryViewModel vm, AppColors colors) {
    return Card(
      elevation: 0,
      color: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CURRENT STREAK',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: colors.textSecondary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${vm.currentStreak}',
                  style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: colors.textPrimary),
                ),
                const SizedBox(width: 8),
                Text(
                  'days',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: colors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapSection(HistoryViewModel vm, AppColors colors, int year) {
    return Card(
      elevation: 0,
      color: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GithubHeatmap(vm: vm, year: year, colors: colors),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildSimpleStat(colors, '${vm.activeDaysCount} days active'),
                const SizedBox(width: 16),
                _buildSimpleStat(colors, '${vm.missedDaysCount} days missed'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleStat(AppColors colors, String text) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: text.contains('active') ? colors.success : colors.textMuted.withAlpha(100),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
      ],
    );
  }

  Widget _buildNutrientsGrid(HistoryViewModel vm, AppColors colors) {
    final macros = vm.averageMacros;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildValueCard('AVG CALS', vm.averageCalories.toStringAsFixed(0), 'kcal', 'Daily avg', colors),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildValueCard('PROTEIN', macros.protein.toStringAsFixed(0), 'g', 'Daily avg', colors)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildValueCard('CARBS', macros.carbs.toStringAsFixed(0), 'g', 'Daily avg', colors)),
            const SizedBox(width: 16),
            Expanded(child: _buildValueCard('FATS', macros.fat.toStringAsFixed(0), 'g', 'Daily avg', colors)),
          ],
        ),
      ],
    );
  }

  Widget _buildMeasurementsCard(HistoryViewModel vm, AppColors colors) {
    return _buildValueCard('LOGGING FREQUENCY', '${vm.measurementFrequency}', 'sessions', 'Keep it up!', colors);
  }

  Widget _buildValueCard(String title, String value, String unit, String subtext, AppColors colors) {
    return Card(
      elevation: 0,
      color: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.textMuted, letterSpacing: 0.8),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colors.textPrimary),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtext, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _WeekSelector extends StatelessWidget {
  final HistoryViewModel vm;
  final AppColors colors;

  const _WeekSelector({required this.vm, required this.colors});

  @override
  Widget build(BuildContext context) {
    final selected = vm.selectedDate;
    final startOfWeek = selected.subtract(Duration(days: selected.weekday - 1));
    final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Card(
      elevation: 0,
      color: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final date = startOfWeek.add(Duration(days: index));
            final isSelected = date.day == selected.day && date.month == selected.month && date.year == selected.year;
            final completion = vm.getCompletionForDate(date);

            return InkWell(
              onTap: () => vm.setSelectedDate(date),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      dayNames[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : colors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (completion > 0)
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : colors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _DayDetails extends StatelessWidget {
  final HistoryViewModel vm;
  final AppColors colors;

  const _DayDetails({required this.vm, required this.colors});

  @override
  Widget build(BuildContext context) {
    final day = vm.dayForSelectedDate;
    final now = DateTime.now();
    final isToday =
        vm.selectedDate.day == now.day && vm.selectedDate.month == now.month && vm.selectedDate.year == now.year;
    final title = isToday ? 'Today' : '${vm.selectedDate.day}/${vm.selectedDate.month}/${vm.selectedDate.year}';

    if (day == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.textPrimary),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: colors.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text('No records', style: TextStyle(color: colors.textMuted)),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        const SizedBox(height: 16),
        ...day.activeZones.map((zone) => _buildTaskDetailCard(day, zone, colors)),
      ],
    );
  }

  Widget _buildTaskDetailCard(WorkoutDay day, ZoneType zone, AppColors colors) {
    final isCompleted = day.isZoneCompleted(zone);
    return Card(
      elevation: 0,
      color: colors.card,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: Icon(_getZoneIcon(zone), color: colors.textPrimary),
        title: Text(_getZoneLabel(zone), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(isCompleted ? 'Completed' : 'Pending'),
        trailing: Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? colors.success : colors.textMuted,
        ),
      ),
    );
  }

  IconData _getZoneIcon(ZoneType zone) {
    switch (zone) {
      case ZoneType.face:
        return Icons.portrait;
      case ZoneType.measurements:
        return Icons.straighten;
      case ZoneType.macronutrients:
        return Icons.restaurant;
      default:
        return Icons.person;
    }
  }

  String _getZoneLabel(ZoneType zone) {
    switch (zone) {
      case ZoneType.face:
        return 'Face';
      case ZoneType.bodyFront:
        return 'Body Front';
      case ZoneType.bodySide:
        return 'Body Side';
      case ZoneType.bodyBack:
        return 'Body Back';
      case ZoneType.measurements:
        return 'Measurements';
      case ZoneType.macronutrients:
        return 'Macros';
    }
  }
}

class _GithubHeatmap extends StatelessWidget {
  final HistoryViewModel vm;
  final int year;
  final AppColors colors;

  const _GithubHeatmap({required this.vm, required this.year, required this.colors});

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, 1, 1);
    final int sunOffset = firstDay.weekday == 7 ? 0 : firstDay.weekday;
    final gridStartDate = firstDay.subtract(Duration(days: sunOffset));
    final weeksCount = 53;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const SizedBox(height: 20),
            _buildDayLabel('M'),
            const SizedBox(height: 14),
            _buildDayLabel('W'),
            const SizedBox(height: 14),
            _buildDayLabel('F'),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(weeksCount, (wIdx) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Column(
                    children: List.generate(7, (dIdx) {
                      final date = gridStartDate.add(Duration(days: wIdx * 7 + dIdx));
                      if (date.year != year) return _buildCell(Colors.transparent);
                      final completion = vm.getCompletionForDate(date);
                      return _buildCell(_getCellColor(completion));
                    }),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayLabel(String label) => Text(label, style: TextStyle(fontSize: 10, color: colors.textMuted));
  Widget _buildCell(Color color) => Container(
    width: 12,
    height: 12,
    margin: const EdgeInsets.symmetric(vertical: 1),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
  );

  Color _getCellColor(double completion) {
    if (completion <= 0) return colors.brightness == Brightness.light ? Colors.grey[200]! : Colors.white10;
    return colors.primary.withValues(alpha: completion.clamp(0.2, 1.0));
  }
}
