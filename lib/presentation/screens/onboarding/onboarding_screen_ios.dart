import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:cupertino_native_better/cupertino_native_better.dart';
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
import '../../../core/providers/units_provider.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../../core/services/review_service.dart';

class OnboardingScreenIOS extends StatefulWidget {
  const OnboardingScreenIOS({super.key});

  @override
  State<OnboardingScreenIOS> createState() => _OnboardingScreenIOSState();
}

class _OnboardingScreenIOSState extends State<OnboardingScreenIOS> with TickerProviderStateMixin {
  final PageController _pageController = PageController();

  late AnimationController _transitionController;
  late Animation<double> _day1Opacity;
  late Animation<Offset> _day1Move;
  late Animation<double> _day30Opacity;
  late Animation<Offset> _day30Move;
  bool _transitionCompleted = false;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _day1Opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );
    _day1Move = Tween<Offset>(begin: Offset.zero, end: const Offset(-0.2, 0.0)).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _day30Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );
    _day30Move = Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  void _startTransition() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _transitionController.forward().then((_) {
        if (mounted) setState(() => _transitionCompleted = true);
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  void _next() {
    context.read<OnboardingViewModel>().nextStep();
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
          // Dynamic Background (Subtle Gradient)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primary.withValues(alpha: 0.05),
                    Colors.transparent,
                    colors.primary.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, colors, onboardingVm),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Disable swiping, enforce navigation rules
                    onPageChanged: (index) {
                      if (index == OnboardingStep.values.length - 1) {
                        _startTransition();
                      }
                    },
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
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AppColors colors, OnboardingViewModel vm) {
    final steps = OnboardingStep.values;
    final currentIndex = steps.indexOf(vm.currentStep);
    final totalSteps = steps.length;
    final localeVm = context.watch<LocaleViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LEFT: prominent back button
          SizedBox(
            width: 48,
            height: 48,
            child: (currentIndex > 0 && vm.currentStep != OnboardingStep.finalizing)
                ? CNButton.icon(
                    icon: const CNSymbol('chevron.left', size: 24),
                    onPressed: () {
                      vm.previousStep();
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutCubic,
                      );
                    },
                  )
                : null,
          ),

          // CENTER: progress bar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: (currentIndex + 1) / totalSteps,
                  backgroundColor: colors.surface,
                  valueColor: AlwaysStoppedAnimation(colors.primary),
                  minHeight: 4,
                ),
              ),
            ),
          ),

          // RIGHT: language flag
          SizedBox(width: 48, height: 48, child: _buildLanguageFlag(context, localeVm, colors)),
        ],
      ),
    );
  }

  Widget _buildLanguageFlag(BuildContext context, LocaleViewModel localeVm, AppColors colors) {
    String flag = '🇺🇸';
    if (localeVm.currentLanguage == AppLanguage.french) flag = '🇫🇷';
    if (localeVm.currentLanguage == AppLanguage.spanish) flag = '🇪🇸';

    return CNPopupMenuButton(
      buttonLabel: flag,
      buttonStyle: CNButtonStyle.plain,
      items: AppLanguage.values.map((lang) {
        String f = '🇺🇸';
        if (lang == AppLanguage.french) f = '🇫🇷';
        if (lang == AppLanguage.spanish) f = '🇪🇸';
        return CNPopupMenuItem(label: "$f ${lang.code.toUpperCase()}");
      }).toList(),
      onSelected: (index) {
        final lang = AppLanguage.values[index];
        localeVm.setLanguage(lang);
      },
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
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, letterSpacing: -1)),
          const SizedBox(height: 40),
          Expanded(child: child),
          if (buttonLabel != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: double.infinity,
                height: 64, // Bigger button
                child: CNButton(
                  label: buttonLabel,
                  onPressed: onButtonPressed,
                  config: const CNButtonConfig(style: CNButtonStyle.prominentGlass),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep(BuildContext context, AppColors colors, AppLocalizations l10n) {
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
          const SizedBox(height: 48),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.border.withValues(alpha: 0.2), width: 1),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Center(
                            child: Transform.scale(
                              scale: 0.9,
                              child: Image.asset("assets/images/day1.png", fit: BoxFit.contain),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Day 1",
                        style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.border.withValues(alpha: 0.2), width: 1),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Center(child: Image.asset("assets/images/day30.png", fit: BoxFit.contain)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Day 30",
                        style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
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
      onButtonPressed: vm.canProceed ? _next : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            vm.age == 0 ? "--" : vm.age.toString(),
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          CNSlider(
            value: vm.ageInteracted ? vm.age.toDouble() : 25.0,
            min: 13,
            max: 100,
            onChanged: (val) {
              if (!vm.ageInteracted) {
                vm.setAge(25);
              } else {
                vm.setAge(val.round());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeightStep(BuildContext context, AppColors colors, OnboardingViewModel vm, AppLocalizations l10n) {
    final units = context.watch<UnitsProvider>();
    final isMetric = units.isMetric;

    return _buildStepContainer(
      title: l10n.onboardingHeightTitle,
      buttonLabel: l10n.continueButton,
      onButtonPressed: vm.canProceed ? _next : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => units.toggleUnitSystem(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  vm.heightCm == 0
                      ? "--"
                      : (isMetric ? vm.heightCm.toInt().toString() : UnitConverter.formatCmAsFeetInches(vm.heightCm)),
                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                if (isMetric || vm.heightCm == 0)
                  Text(
                    units.heightUnit,
                    style: TextStyle(fontSize: 24, color: colors.primary, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          CNSlider(
            value: vm.heightInteracted ? vm.heightCm : 160.0,
            min: 100,
            max: 220,
            onChanged: (val) {
              if (!vm.heightInteracted) {
                vm.setHeight(160);
              } else {
                vm.setHeight(val);
              }
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: CNSegmentedControl(
              labels: const ['Metric', 'Imperial'],
              selectedIndex: isMetric ? 0 : 1,
              onValueChanged: (index) => units.setUnitSystem(index == 0 ? UnitSystem.metric : UnitSystem.imperial),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightStep(BuildContext context, AppColors colors, OnboardingViewModel vm, AppLocalizations l10n) {
    final units = context.watch<UnitsProvider>();
    final isMetric = units.isMetric;

    return _buildStepContainer(
      title: l10n.onboardingWeightTitle,
      buttonLabel: l10n.continueButton,
      onButtonPressed: vm.canProceed ? _next : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => units.toggleUnitSystem(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  vm.weightKg == 0
                      ? "--"
                      : (isMetric
                            ? vm.weightKg.toStringAsFixed(1)
                            : UnitConverter.kgToLbs(vm.weightKg).toStringAsFixed(1)),
                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  units.weightUnit,
                  style: TextStyle(fontSize: 24, color: colors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          CNSlider(
            value: vm.weightInteracted ? vm.weightKg : 115.0,
            min: 30,
            max: 200,
            onChanged: (val) {
              if (!vm.weightInteracted) {
                vm.setWeight(115);
              } else {
                vm.setWeight(val);
              }
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: CNSegmentedControl(
              labels: const ['Metric', 'Imperial'],
              selectedIndex: isMetric ? 0 : 1,
              onValueChanged: (index) => units.setUnitSystem(index == 0 ? UnitSystem.metric : UnitSystem.imperial),
            ),
          ),
        ],
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
      buttonLabel: l10n.continueButton,
      onButtonPressed: vm.canProceed ? _next : null,
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
      title: "Lets Start",
      buttonLabel: "Start tracking",
      onButtonPressed: () async {
        await vm.completeOnboarding();
        // Trigger native app review prompt
        /*
        final InAppReview inAppReview = InAppReview.instance;
        if (await inAppReview.isAvailable()) {
          inAppReview.requestReview();
        }
        */

        // Use the actual ReviewService for a one-time request
        if (mounted) {
          await context.read<ReviewService>().requestReviewIfAppropriate();
        }

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
      child: Column(
        children: [
          Text(
            "Day 1 starts today. In 30 days, this photo will look different.",
            style: TextStyle(fontSize: 18, color: colors.textSecondary, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 48),
          Expanded(
            child: AnimatedBuilder(
              animation: _transitionController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Day 1: Fades out and translates slightly left
                    SlideTransition(
                      position: _day1Move,
                      child: FadeTransition(
                        opacity: _day1Opacity,
                        child: Image.asset("assets/images/day1.png", fit: BoxFit.contain),
                      ),
                    ),
                    // Day 30: Slides in from right and fades in
                    SlideTransition(
                      position: _day30Move,
                      child: FadeTransition(
                        opacity: _day30Opacity,
                        child: Image.asset("assets/images/day30.png", fit: BoxFit.contain),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
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
          color: isSelected ? colors.primary.withValues(alpha: 0.1) : colors.card.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? colors.primary : colors.border.withValues(alpha: 0.5), width: 1.5),
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
}
