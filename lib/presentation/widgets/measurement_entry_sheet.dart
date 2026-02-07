import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cupertino_native/cupertino_native.dart';
import '../view_models/today_view_model.dart';
import '../view_models/onboarding_view_model.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/color_palette.dart';
import 'package:workout/l10n/generated/app_localizations.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/value_objects/measurement_type.dart';
import '../../core/utils/unit_converter.dart';
import 'suffix_toggle_text_field.dart';

class MeasurementEntrySheet extends StatefulWidget {
  final VoidCallback onDismiss;

  const MeasurementEntrySheet({super.key, required this.onDismiss});

  @override
  State<MeasurementEntrySheet> createState() => _MeasurementEntrySheetState();
}

class _MeasurementEntrySheetState extends State<MeasurementEntrySheet> {
  final Map<MeasurementType, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    final today = context.read<TodayViewModel>().today;
    final isMetric = context.read<OnboardingViewModel>().isMetric;

    for (final type in MeasurementType.values) {
      final existing = today?.measurements.firstWhere(
        (m) => m.type == type,
        orElse: () => Measurement(type: type, value: -1, unit: type == MeasurementType.weight ? 'kg' : 'cm'),
      );

      String initialText = '';
      if (existing != null && existing.value >= 0) {
        if (isMetric) {
          initialText = existing.value.toStringAsFixed(1);
        } else {
          if (type == MeasurementType.weight) {
            initialText = UnitConverter.kgToLbs(existing.value).toStringAsFixed(1);
          } else {
            initialText = UnitConverter.cmToInches(existing.value).toStringAsFixed(1);
          }
        }
      }

      _controllers[type] = TextEditingController(text: initialText);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);
    final onboardingVm = context.watch<OnboardingViewModel>();
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
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
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  AppLocalizations.of(context)!.bodyMeasurements,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.textPrimary),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: widget.onDismiss,
                  child: Icon(CupertinoIcons.xmark_circle_fill, color: colors.textSecondary.withAlpha(150), size: 28),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildField(
                    '⚖️ ${AppLocalizations.of(context)!.weight}',
                    MeasurementType.weight,
                    onboardingVm,
                    colors,
                  ),
                  const SizedBox(height: 16),
                  _buildField('📏 ${AppLocalizations.of(context)!.waist}', MeasurementType.waist, onboardingVm, colors),
                  const SizedBox(height: 16),
                  _buildField('👕 ${AppLocalizations.of(context)!.chest}', MeasurementType.chest, onboardingVm, colors),
                  const SizedBox(height: 16),
                  _buildField('👖 ${AppLocalizations.of(context)!.hips}', MeasurementType.hips, onboardingVm, colors),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          '💪 ${AppLocalizations.of(context)!.armL}',
                          MeasurementType.armLeft,
                          onboardingVm,
                          colors,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                          '💪 ${AppLocalizations.of(context)!.armR}',
                          MeasurementType.armRight,
                          onboardingVm,
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
                          '🦵 ${AppLocalizations.of(context)!.thighL}',
                          MeasurementType.thighLeft,
                          onboardingVm,
                          colors,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                          '🦵 ${AppLocalizations.of(context)!.thighR}',
                          MeasurementType.thighRight,
                          onboardingVm,
                          colors,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildField('🧣 ${AppLocalizations.of(context)!.neck}', MeasurementType.neck, onboardingVm, colors),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CNButton(label: AppLocalizations.of(context)!.cancel, onPressed: widget.onDismiss),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CNButton(label: AppLocalizations.of(context)!.saveAll, onPressed: () => _save(onboardingVm)),
                ),
              ],
            ),
            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, MeasurementType type, OnboardingViewModel vm, AppColors colors) {
    final suffix = type == MeasurementType.weight ? (vm.isMetric ? 'kg' : 'lbs') : (vm.isMetric ? 'cm' : 'in');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textSecondary),
        ),
        const SizedBox(height: 8),
        SuffixToggleTextField(
          controller: _controllers[type]!,
          placeholder: '0.0',
          suffix: suffix,
          colors: colors,
          onSuffixTap: () {
            // Convert all relevant controllers
            final isWeight = type == MeasurementType.weight;

            _controllers.forEach((t, controller) {
              final val = double.tryParse(controller.text);
              if (val != null) {
                if (isWeight && t == MeasurementType.weight) {
                  if (vm.isMetric) {
                    controller.text = UnitConverter.kgToLbs(val).toStringAsFixed(1);
                  } else {
                    controller.text = UnitConverter.lbsToKg(val).toStringAsFixed(1);
                  }
                } else if (!isWeight && t != MeasurementType.weight) {
                  if (vm.isMetric) {
                    controller.text = UnitConverter.cmToInches(val).toStringAsFixed(1);
                  } else {
                    controller.text = UnitConverter.inchesToCm(val).toStringAsFixed(1);
                  }
                }
              }
            });
            vm.toggleUnits();
          },
        ),
      ],
    );
  }

  void _save(OnboardingViewModel vm) async {
    final List<Measurement> measurements = [];
    _controllers.forEach((type, controller) {
      final value = double.tryParse(controller.text);
      if (value != null && value > 0) {
        double normalizedValue = value;
        if (!vm.isMetric) {
          if (type == MeasurementType.weight) {
            normalizedValue = UnitConverter.lbsToKg(value);
          } else {
            normalizedValue = UnitConverter.inchesToCm(value);
          }
        }
        measurements.add(
          Measurement(type: type, value: normalizedValue, unit: type == MeasurementType.weight ? 'kg' : 'cm'),
        );
      }
    });

    await context.read<TodayViewModel>().updateMeasurements(measurements);
    widget.onDismiss();
  }
}
