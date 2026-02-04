import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cupertino_native/cupertino_native.dart';
import '../view_models/today_view_model.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/color_palette.dart';

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

    // Tab bar height estimate to avoid covering/being covered incorrectly
    const tabBarHeight = 84.0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 500) {
          widget.onDismiss();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: colors.textPrimary.withAlpha(30), blurRadius: 30, offset: const Offset(0, -10))],
        ),
        padding: EdgeInsets.fromLTRB(24, 12, 24, 12 + safeAreaBottom + tabBarHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pull Handle
            Center(
              child: Container(
                width: 36,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2.5)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Macronutrients',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.textPrimary),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: widget.onDismiss,
                  child: Icon(CupertinoIcons.xmark_circle_fill, color: colors.textSecondary.withAlpha(150), size: 28),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildField('Calories', _caloriesController, 'kcal', colors)),
                const SizedBox(width: 16),
                Expanded(child: _buildField('Protein', _proteinController, 'g', colors)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildField('Carbs', _carbsController, 'g', colors)),
                const SizedBox(width: 16),
                Expanded(child: _buildField('Fat', _fatController, 'g', colors)),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: CNButton(label: 'Cancel', onPressed: widget.onDismiss),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CNButton(label: 'Save Changes', onPressed: _save),
                ),
              ],
            ),
            SizedBox(height: bottomPadding),
          ],
        ),
      ),
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
          placeholderStyle: TextStyle(color: colors.textMuted),
          suffix: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(unit, style: TextStyle(color: colors.textMuted, fontSize: 14)),
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
    widget.onDismiss();
  }
}
