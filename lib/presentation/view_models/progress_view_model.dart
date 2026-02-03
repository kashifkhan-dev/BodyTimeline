import 'package:flutter/foundation.dart';
import '../../domain/entities/workout_day.dart';
import '../../domain/repositories/workout_repository.dart';

class ProgressViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;

  List<WorkoutDay> _history = [];
  bool _isLoading = true;

  ProgressViewModel(this._workoutRepository) {
    refresh();
  }

  List<WorkoutDay> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    _history = await _workoutRepository.getAllDays();
    // Sort by date ascending for progress tracking
    _history.sort((a, b) => a.date.compareTo(b.date));

    _isLoading = false;
    notifyListeners();
  }
}
