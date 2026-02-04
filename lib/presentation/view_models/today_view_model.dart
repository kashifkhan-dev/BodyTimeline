import 'package:flutter/foundation.dart';
import '../../domain/entities/workout_day.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/entities/macro_log.dart';
import '../../domain/entities/measurement.dart';

class TodayViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;

  WorkoutDay? _today;
  bool _isLoading = true;

  TodayViewModel(this._workoutRepository, SettingsRepository settingsRepository) {
    refresh();
  }

  WorkoutDay? get today => _today;
  bool get isLoading => _isLoading;

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    // In a real app, we'd ensure the day matches 'today' strictly here
    _today = await _workoutRepository.getDay(DateTime.now());

    _isLoading = false;
    notifyListeners();
  }

  // We could add methods here to save photos, measurements etc.
  // TodayPage will call these.
  Future<void> updateMacros(double calories, double protein, double carbs, double fat) async {
    final macros = MacroLog(calories: calories, protein: protein, carbs: carbs, fat: fat);
    await _workoutRepository.saveMacros(DateTime.now(), macros);
    await refresh();
  }

  Future<void> updateMeasurements(List<Measurement> measurements) async {
    await _workoutRepository.saveMeasurements(DateTime.now(), measurements);
    await refresh();
  }
}
