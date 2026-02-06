import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_palette.dart';
import '../../../domain/value_objects/measurement_type.dart';
import '../../widgets/scrollable_bar_chart.dart';

import '../../view_models/stats_view_model.dart';
import '../../../domain/entities/workout_day.dart';
import '../../../domain/entities/measurement.dart';

class MeasurementStatsScreenIOS extends StatelessWidget {
  const MeasurementStatsScreenIOS({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);
    final vm = context.watch<StatsViewModel>();
    final today = vm.getTodayMeasurements();

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Physical Progress'),
        backgroundColor: colors.background.withAlpha(200),
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            _buildSummaryHeader('Track Your Transformation', 'Physical measurements over time', colors),
            const SizedBox(height: 32),

            ...MeasurementType.values.map(
              (type) => Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: ScrollableBarChart(
                  metricType: 'measurement',
                  measurementType: type,
                  label: _getLabel(type).toUpperCase(),
                  unit: _getUnit(type),
                  colors: colors,
                ),
              ),
            ),

            const SizedBox(height: 16),
            _buildSectionTitle("Today's Measurements", colors),
            const SizedBox(height: 12),

            if (today != null && today.measurements.isNotEmpty)
              _buildTodaySection(today, colors)
            else
              _buildEmptyState('No measurements recorded today', colors),

            const SizedBox(height: 80),
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

  Widget _buildTodaySection(WorkoutDay today, AppColors colors) {
    return Column(children: today.measurements.map((m) => _buildMeasurementTile(m, colors)).toList());
  }

  Widget _buildMeasurementTile(Measurement m, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(_getEmoji(m.type), style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _getLabel(m.type),
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.textPrimary),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  m.value % 1 == 0 ? m.value.toInt().toString() : m.value.toStringAsFixed(1),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.primary),
                ),
                const SizedBox(width: 4),
                Text(m.unit, style: TextStyle(fontSize: 14, color: colors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border, style: BorderStyle.solid),
      ),
      child: Center(
        child: Text(text, style: TextStyle(color: colors.textMuted)),
      ),
    );
  }

  Widget _buildSummaryHeader(String title, String subtitle, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 16, color: colors.textSecondary)),
      ],
    );
  }

  String _getLabel(MeasurementType type) {
    switch (type) {
      case MeasurementType.weight:
        return 'Weight';
      case MeasurementType.waist:
        return 'Waist';
      case MeasurementType.chest:
        return 'Chest';
      case MeasurementType.hips:
        return 'Hips';
      case MeasurementType.armLeft:
        return 'Arm (L)';
      case MeasurementType.armRight:
        return 'Arm (R)';
      case MeasurementType.thighLeft:
        return 'Thigh (L)';
      case MeasurementType.thighRight:
        return 'Thigh (R)';
      case MeasurementType.neck:
        return 'Neck';
    }
  }

  String _getUnit(MeasurementType type) {
    if (type == MeasurementType.weight) return 'kg';
    return 'cm';
  }

  String _getEmoji(MeasurementType type) {
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
}
