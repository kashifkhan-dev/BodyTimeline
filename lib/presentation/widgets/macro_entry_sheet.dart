import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cupertino_native/cupertino_native.dart';
import '../view_models/today_view_model.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/color_palette.dart';
import 'dart:math' as math;

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
    final vm = context.watch<TodayViewModel>();
    final today = vm.today;

    final calories = today?.macros?.calories ?? 0;
    final protein = today?.macros?.protein ?? 0;
    final carbs = today?.macros?.carbs ?? 0;
    final fat = today?.macros?.fat ?? 0;

    // Estimate goal (mock)
    const calGoal = 2000.0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [BoxShadow(color: colors.textPrimary.withAlpha(20), blurRadius: 40, offset: const Offset(0, -10))],
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + safeAreaBottom),
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
                        'TODAY',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colors.textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Macros',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colors.textPrimary),
                      ),
                    ],
                  ),
                  _buildCalendarIcon(colors),
                ],
              ),

              const SizedBox(height: 32),

              // Infographic Card
              _buildMacroInfographic(context, colors, calories, protein, carbs, fat, calGoal),

              const SizedBox(height: 32),

              Text(
                'Log Entry',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: _buildField('Calories', _caloriesController, 'kcal', colors)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField('Protein', _proteinController, 'g', colors)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildField('Carbs', _carbsController, 'g', colors)),
                  const SizedBox(width: 12),
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
                    child: CNButton(label: 'Save Logs', onPressed: _save),
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

  Widget _buildMacroInfographic(
    BuildContext context,
    AppColors colors,
    double cal,
    double p,
    double c,
    double f,
    double goal,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: colors.textPrimary.withAlpha(5), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          // Ring Chart
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(value: 1.0, strokeWidth: 14, color: colors.surface),
                ),
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: (cal / goal).clamp(0.0, 1.0),
                    strokeWidth: 14,
                    color: const Color(0xFF1B1B1E), // Dark aesthetic
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${cal.toInt()}',
                      style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: colors.textPrimary),
                    ),
                    Text(
                      'TOTAL CALORIES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Bottom Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroStat('PROTEIN', p, const Color(0xFF1B1B1E), colors),
              _buildMacroStat('CARBS', c, const Color(0xFFD0F288), colors),
              _buildMacroStat('FATS', f, const Color(0xFFE5E7EB), colors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroStat(String label, double value, Color accent, AppColors colors) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colors.textMuted),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${value.toInt()}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            Text('g', style: TextStyle(fontSize: 10, color: colors.textMuted)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2)),
        ),
      ],
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
    // No dismiss here so the user sees the graph update, or maybe dismiss.
    // Usually loggers dismiss after save.
    widget.onDismiss();
  }
}

class CircularProgressIndicator extends StatelessWidget {
  final double value;
  final double strokeWidth;
  final Color color;
  final StrokeCap strokeCap;

  const CircularProgressIndicator({
    super.key,
    required this.value,
    required this.strokeWidth,
    required this.color,
    this.strokeCap = StrokeCap.butt,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CircularProgressPainter(value: value, strokeWidth: strokeWidth, color: color, strokeCap: strokeCap),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double value;
  final double strokeWidth;
  final Color color;
  final StrokeCap strokeCap;

  _CircularProgressPainter({
    required this.value,
    required this.strokeWidth,
    required this.color,
    required this.strokeCap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = strokeCap;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, 2 * math.pi * value, false, paint);
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
