import 'package:flutter/foundation.dart';
import '../../domain/entities/workout_day.dart';
import '../../domain/repositories/workout_repository.dart';

class HistoryViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;

  List<WorkoutDay> _history = [];
  bool _isLoading = true;

  HistoryViewModel(this._workoutRepository) {
    refresh();
  }

  List<WorkoutDay> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    _history = await _workoutRepository.getAllDays();
    // Sort by date descending
    _history.sort((a, b) => b.date.compareTo(a.date));

    _isLoading = false;
    notifyListeners();
  }
}
