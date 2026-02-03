import 'package:flutter/foundation.dart';
import '../../domain/entities/workout_day.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/repositories/settings_repository.dart';

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
}
