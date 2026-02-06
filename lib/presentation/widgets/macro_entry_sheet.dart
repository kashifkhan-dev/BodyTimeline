import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cupertino_native/cupertino_native.dart';
import '../view_models/today_view_model.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/color_palette.dart';
import 'package:workout/l10n/generated/app_localizations.dart';

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
    if (today?.macros != null) {
      _caloriesController.text = today!.macros!.calories > 0 ? today.macros!.calories.toString() : '';
      _proteinController.text = today.macros!.protein > 0 ? today.macros!.protein.toString() : '';
      _carbsController.text = today.macros!.carbs > 0 ? today.macros!.carbs.toString() : '';
      _fatController.text = today.macros!.fat > 0 ? today.macros!.fat.toString() : '';
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
              // Pull Handle
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
                      colors,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField('🥩 ${AppLocalizations.of(context)!.protein}', _proteinController, 'g', colors),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildField('🥔 ${AppLocalizations.of(context)!.carbs}', _carbsController, 'g', colors),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField('🧈 ${AppLocalizations.of(context)!.fats}', _fatController, 'g', colors)),
                ],
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: CNButton(label: AppLocalizations.of(context)!.cancel, onPressed: widget.onDismiss),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CNButton(label: AppLocalizations.of(context)!.saveLogs, onPressed: _save),
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

  Widget _buildField(String label, TextEditingController controller, String unit, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textSecondary),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          style: TextStyle(color: colors.textPrimary, fontSize: 17),
          placeholder: '0',
          suffix: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(unit, style: TextStyle(color: colors.textMuted, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  void _save() async {
    final calories = double.tryParse(_caloriesController.text) ?? 0;
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;

    await context.read<TodayViewModel>().updateMacros(calories, protein, carbs, fat);
    // Usually loggers dismiss after save.
    widget.onDismiss();
  }
}
