import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cupertino_native_better/cupertino_native_better.dart';
import '../view_models/today_view_model.dart';

import '../../core/theme/theme_provider.dart';
import '../../core/theme/color_palette.dart';
import 'package:workout/l10n/generated/app_localizations.dart';
import '../../core/utils/unit_converter.dart';
import 'suffix_toggle_text_field.dart';
import '../../core/providers/units_provider.dart';

class MacroEntrySheet extends StatefulWidget {
  final VoidCallback onDismiss;

  const MacroEntrySheet({super.key, required this.onDismiss});

  @override
  State<MacroEntrySheet> createState() => _MacroEntrySheetState();
}

class _MacroEntrySheetState extends State<MacroEntrySheet> {
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final today = context.read<TodayViewModel>().today;
    final units = context.read<UnitsProvider>();
    final isMetric = units.isMetric;

    if (today?.macros != null) {
      _caloriesController.text = today!.macros!.calories > 0 ? today.macros!.calories.toStringAsFixed(0) : '';

      final protein = today.macros!.protein;
      final carbs = today.macros!.carbs;
      final fat = today.macros!.fat;

      if (isMetric) {
        _proteinController.text = protein > 0 ? protein.toStringAsFixed(1) : '';
        _carbsController.text = carbs > 0 ? carbs.toStringAsFixed(1) : '';
        _fatController.text = fat > 0 ? fat.toStringAsFixed(1) : '';
      } else {
        _proteinController.text = protein > 0 ? UnitConverter.gToOz(protein).toStringAsFixed(2) : '';
        _carbsController.text = carbs > 0 ? UnitConverter.gToOz(carbs).toStringAsFixed(2) : '';
        _fatController.text = fat > 0 ? UnitConverter.gToOz(fat).toStringAsFixed(2) : '';
      }
    }
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);
    final units = context.watch<UnitsProvider>();
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    const tabBarHeight = 84.0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [BoxShadow(color: colors.textPrimary.withAlpha(20), blurRadius: 40, offset: const Offset(0, -10))],
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + safeAreaBottom + tabBarHeight),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2.5)),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.today.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colors.textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.macros,
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colors.textPrimary),
                      ),
                    ],
                  ),
                  _buildCalendarIcon(colors),
                ],
              ),

              const SizedBox(height: 32),

              Text(
                AppLocalizations.of(context)!.logEntry,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      '🍽️ ${AppLocalizations.of(context)!.calories}',
                      _caloriesController,
                      'kcal',
                      units,
                      colors,
                      isCals: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      '🥩 ${AppLocalizations.of(context)!.protein}',
                      _proteinController,
                      units.isMetric ? 'g' : 'oz',
                      units,
                      colors,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      '🥔 ${AppLocalizations.of(context)!.carbs}',
                      _carbsController,
                      units.isMetric ? 'g' : 'oz',
                      units,
                      colors,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      '🧈 ${AppLocalizations.of(context)!.fats}',
                      _fatController,
                      units.isMetric ? 'g' : 'oz',
                      units,
                      colors,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: CNButton(
                      label: AppLocalizations.of(context)!.cancel,
                      config: const CNButtonConfig(style: CNButtonStyle.glass),
                      onPressed: widget.onDismiss,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CNButton(
                      label: AppLocalizations.of(context)!.saveLogs,
                      config: const CNButtonConfig(style: CNButtonStyle.prominentGlass),
                      onPressed: () => _save(units),
                    ),
                  ),
                ],
              ),
              SizedBox(height: bottomPadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarIcon(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withAlpha(100), width: 1.5),
      ),
      child: const Icon(CupertinoIcons.calendar, color: Color(0xFF10B981), size: 24),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String unit,
    UnitsProvider units,
    AppColors colors, {
    bool isCals = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textSecondary),
        ),
        const SizedBox(height: 8),
        SuffixToggleTextField(
          controller: controller,
          placeholder: '0',
          suffix: unit,
          colors: colors,
          onSuffixTap: () {
            if (isCals) return; // Calories don't toggle

            final isMetric = units.isMetric;
            final controllers = [_proteinController, _carbsController, _fatController];
            for (var c in controllers) {
              final val = double.tryParse(c.text);
              if (val != null) {
                if (isMetric) {
                  c.text = UnitConverter.gToOz(val).toStringAsFixed(2);
                } else {
                  c.text = UnitConverter.ozToG(val).toStringAsFixed(1);
                }
              }
            }
            units.toggleUnitSystem();
          },
        ),
      ],
    );
  }

  void _save(UnitsProvider units) async {
    double calories = double.tryParse(_caloriesController.text) ?? 0;
    double protein = double.tryParse(_proteinController.text) ?? 0;
    double carbs = double.tryParse(_carbsController.text) ?? 0;
    double fat = double.tryParse(_fatController.text) ?? 0;

    if (!units.isMetric) {
      protein = UnitConverter.ozToG(protein);
      carbs = UnitConverter.ozToG(carbs);
      fat = UnitConverter.ozToG(fat);
    }

    await context.read<TodayViewModel>().updateMacros(calories, protein, carbs, fat);
    widget.onDismiss();
  }
}
