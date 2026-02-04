import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../view_models/history_view_model.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/color_palette.dart';
import '../../domain/entities/workout_day.dart';
import '../../domain/value_objects/zone_type.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);

    // Dynamic title for selected month/year
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

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text('History', style: TextStyle(color: colors.textPrimary)),
            backgroundColor: colors.background.withAlpha(200),
            border: Border(bottom: BorderSide(color: colors.border)),
          ),
          if (vm.isLoading)
            const SliverFillRemaining(child: Center(child: CupertinoActivityIndicator()))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. Month/Year Subtitle
                  Text(
                    dateSubtext,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // 2. Week Selector
                  _WeekSelector(vm: vm, colors: colors),
                  const SizedBox(height: 32),

                  // 3. Day Details Section
                  _DayDetails(vm: vm, colors: colors),
                  const SizedBox(height: 48),

                  // 4. Streak Hero
                  _buildSectionTitle('Streak', colors),
                  const SizedBox(height: 12),
                  _buildStreakHero(vm, colors),
                  const SizedBox(height: 32),

                  // 5. Heatmap Section
                  _buildSectionTitle('2026 Activity', colors),
                  const SizedBox(height: 12),
                  _buildHeatmapSection(vm, colors, 2026),
                  const SizedBox(height: 32),

                  // 6. Nutrients Overview
                  _buildSectionTitle('Nutrients Overview', colors),
                  const SizedBox(height: 12),
                  _buildNutrientsGrid(vm, colors),
                  const SizedBox(height: 32),

                  // 7. Body Progress
                  _buildSectionTitle('Body Progress', colors),
                  const SizedBox(height: 12),
                  _buildMeasurementsCard(vm, colors),
                  const SizedBox(height: 120),
                ]),
              ),
            ),
        ],
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.primary.withAlpha(40), width: 1.5),
        boxShadow: [BoxShadow(color: colors.textPrimary.withAlpha(5), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(right: 0, top: 0, bottom: 0, width: 8, child: Container(color: colors.success)),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                    ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapSection(HistoryViewModel vm, AppColors colors, int year) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: colors.textPrimary.withAlpha(5), blurRadius: 20, offset: const Offset(0, 10))],
      ),
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
              child: _buildValueCard(
                'AVG CALORIES',
                vm.averageCalories
                    .toStringAsFixed(0)
                    .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'),
                'kcal',
                'Daily average',
                colors,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildValueCard('PROTEIN', macros.protein.toStringAsFixed(0), 'g', 'Daily average', colors),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildValueCard('CARBS', macros.carbs.toStringAsFixed(0), 'g', 'Daily average', colors)),
            const SizedBox(width: 16),
            Expanded(child: _buildValueCard('FATS', macros.fat.toStringAsFixed(0), 'g', 'Daily average', colors)),
          ],
        ),
      ],
    );
  }

  Widget _buildMeasurementsCard(HistoryViewModel vm, AppColors colors) {
    return _buildValueCard('LOGGING FREQUENCY', '${vm.measurementFrequency}', 'sessions', 'Keep it up!', colors);
  }

  Widget _buildValueCard(String title, String value, String unit, String subtext, AppColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: colors.textPrimary.withAlpha(5), blurRadius: 15, offset: const Offset(0, 8))],
      ),
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
    );
  }
}

class _WeekSelector extends StatelessWidget {
  final HistoryViewModel vm;
  final AppColors colors;

  const _WeekSelector({required this.vm, required this.colors});

