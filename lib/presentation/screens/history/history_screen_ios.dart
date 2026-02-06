import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../view_models/history_view_model.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_palette.dart';
import '../../../domain/entities/workout_day.dart';
import '../../../domain/value_objects/zone_type.dart';
import '../../../domain/value_objects/measurement_type.dart';
import '../../../domain/entities/measurement.dart';
import '../stats/nutrient_stats_screen_ios.dart';
import '../stats/measurement_stats_screen_ios.dart';
import 'package:workout/l10n/generated/app_localizations.dart';

class HistoryScreenIOS extends StatelessWidget {
  const HistoryScreenIOS({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);

    final l10n = AppLocalizations.of(context)!;
    final monthNames = [
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
    final dateSubtext = '${monthNames[vm.selectedDate.month - 1]} ${vm.selectedDate.year}';

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(AppLocalizations.of(context)!.history, style: TextStyle(color: colors.textPrimary)),
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
                  Text(
                    dateSubtext,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  _WeekSelector(vm: vm, colors: colors),
                  const SizedBox(height: 32),
                  _DayDetails(vm: vm, colors: colors),
                  const SizedBox(height: 48),
                  _buildSectionTitle(AppLocalizations.of(context)!.streak, colors),
                  const SizedBox(height: 12),
                  _buildStreakHero(context, vm, colors),
                  const SizedBox(height: 32),
                  _buildSectionTitle('${vm.selectedDate.year} ${AppLocalizations.of(context)!.activitySuffix}', colors),
                  const SizedBox(height: 12),
                  _buildHeatmapSection(context, vm, colors, 2026),
                  const SizedBox(height: 32),
                  _buildSectionTitle(AppLocalizations.of(context)!.nutrientsOverview, colors),
                  const SizedBox(height: 12),
                  _buildNutrientsGrid(context, vm, colors),
                  const SizedBox(height: 32),
                  _buildSectionTitle(AppLocalizations.of(context)!.measurementsOverview, colors),
                  const SizedBox(height: 12),
                  _buildMeasurementsOverview(context, vm, colors),
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

  Widget _buildStreakHero(BuildContext context, HistoryViewModel vm, AppColors colors) {
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
                  Text(
                    AppLocalizations.of(context)!.currentStreak,
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
                        AppLocalizations.of(context)!.days,
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

  Widget _buildHeatmapSection(BuildContext context, HistoryViewModel vm, AppColors colors, int year) {
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
              _buildSimpleStat(colors, AppLocalizations.of(context)!.daysActive(vm.activeDaysCount)),
              const SizedBox(width: 16),
              _buildSimpleStat(colors, AppLocalizations.of(context)!.daysMissed(vm.missedDaysCount)),
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
            color: text.toLowerCase().contains('active') || text.toLowerCase().contains('activo')
                ? colors.success
                : colors.textMuted.withAlpha(100),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
      ],
    );
  }

  Widget _buildNutrientsGrid(BuildContext context, HistoryViewModel vm, AppColors colors) {
    final macros = vm.averageMacros;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(CupertinoPageRoute(builder: (context) => const NutrientStatsScreenIOS())),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildValueCard(
                  AppLocalizations.of(context)!.avgCalories,
                  vm.averageCalories.toStringAsFixed(0),
                  'kcal',
                  AppLocalizations.of(context)!.dailyAverage,
                  colors,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildValueCard(
                  AppLocalizations.of(context)!.protein,
                  macros.protein.toStringAsFixed(0),
                  'g',
                  AppLocalizations.of(context)!.dailyAverage,
                  colors,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildValueCard(
                  AppLocalizations.of(context)!.carbs,
                  macros.carbs.toStringAsFixed(0),
                  'g',
                  AppLocalizations.of(context)!.dailyAverage,
                  colors,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildValueCard(
                  AppLocalizations.of(context)!.fats,
                  macros.fat.toStringAsFixed(0),
                  'g',
                  AppLocalizations.of(context)!.dailyAverage,
                  colors,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsOverview(BuildContext context, HistoryViewModel vm, AppColors colors) {
    final latest = vm.latestMeasurements;
    if (latest.isEmpty) return _buildEmptyCard(AppLocalizations.of(context)!.noMeasurementsYet, colors);

    final entries = latest.entries.toList();

    return Column(
      children: [
        for (int i = 0; i < entries.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: (i + 2 < entries.length) ? 16 : 0),
            child: Row(
              children: [
                Expanded(child: _buildMeasurementValueCard(context, entries[i].value, colors)),
                const SizedBox(width: 16),
                if (i + 1 < entries.length)
                  Expanded(child: _buildMeasurementValueCard(context, entries[i + 1].value, colors))
                else
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMeasurementValueCard(BuildContext context, Measurement m, AppColors colors) {
    return GestureDetector(
      onTap: () =>
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) => const MeasurementStatsScreenIOS())),
      child: Container(
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
            Row(
              children: [
                Text(_getMeasurementEmoji(m.type), style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _getMeasurementLabel(context, m.type).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colors.textMuted,
                      letterSpacing: 0.8,
                    ),
                    overflow: TextOverflow.ellipsis,
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
                  m.value % 1 == 0 ? m.value.toInt().toString() : m.value.toStringAsFixed(1),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colors.textPrimary),
                ),
                const SizedBox(width: 4),
                Text(
                  m.unit,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.latestRecorded,
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _getMeasurementLabel(BuildContext context, MeasurementType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case MeasurementType.weight:
        return l10n.weight;
      case MeasurementType.waist:
        return l10n.waist;
      case MeasurementType.chest:
        return l10n.chest;
      case MeasurementType.hips:
        return l10n.hips;
      case MeasurementType.armLeft:
        return l10n.armLeft;
      case MeasurementType.armRight:
        return l10n.armRight;
      case MeasurementType.thighLeft:
        return l10n.thighLeft;
      case MeasurementType.thighRight:
        return l10n.thighRight;
      case MeasurementType.neck:
        return l10n.neck;
    }
  }

  String _getMeasurementEmoji(MeasurementType type) {
    switch (type) {
      case MeasurementType.weight:
        return '⚖️';
      case MeasurementType.waist:
        return '📏';
      case MeasurementType.chest:
        return '👕';
      case MeasurementType.hips:
        return '👖';
      case MeasurementType.armLeft:
        return '💪';
      case MeasurementType.armRight:
        return '💪';
      case MeasurementType.thighLeft:
        return '🦵';
      case MeasurementType.thighRight:
        return '🦵';
      case MeasurementType.neck:
        return '👔';
    }
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
}

class _WeekSelector extends StatelessWidget {
  final HistoryViewModel vm;
  final AppColors colors;

  const _WeekSelector({required this.vm, required this.colors});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selected = vm.selectedDate;
    final startOfWeek = selected.subtract(Duration(days: selected.weekday - 1));
    final dayNames = [l10n.mon, l10n.tue, l10n.wed, l10n.thu, l10n.fri, l10n.sat, l10n.sun];

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
                    ),
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
    final title = isToday ? AppLocalizations.of(context)!.today : _formatDate(context, vm.selectedDate);

    if (day == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.textPrimary),
          ),
          const SizedBox(height: 16),
          _buildEmptyCard(AppLocalizations.of(context)!.noRecordsDay, colors),
        ],
      );
    }

    final totalZones = day.activeZones.length;
    final completedZones = day.activeZones.where((z) => day.isZoneCompleted(z)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        Text(
          AppLocalizations.of(context)!.zonesCompleted(completedZones, totalZones),
          style: TextStyle(fontSize: 15, color: colors.textSecondary),
        ),
        const SizedBox(height: 20),
        ...day.activeZones.map((zone) => _buildTaskDetailCard(context, day, zone, colors)),
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

  Widget _buildTaskDetailCard(BuildContext context, WorkoutDay day, ZoneType zone, AppColors colors) {
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
                    _getZoneLabel(context, zone),
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.textPrimary),
                  ),
                  Text(
                    isCompleted ? AppLocalizations.of(context)!.completed : AppLocalizations.of(context)!.pending,
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

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final months = [
      l10n.jan,
      l10n.feb,
      l10n.mar,
      l10n.apr,
      l10n.may,
      l10n.jun,
      l10n.jul,
      l10n.aug,
      l10n.sep,
      l10n.oct,
      l10n.nov,
      l10n.dec,
    ];
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
    final int sunOffset = firstDay.weekday == 7 ? 0 : firstDay.weekday;
    final gridStartDate = firstDay.subtract(Duration(days: sunOffset));
    final weeksCount = 53;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const SizedBox(height: 28),
            _buildDayLabel(AppLocalizations.of(context)!.mon[0]),
            const SizedBox(height: 14),
            _buildDayLabel(AppLocalizations.of(context)!.wed[0]),
            const SizedBox(height: 14),
            _buildDayLabel(AppLocalizations.of(context)!.fri[0]),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMonthLabels(context, gridStartDate, weeksCount),
                const SizedBox(height: 8),
                Row(
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
    );
  }

  Widget _buildMonthLabels(BuildContext context, DateTime gridStartDate, int weeksCount) {
    final l10n = AppLocalizations.of(context)!;
    final monthNames = [
      l10n.jan,
      l10n.feb,
      l10n.mar,
      l10n.apr,
      l10n.may,
      l10n.jun,
      l10n.jul,
      l10n.aug,
      l10n.sep,
      l10n.oct,
      l10n.nov,
      l10n.dec,
    ];
    final List<Widget> labels = [];
    int lastMonth = -1;
    for (int i = 0; i < weeksCount; i++) {
      final date = gridStartDate.add(Duration(days: i * 7 + 3));
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

  Widget _buildDayLabel(String label) => SizedBox(
    height: 14,
    child: Center(
      child: Text(
        label,
        style: TextStyle(fontSize: 9, color: colors.textMuted, fontWeight: FontWeight.bold),
      ),
    ),
  );
  Widget _buildCell(Color color) => Container(
    width: 12,
    height: 12,
    margin: const EdgeInsets.symmetric(vertical: 1),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
  );

  Color _getCellColor(double completion) {
    if (completion <= 0) return colors.brightness == Brightness.light ? const Color(0xFFF3F4F6) : colors.surface;
    if (colors.brightness == Brightness.light) {
      if (completion < 0.25) return const Color(0xFFD1FAE5);
      if (completion < 0.50) return const Color(0xFF6EE7B7);
      if (completion < 0.75) return const Color(0xFF34D399);
      if (completion < 1.0) return const Color(0xFF10B981);
      return const Color(0xFF065F46);
    } else {
      if (completion < 0.25) return colors.primary.withAlpha(40);
      if (completion < 0.50) return colors.primary.withAlpha(80);
      if (completion < 0.75) return colors.primary.withAlpha(140);
      if (completion < 1.0) return colors.primary.withAlpha(200);
      return colors.primary;
    }
  }
}
