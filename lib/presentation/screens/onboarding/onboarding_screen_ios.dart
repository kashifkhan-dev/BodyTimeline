import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/onboarding_view_model.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/color_palette.dart';
import '../../../core/utils/unit_converter.dart';
import '../main_shell.dart';
import '../../view_models/locale_view_model.dart';
import '../../../domain/entities/app_language.dart';
import 'package:workout/l10n/generated/app_localizations.dart';

class OnboardingScreenIOS extends StatefulWidget {
  const OnboardingScreenIOS({super.key});

  @override
  State<OnboardingScreenIOS> createState() => _OnboardingScreenIOSState();
}

class _OnboardingScreenIOSState extends State<OnboardingScreenIOS> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  late AnimationController _rocketController;
  late Animation<Offset> _rocketMove;
  late Animation<double> _rocketScale;
  late Animation<double> _rocketOpacity;
  late Animation<double> _rocketRotate;
  bool _isLaunching = false;

  @override
  void initState() {
    super.initState();
    _rocketController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));

    _rocketMove = Tween<Offset>(begin: Offset.zero, end: const Offset(10, -3)).animate(
      CurvedAnimation(
        parent: _rocketController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInBack),
      ),
    );

    _rocketScale = Tween<double>(begin: 1.0, end: 3.5).animate(
      CurvedAnimation(
        parent: _rocketController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    _rocketOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _rocketController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _rocketRotate =
        Tween<double>(
          begin: 0.0,
          end: 0.18, // Significant tilt (~65 degrees) toward the right path
        ).animate(
          CurvedAnimation(
            parent: _rocketController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _rocketController.dispose();
    super.dispose();
  }

  void _next() {
    _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors(context);
    final onboardingVm = context.watch<OnboardingViewModel>();
    final l10n = AppLocalizations.of(context)!;

    debugPrint('🔄 OnboardingScreenIOS rebuilding with locale: ${l10n.localeName}');

    return CupertinoPageScaffold(
      backgroundColor: colors.background,
      child: Stack(
        children: [
          // Dynamic Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primary.withOpacity(0.05),
                    colors.background,
                    colors.background,
                    colors.primary.withOpacity(0.02),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildWelcomeStep(context, colors, l10n),
                _buildGoalStep(context, colors, onboardingVm, l10n),
                _buildGenderStep(context, colors, onboardingVm, l10n),
                _buildAgeStep(context, colors, onboardingVm, l10n),
                _buildHeightStep(context, colors, onboardingVm, l10n),
                _buildWeightStep(context, colors, onboardingVm, l10n),
                _buildFrequencyStep(context, colors, onboardingVm, l10n),
                _buildFinalStep(context, colors, onboardingVm, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContainer({
    required String title,
    required Widget child,
    String? buttonLabel,
    VoidCallback? onButtonPressed,
    bool showBackButton = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBackButton)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                _pageController.previousPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
              },
              child: const Icon(CupertinoIcons.arrow_left, size: 28),
            )
          else
            const SizedBox(height: 44),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, letterSpacing: -1)),
          const SizedBox(height: 40),
          Expanded(child: child),
          if (buttonLabel != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _ProminentButton(label: buttonLabel, onPressed: onButtonPressed),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep(BuildContext context, AppColors colors, AppLocalizations l10n) {
    final localeVm = context.watch<LocaleViewModel>();

    return _buildStepContainer(
      title: l10n.onboardingWelcomeTitle,
      showBackButton: false,
      buttonLabel: l10n.onboardingGetStarted,
      onButtonPressed: _next,
      child: Column(
        children: [
          Text(
            l10n.onboardingSubtitle,
            style: TextStyle(fontSize: 18, color: colors.textSecondary, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 24),
          // Character Comparison with Depth & 3D Presence
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildAnimatedCharacter("assets/images/onboard_before.png", "Before", colors)),
                const SizedBox(width: 8),
                Expanded(child: _buildAnimatedCharacter("assets/images/onboard_after.png", "After", colors)),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Minimalist Language Picker
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: AppLanguage.values.map((lang) {
              final isSelected = localeVm.currentLanguage == lang;
              return GestureDetector(
                onTap: () {
                  debugPrint('🌍 Language changed to: ${lang.code}');
                  localeVm.setLanguage(lang);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                      color: isSelected ? colors.primary : colors.textMuted,
                      letterSpacing: 0.5,
                    ),
                    child: Text(lang.code.toUpperCase()),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGoalStep(BuildContext context, AppColors colors, OnboardingViewModel vm, AppLocalizations l10n) {
    final goals = [
      {'val': l10n.loseFat, 'key': 'Lose fat'},
      {'val': l10n.buildMuscle, 'key': 'Build muscle'},
      {'val': l10n.bodyRecomposition, 'key': 'Body recomposition'},
      {'val': l10n.trackProgressOnly, 'key': 'Just track my progress'},
    ];
    return _buildStepContainer(
      title: l10n.onboardingGoalTitle,
      child: ListView.separated(
        itemCount: goals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final goal = goals[index];
          final isSelected = vm.goal == goal['key'];
          return _buildLiquidTile(
            label: goal['val']!,
            isSelected: isSelected,
            onTap: () {
              vm.setGoal(goal['key']!);
              Future.delayed(const Duration(milliseconds: 300), _next);
            },
            colors: colors,
          );
        },
      ),
    );
  }

  Widget _buildGenderStep(BuildContext context, AppColors colors, OnboardingViewModel vm, AppLocalizations l10n) {
    return _buildStepContainer(
      title: l10n.onboardingGenderTitle,
      child: Column(
        children: [
          _buildLiquidTile(
            label: l10n.male,
            isSelected: vm.gender == "Male",
            onTap: () {
              vm.setGender("Male");
              Future.delayed(const Duration(milliseconds: 300), _next);
            },
            colors: colors,
            icon: CupertinoIcons.person_fill,
          ),
          const SizedBox(height: 16),
          _buildLiquidTile(
            label: l10n.female,
            isSelected: vm.gender == "Female",
            onTap: () {
              vm.setGender("Female");
              Future.delayed(const Duration(milliseconds: 300), _next);
            },
            colors: colors,
            icon: CupertinoIcons.person_fill,
          ),
        ],
      ),
    );
  }

  Widget _buildAgeStep(BuildContext context, AppColors colors, OnboardingViewModel vm, AppLocalizations l10n) {
    return _buildStepContainer(
      title: l10n.onboardingAgeTitle,
      buttonLabel: l10n.continueButton,
      onButtonPressed: () {
        final age = int.tryParse(_ageController.text);
        if (age != null) {
          vm.setAge(age);
          _next();
        }
      },
      child: Center(
        child: _buildGlossyTextField(
          controller: _ageController,
          placeholder: l10n.onboardingAgePlaceholder,
          keyboardType: TextInputType.number,
          colors: colors,
        ),
      ),
    );
  }

  Widget _buildHeightStep(BuildContext context, AppColors colors, OnboardingViewModel vm, AppLocalizations l10n) {
    // Current display value
    if (_heightController.text.isEmpty && vm.heightCm != null) {
      if (vm.isMetric) {
        _heightController.text = (vm.heightCm! / 100).toStringAsFixed(2);
      } else {
        _heightController.text = UnitConverter.mToFt(vm.heightCm! / 100).toStringAsFixed(1);
      }
    }

    return _buildStepContainer(
      title: l10n.onboardingHeightTitle,
      buttonLabel: l10n.continueButton,
      onButtonPressed: () {
        final val = double.tryParse(_heightController.text);
        if (val != null) {
          final m = vm.isMetric ? val : UnitConverter.ftToM(val);
          vm.setHeight(m * 100);
          _next();
        }
      },
      child: Center(
        child: _buildGlossyTextField(
          controller: _heightController,
          placeholder: l10n.onboardingHeightPlaceholder,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          colors: colors,
          suffix: vm.isMetric ? "m" : "ft",
          onSuffixTap: () {
            final currentVal = double.tryParse(_heightController.text);
            if (currentVal != null) {
              if (vm.isMetric) {
                // To Imperial
                _heightController.text = UnitConverter.mToFt(currentVal).toStringAsFixed(1);
              } else {
                // To Metric
                _heightController.text = UnitConverter.ftToM(currentVal).toStringAsFixed(2);
              }
            }
            vm.toggleUnits();
          },
        ),
      ),
    );
  }

  Widget _buildWeightStep(BuildContext context, AppColors colors, OnboardingViewModel vm, AppLocalizations l10n) {
    if (_weightController.text.isEmpty && vm.weightKg != null) {
      if (vm.isMetric) {
        _weightController.text = vm.weightKg!.toStringAsFixed(1);
      } else {
        _weightController.text = UnitConverter.kgToLbs(vm.weightKg!).toStringAsFixed(1);
      }
    }

    return _buildStepContainer(
      title: l10n.onboardingWeightTitle,
      buttonLabel: l10n.continueButton,
      onButtonPressed: () {
        final val = double.tryParse(_weightController.text);
        if (val != null) {
          final kg = vm.isMetric ? val : UnitConverter.lbsToKg(val);
          vm.setWeight(kg);
          _next();
        }
      },
      child: Center(
        child: _buildGlossyTextField(
          controller: _weightController,
          placeholder: l10n.onboardingWeightPlaceholder,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          colors: colors,
          suffix: vm.isMetric ? "kg" : "lbs",
          onSuffixTap: () {
            final currentVal = double.tryParse(_weightController.text);
            if (currentVal != null) {
              if (vm.isMetric) {
                // To Imperial
                _weightController.text = UnitConverter.kgToLbs(currentVal).toStringAsFixed(1);
              } else {
                // To Metric
                _weightController.text = UnitConverter.lbsToKg(currentVal).toStringAsFixed(1);
              }
            }
            vm.toggleUnits();
          },
        ),
      ),
    );
  }

  Widget _buildFrequencyStep(BuildContext context, AppColors colors, OnboardingViewModel vm, AppLocalizations l10n) {
    final options = [
      {'val': l10n.dontTrain, 'key': 'I don’t train'},
      {'val': l10n.train1_2Times, 'key': '1–2 times per week'},
      {'val': l10n.train3_4Times, 'key': '3–4 times per week'},
      {'val': l10n.train5PlusTimes, 'key': '5+ times per week'},
    ];
    return _buildStepContainer(
      title: l10n.onboardingFrequencyTitle,
      child: ListView.separated(
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final freq = options[index];
          final isSelected = vm.frequency == freq['key'];
          return _buildLiquidTile(
            label: freq['val']!,
            isSelected: isSelected,
            onTap: () {
              vm.setFrequency(freq['key']!);
              Future.delayed(const Duration(milliseconds: 300), _next);
            },
            colors: colors,
          );
        },
      ),
    );
  }

  Widget _buildFinalStep(BuildContext context, AppColors colors, OnboardingViewModel vm, AppLocalizations l10n) {
    return _buildStepContainer(
      title: l10n.onboardingFinalTitle,
      buttonLabel: _isLaunching ? null : l10n.onboardingStartJourney,
      onButtonPressed: () async {
        setState(() => _isLaunching = true);
        await vm.completeOnboarding();
        await _rocketController.forward();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const MainShell(),
              transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 1000),
            ),
          );
        }
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _rocketController,
              builder: (context, child) {
                return SlideTransition(
                  position: _rocketMove,
                  child: ScaleTransition(
                    scale: _rocketScale,
                    child: RotationTransition(
                      turns: _rocketRotate,
                      child: FadeTransition(
                        opacity: _rocketOpacity,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_isLaunching) Positioned(bottom: 0, child: _buildEngineFlame(colors)),
                            const Text("🚀", style: TextStyle(fontSize: 100)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _isLaunching ? 0.0 : 1.0,
              child: Text(
                l10n.onboardingReady,
                style: TextStyle(fontSize: 20, color: colors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineFlame(AppColors colors) {
    return Container(
      width: 40,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.primary.withOpacity(0.8), Colors.orange.withOpacity(0.4), Colors.transparent],
        ),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
    );
  }

  Widget _buildAnimatedCharacter(String assetPath, String label, AppColors colors) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(
            // Scale from 0.8 to 1.03 for a "pop" effect
            scale: 0.8 + (value * 0.23),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Floating Ground Shadow
                Positioned(
                  bottom: 20,
                  child: Container(
                    width: 100,
                    height: 10,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: colors.textPrimary.withOpacity(0.12 * value), blurRadius: 12, spreadRadius: 2),
                      ],
                      borderRadius: const BorderRadius.all(Radius.elliptical(50, 5)),
                    ),
                  ),
                ),
                // The Character PNG
                Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('❌ Failed to load $assetPath: $error');
                    return Icon(CupertinoIcons.person_solid, size: 64, color: colors.textMuted);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiquidTile({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required AppColors colors,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withOpacity(0.1) : colors.card.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: isSelected ? colors.primary : colors.textMuted),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? colors.textPrimary : colors.textSecondary,
                ),
              ),
            ),
            if (isSelected) Icon(CupertinoIcons.checkmark_alt_circle_fill, color: colors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildGlossyTextField({
    required TextEditingController controller,
    required String placeholder,
    required AppColors colors,
    TextInputType? keyboardType,
    String? suffix,
    VoidCallback? onSuffixTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: colors.background.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border.withOpacity(0.3)),
          ),
          child: CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            keyboardType: keyboardType,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: null,
            suffix: suffix != null
                ? GestureDetector(
                    onTap: onSuffixTap,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: Text(
                        suffix,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.primary),
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _ProminentButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;

  const _ProminentButton({required this.label, this.onPressed});

  @override
  State<_ProminentButton> createState() => _ProminentButtonState();
}

class _ProminentButtonState extends State<_ProminentButton> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors(context);
    final bool isEnabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: (_) => isEnabled ? _pressController.forward() : null,
      onTapUp: (_) => isEnabled ? _pressController.reverse() : null,
      onTapCancel: () => isEnabled ? _pressController.reverse() : null,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [colors.primary, colors.primary.withAlpha(200)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: colors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