  @override
  Widget build(BuildContext context) {
    // Current selected date and its week
    final selected = vm.selectedDate;
    final startOfWeek = selected.subtract(Duration(days: selected.weekday - 1));

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: colors.textPrimary.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final date = startOfWeek.add(Duration(days: index));
          final isSelected = date.day == selected.day && date.month == selected.month && date.year == selected.year;
          // isToday removed as it was unused
          final completion = vm.getCompletionForDate(date);

          return GestureDetector(
            onTap: () => vm.setSelectedDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? (colors.brightness == Brightness.light ? colors.textPrimary : colors.background)
                    : CupertinoColors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    dayNames[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? (colors.brightness == Brightness.light ? colors.background : colors.textPrimary)
                          : colors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? (colors.brightness == Brightness.light ? colors.background : colors.textPrimary)
                          : colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (completion > 0)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (colors.brightness == Brightness.light ? colors.background : colors.primary)
                            : colors.success,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 4),
                ],
              ),
            ),
          );
        }),
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

    final title = isToday ? 'Today' : _formatDate(vm.selectedDate);

    if (day == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.textPrimary),
          ),
          const SizedBox(height: 16),
          _buildEmptyCard('No records for this day', colors),
        ],
      );
    }

    final totalZones = day.activeZones.length;
    final completedZones = day.activeZones.where((z) => day.isZoneCompleted(z)).length;
    final statusText = '$completedZones of $totalZones zones completed';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        Text(statusText, style: TextStyle(fontSize: 15, color: colors.textSecondary)),
        const SizedBox(height: 20),
        ...day.activeZones.map((zone) => _buildTaskDetailCard(day, zone, colors)),
      ],
    );
  }

  Widget _buildEmptyCard(String text, AppColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Center(
        child: Text(text, style: TextStyle(color: colors.textMuted, fontSize: 15)),
      ),
    );
  }

  Widget _buildTaskDetailCard(WorkoutDay day, ZoneType zone, AppColors colors) {
    final isCompleted = day.isZoneCompleted(zone);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: colors.textPrimary.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Icon(_getZoneIcon(zone), size: 20, color: colors.textPrimary)),
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
                  Text(
                    isCompleted ? 'Completed' : 'Pending',
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              isCompleted ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
              color: isCompleted ? colors.success : colors.textMuted,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getZoneIcon(ZoneType zone) {
    switch (zone) {
      case ZoneType.face:
        return CupertinoIcons.person_crop_circle;
      case ZoneType.bodyFront:
      case ZoneType.bodySide:
      case ZoneType.bodyBack:
        return CupertinoIcons.person_alt;
      case ZoneType.measurements:
        return CupertinoIcons.gauge;
      case ZoneType.macronutrients:
        return CupertinoIcons.lab_flask;
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
        return 'Body Measurements';
      case ZoneType.macronutrients:
        return 'Macronutrients';
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
    final lastDay = DateTime(year, 12, 31);
    final int firstWeekday = firstDay.weekday;
    final int sunOffset = firstWeekday == 7 ? 0 : firstWeekday;
    final gridStartDate = firstDay.subtract(Duration(days: sunOffset));
    final totalDaysCount = lastDay.difference(gridStartDate).inDays + 1;
    final weeksCount = (totalDaysCount / 7).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const SizedBox(height: 28),
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
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMonthLabels(gridStartDate, weeksCount),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(weeksCount, (wIdx) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.5),
                          child: Column(
                            children: List.generate(7, (dIdx) {
                              final date = gridStartDate.add(Duration(days: wIdx * 7 + dIdx));
                              if (date.year != year) return _buildCell(CupertinoColors.transparent);
                              final completion = vm.getCompletionForDate(date);
                              return _buildCell(_getCellColor(completion));
                            }),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthLabels(DateTime gridStartDate, int weeksCount) {
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final List<Widget> labels = [];
    int lastMonth = -1;

    for (int i = 0; i < weeksCount; i++) {
      final date = gridStartDate.add(Duration(days: i * 7 + 3)); // Check mid-week
      if (date.month != lastMonth && date.year == year) {
        labels.add(
          Positioned(
            left: i * 15.0,
            child: Text(
              monthNames[date.month - 1],
              style: TextStyle(fontSize: 10, color: colors.textMuted, fontWeight: FontWeight.bold),
            ),
          ),
        );
        lastMonth = date.month;
      }
    }

    return SizedBox(
      height: 14,
      width: weeksCount * 15.0,
      child: Stack(children: labels),
    );
  }

  Widget _buildDayLabel(String label) {
    return SizedBox(
      height: 14,
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontSize: 9, color: colors.textMuted, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCell(Color color) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
    );
  }

  Color _getCellColor(double completion) {
    if (completion <= 0) {
      return colors.brightness == Brightness.light ? const Color(0xFFF3F4F6) : colors.surface;
    }

    if (colors.brightness == Brightness.light) {
      if (completion < 0.25) return const Color(0xFFD1FAE5);
      if (completion < 0.50) return const Color(0xFF6EE7B7);
      if (completion < 0.75) return const Color(0xFF34D399);
      if (completion < 1.0) return const Color(0xFF10B981);
      return const Color(0xFF065F46); // 100% is deep success green
    } else {
      // Dark mode heatmap colors - deeper depth and glowing emeralds
      if (completion < 0.25) return colors.primary.withAlpha(40);
      if (completion < 0.50) return colors.primary.withAlpha(80);
      if (completion < 0.75) return colors.primary.withAlpha(140);
      if (completion < 1.0) return colors.primary.withAlpha(200);
      return colors.primary; // 100% is full glowing primary
    }
  }
}
