import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/value_objects/measurement_type.dart';

enum OnboardingStep { welcome, goal, gender, age, height, weight, frequency, finalizing }

class OnboardingViewModel extends ChangeNotifier {
  final SharedPreferences _prefs;
  final WorkoutRepository _workoutRepository;

  OnboardingStep _currentStep = OnboardingStep.welcome;
  String? _goal;
  String? _gender;
  int _age = 0;
  double _heightCm = 0;
  double _weightKg = 0;
  String? _frequency;

  bool _ageInteracted = false;
  bool _heightInteracted = false;
  bool _weightInteracted = false;

  OnboardingViewModel(this._prefs, this._workoutRepository);

  OnboardingStep get currentStep => _currentStep;
  String? get goal => _goal;
  String? get gender => _gender;
  int get age => _age;
  double get heightCm => _heightCm;
  double get weightKg => _weightKg;
  String? get frequency => _frequency;

  bool get ageInteracted => _ageInteracted;
  bool get heightInteracted => _heightInteracted;
  bool get weightInteracted => _weightInteracted;

  bool get canProceed {
    switch (_currentStep) {
      case OnboardingStep.welcome:
        return true;
      case OnboardingStep.goal:
        return _goal != null;
      case OnboardingStep.gender:
        return _gender != null;
      case OnboardingStep.age:
        return _age > 0 && _ageInteracted;
      case OnboardingStep.height:
        return _heightCm > 0 && _heightInteracted;
      case OnboardingStep.weight:
        return _weightKg > 0 && _weightInteracted;
      case OnboardingStep.frequency:
        return _frequency != null;
      case OnboardingStep.finalizing:
        return true;
    }
  }

  void nextStep() {
    if (!canProceed) return;
    final steps = OnboardingStep.values;
    final currentIndex = steps.indexOf(_currentStep);
    if (currentIndex < steps.length - 1) {
      _currentStep = steps[currentIndex + 1];
      notifyListeners();
    }
  }

  void previousStep() {
    final steps = OnboardingStep.values;
    final currentIndex = steps.indexOf(_currentStep);
    if (currentIndex > 0) {
      _currentStep = steps[currentIndex - 1];
      notifyListeners();
    }
  }

  void setGoal(String goal) {
    _goal = goal;
    notifyListeners();
  }

  void setGender(String gender) {
    _gender = gender;
    notifyListeners();
  }

  void setAge(int age) {
    _age = age;
    _ageInteracted = true;
    notifyListeners();
  }

  void setHeight(double cm) {
    _heightCm = cm;
    _heightInteracted = true;
    notifyListeners();
  }

  void setWeight(double kg) {
    _weightKg = kg;
    _weightInteracted = true;
    notifyListeners();
  }

  void setFrequency(String frequency) {
    _frequency = frequency;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    // Save to SharedPreferences
    await _prefs.setBool('onboarding_completed', true);
    await _prefs.setString('user_goal', _goal ?? '');
    await _prefs.setString('user_gender', _gender ?? '');
    if (_age > 0) await _prefs.setInt('user_age', _age);
    if (_heightCm > 0) await _prefs.setDouble('user_height_cm', _heightCm);
    if (_weightKg > 0) await _prefs.setDouble('user_weight_kg', _weightKg);

    await _prefs.setString('workout_frequency', _frequency ?? '');

    // Save as first-day record (SQLite via WorkoutRepository)
    final now = DateTime.now();
    final List<Measurement> initialMeasurements = [];

    if (_weightKg > 0) {
      initialMeasurements.add(Measurement(type: MeasurementType.weight, value: _weightKg, unit: 'kg'));
    }

    // Height isn't typically tracked daily in measurements, but let's see if we should store it
    // PRD says "Save that data correctly as the first-day record"
    // Usually weight is a measurement. Height might be a profile value.
    // However, I'll store whatever I can in the measurement list if it fits.

    if (initialMeasurements.isNotEmpty) {
      await _workoutRepository.saveMeasurements(now, initialMeasurements);
    }

    notifyListeners();
  }
}
