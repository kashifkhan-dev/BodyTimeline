import 'package:flutter/foundation.dart';
import '../../domain/entities/workout_day.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/value_objects/measurement_type.dart';

class StatsViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;

  // Data cache: Map<Date, WorkoutDay>
  // We keep only what's "near" the current viewing window
  final Map<DateTime, WorkoutDay?> _dataCache = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StatsViewModel(this._workoutRepository);

  void clearCache() {
    _dataCache.clear();
    notifyListeners();
  }

  /// Fetches a window of data.
  /// In a real app, this would call a paginated repository method.
  /// For now, it queries what we need and simulates chunked loading.
  Future<void> loadWindow(DateTime centerDate, {int windowDays = 14}) async {
    final startDate = centerDate.subtract(Duration(days: windowDays));

    bool needsFetch = false;
    for (int i = 0; i <= windowDays; i++) {
      final date = DateTime(
        startDate.add(Duration(days: i)).year,
        startDate.add(Duration(days: i)).month,
        startDate.add(Duration(days: i)).day,
      );
      if (!_dataCache.containsKey(date)) {
        needsFetch = true;
        break;
      }
    }

    if (!needsFetch) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Simulation: Fetching from repository
      // Since repository doesn't have getRange, we iterate for now
      // but the UI will see a "loaded" state.
      // In production, we'd add 'getRange(start, end)' to WorkoutRepository.
      for (int i = 0; i <= windowDays; i++) {
        final date = DateTime(
          startDate.add(Duration(days: i)).year,
          startDate.add(Duration(days: i)).month,
          startDate.add(Duration(days: i)).day,
        );
        if (!_dataCache.containsKey(date)) {
          final day = await _workoutRepository.getDay(date);
          _dataCache[date] = day;
        }
      }
    } catch (e) {
      debugPrint("Error loading stats data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  WorkoutDay? getTodayMeasurements() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _dataCache[today];
  }

  /// Returns data for a specific range suitable for the chart
  List<StatsPoint> getDataPoints(DateTime start, DateTime end, String metricType, {MeasurementType? measurementType}) {
    final points = <StatsPoint>[];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      final date = DateTime(
        start.add(Duration(days: i)).year,
        start.add(Duration(days: i)).month,
        start.add(Duration(days: i)).day,
      );
      final day = _dataCache[date];
      double value = 0;

      if (day != null) {
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
      }
      points.add(StatsPoint(date: date, value: value));
    }
    return points;
  }
}

class StatsPoint {
  final DateTime date;
  final double value;

  StatsPoint({required this.date, required this.value});
}
