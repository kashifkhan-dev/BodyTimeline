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
  int? _age;
  double? _heightCm;
  double? _weightKg;
  String? _frequency;
  bool _isMetric = true; // Default to metric

  OnboardingViewModel(this._prefs, this._workoutRepository) {
    _isMetric = _prefs.getBool('is_metric') ?? true;
  }

  OnboardingStep get currentStep => _currentStep;
  String? get goal => _goal;
  String? get gender => _gender;
  int? get age => _age;
  double? get heightCm => _heightCm;
  double? get weightKg => _weightKg;
  String? get frequency => _frequency;
  bool get isMetric => _isMetric;

  void nextStep() {
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
    notifyListeners();
  }

  void setHeight(double cm) {
    _heightCm = cm;
    notifyListeners();
  }

  void setWeight(double kg) {
    _weightKg = kg;
    notifyListeners();
  }

  void setFrequency(String frequency) {
    _frequency = frequency;
    notifyListeners();
  }

  void toggleUnits() {
    _isMetric = !_isMetric;
    _prefs.setBool('is_metric', _isMetric);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    // Save to SharedPreferences
    await _prefs.setBool('onboarding_completed', true);
    await _prefs.setString('user_goal', _goal ?? '');
    await _prefs.setString('user_gender', _gender ?? '');
    if (_age != null) await _prefs.setInt('user_age', _age!);
    if (_heightCm != null) await _prefs.setDouble('user_height_cm', _heightCm!);
    if (_weightKg != null) await _prefs.setDouble('user_weight_kg', _weightKg!);
    await _prefs.setString('workout_frequency', _frequency ?? '');

    // Save as first-day record (SQLite via WorkoutRepository)
    final now = DateTime.now();
    final List<Measurement> initialMeasurements = [];

    if (_weightKg != null) {
      initialMeasurements.add(Measurement(type: MeasurementType.weight, value: _weightKg!, unit: 'kg'));
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
