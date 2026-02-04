import 'package:flutter/foundation.dart';
import '../../domain/entities/workout_day.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/entities/macro_log.dart';

class HistoryViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;

  List<WorkoutDay> _history = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  HistoryViewModel(this._workoutRepository) {
    refresh();
  }

  List<WorkoutDay> get history => _history;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  WorkoutDay? get dayForSelectedDate {
    try {
      return _history.firstWhere((d) => DateTime(d.date.year, d.date.month, d.date.day) == _selectedDate);
    } catch (_) {
      return null;
    }
  }

  int get currentStreak {
    if (_history.isEmpty) return 0;

    final sorted = List<WorkoutDay>.from(_history)..sort((a, b) => b.date.compareTo(a.date));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int streak = 0;
    DateTime nextExpectedDate = today;

    // Check if the most recent day is today or yesterday
    final latestDate = DateTime(sorted[0].date.year, sorted[0].date.month, sorted[0].date.day);
    if (latestDate.isBefore(today.subtract(const Duration(days: 1)))) {
      return 0;
    }

    for (final day in sorted) {
      final dayDate = DateTime(day.date.year, day.date.month, day.date.day);
      if (dayDate == nextExpectedDate) {
        if (day.isCompleted) {
          streak++;
          nextExpectedDate = nextExpectedDate.subtract(const Duration(days: 1));
        } else {
          // If today is not completed, we might still have a streak ending yesterday
          if (nextExpectedDate == today) {
            nextExpectedDate = today.subtract(const Duration(days: 1));
            continue;
          }
          break;
        }
      } else if (dayDate.isBefore(nextExpectedDate)) {
        break;
      }
    }
    return streak;
  }

  int get longestStreak {
    if (_history.isEmpty) return 0;

    final sorted = List<WorkoutDay>.from(_history)..sort((a, b) => a.date.compareTo(b.date));

    int maxStreak = 0;
    int current = 0;
    DateTime? prevDate;

    for (final day in sorted) {
      if (!day.isCompleted) {
        current = 0;
        prevDate = null;
        continue;
      }

      final dayDate = DateTime(day.date.year, day.date.month, day.date.day);
      if (prevDate == null || dayDate == prevDate.add(const Duration(days: 1))) {
        current++;
      } else {
        current = 1;
      }

      if (current > maxStreak) maxStreak = current;
      prevDate = dayDate;
    }
    return maxStreak;
  }

  int get activeDaysCount => _history.where((d) => d.completionPercentage > 0).length;

  int get missedDaysCount {
    if (_history.isEmpty) return 0;
    final sorted = List<WorkoutDay>.from(_history)..sort((a, b) => a.date.compareTo(b.date));
    final start = sorted.first.date;
    final end = DateTime.now();
    final totalDays = end.difference(start).inDays + 1;
    return totalDays - activeDaysCount;
  }

  double get totalCompletionAverage {
    if (_history.isEmpty) return 0.0;
    final total = _history.fold<double>(0, (sum, day) => sum + day.completionPercentage);
    return total / _history.length;
  }

  // MACRO STATS
  double get averageCalories {
    final logged = _history.where((d) => d.macros != null && d.macros!.calories > 0).toList();
    if (logged.isEmpty) return 0;
    return logged.fold<double>(0, (sum, d) => sum + d.macros!.calories) / logged.length;
  }

  MacroLog get averageMacros {
    final logged = _history.where((d) => d.macros != null).toList();
    if (logged.isEmpty) return const MacroLog(calories: 0, protein: 0, carbs: 0, fat: 0);

    double p = 0, c = 0, f = 0, cal = 0;
    for (var d in logged) {
      p += d.macros!.protein;
      c += d.macros!.carbs;
      f += d.macros!.fat;
      cal += d.macros!.calories;
    }
    final len = logged.length;
    return MacroLog(calories: cal / len, protein: p / len, carbs: c / len, fat: f / len);
  }

  // MEASUREMENT STATS
  int get measurementFrequency {
    return _history.where((d) => d.measurements.isNotEmpty).length;
  }

  double getCompletionForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    try {
      final day = _history.firstWhere((d) => DateTime(d.date.year, d.date.month, d.date.day) == key);
      return day.completionPercentage;
    } catch (_) {
      return 0.0;
    }
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    _history = await _workoutRepository.getAllDays();

    _isLoading = false;
    notifyListeners();
  }
}
