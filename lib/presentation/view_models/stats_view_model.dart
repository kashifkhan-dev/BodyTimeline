import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/workout_day.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/value_objects/measurement_type.dart';

class StatsViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;
  StreamSubscription? _subscription;
  List<WorkoutDay> _history = [];
  bool _isLoading = false;

  StatsViewModel(this._workoutRepository) {
    _subscription = _workoutRepository.changes.listen((_) => refresh());
    refresh();
  }

  List<WorkoutDay> get history => _history;
  bool get isLoading => _isLoading;

  void clearCache() {
    _history.clear();
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_history.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _history = await _workoutRepository.getAllDays();
      // Repo returns Descending (Newest first). Sort Ascending for charts.
      _history.sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      debugPrint("Error loading stats: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Returns the latest recorded day (Shifted Today)
  WorkoutDay? getTodayMeasurements() {
    if (_history.isEmpty) return null;
    return _history.last; // Last because we sorted Ascending
  }

  /// Returns data for all saved days.
  /// The UI (ScrollableBarChart) handles windowing/scrolling.
  List<StatsPoint> getDataPoints(String metricType, {MeasurementType? measurementType}) {
    final points = <StatsPoint>[];
    for (var day in _history) {
      double value = 0;
      if (metricType == 'calories') {
        value = day.macros?.calories ?? 0;
      } else if (metricType == 'protein') {
        value = day.macros?.protein ?? 0;
      } else if (metricType == 'carbs') {
        value = day.macros?.carbs ?? 0;
      } else if (metricType == 'fats') {
        value = day.macros?.fat ?? 0;
      } else if (metricType == 'measurement' && measurementType != null) {
        try {
          value = day.measurements.firstWhere((m) => m.type == measurementType).value;
        } catch (_) {
          value = 0;
        }
      }
      points.add(StatsPoint(date: day.date, value: value));
    }
    return points;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// loadWindow is no longer needed since we load all real data at once (it's small enough for now)
// and the requirement says "Each bar = one saved day".
// If we had 1000s of days, we'd paginate getAllDays.

class StatsPoint {
  final DateTime date;
  final double value;

  StatsPoint({required this.date, required this.value});
}
