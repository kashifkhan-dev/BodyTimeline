import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_palette.dart';
import '../../widgets/scrollable_bar_chart.dart';
import '../../view_models/stats_view_model.dart';
import '../../../domain/entities/workout_day.dart';
import 'package:workout/l10n/generated/app_localizations.dart';

class NutrientStatsScreen extends StatelessWidget {
  const NutrientStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);
    final vm = context.watch<StatsViewModel>();
    final today = vm.getTodayMeasurements();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.nutrientStatistics),
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSummaryHeader(
            AppLocalizations.of(context)!.macronutrients,
            AppLocalizations.of(context)!.nutritionalIntakeHistory,
            colors,
          ),
          const SizedBox(height: 32),
          ScrollableBarChart(
            metricType: 'calories',
            label: AppLocalizations.of(context)!.avgCalories,
            unit: 'kcal',
            colors: colors,
          ),
          const SizedBox(height: 32),
          ScrollableBarChart(
            metricType: 'protein',
            label: AppLocalizations.of(context)!.protein,
            unit: 'g',
            colors: colors,
          ),
          const SizedBox(height: 32),
          ScrollableBarChart(
            metricType: 'carbs',
            label: AppLocalizations.of(context)!.carbs,
            unit: 'g',
            colors: colors,
          ),
          const SizedBox(height: 32),
          ScrollableBarChart(metricType: 'fats', label: AppLocalizations.of(context)!.fats, unit: 'g', colors: colors),

          const SizedBox(height: 32),
          _buildSectionTitle(AppLocalizations.of(context)!.todaysNutrients, colors),
          const SizedBox(height: 12),
          if (today != null && today.macros != null)
            _buildTodayNutrients(context, today, colors)
          else
            _buildEmptyState(AppLocalizations.of(context)!.noNutrientsLoggedToday, colors),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppColors colors) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary),
    );
  }

  Widget _buildTodayNutrients(BuildContext context, WorkoutDay today, AppColors colors) {
    final m = today.macros!;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildNutrientTile(l10n.calories, m.calories, 'kcal', '🍽️', colors),
        _buildNutrientTile(l10n.protein, m.protein, 'g', '🥩', colors),
        _buildNutrientTile(l10n.carbs, m.carbs, 'g', '🍝', colors),
        _buildNutrientTile(l10n.fats, m.fat, 'g', '🥑', colors),
      ],
    );
  }

  Widget _buildNutrientTile(String title, double value, String unit, String emoji, AppColors colors) {
    return Card(
      elevation: 0,
      color: colors.card,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: colors.surface,
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value.toStringAsFixed(0),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.primary),
            ),
            const SizedBox(width: 4),
            Text(unit, style: TextStyle(fontSize: 14, color: colors.textSecondary)),
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
}
