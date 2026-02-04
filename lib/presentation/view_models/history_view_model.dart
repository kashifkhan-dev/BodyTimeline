import 'package:flutter/foundation.dart';
import '../../domain/entities/workout_day.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/entities/macro_log.dart';

class HistoryViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;

  List<WorkoutDay> _history = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  // CACHED VALUES (Memoized)
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _activeDaysCount = 0;
  int _missedDaysCount = 0;
  double _totalCompletionAverage = 0.0;
  double _averageCalories = 0.0;
  MacroLog _averageMacros = const MacroLog(calories: 0, protein: 0, carbs: 0, fat: 0);
  int _measurementFrequency = 0;
  Map<DateTime, double> _completionCache = {};

  HistoryViewModel(this._workoutRepository) {
    refresh();
  }

  List<WorkoutDay> get history => _history;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;

  // GETTERS (Returning memoized values)
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  int get activeDaysCount => _activeDaysCount;
  int get missedDaysCount => _missedDaysCount;
  double get totalCompletionAverage => _totalCompletionAverage;
  double get averageCalories => _averageCalories;
  MacroLog get averageMacros => _averageMacros;
  int get measurementFrequency => _measurementFrequency;

  void setSelectedDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  WorkoutDay? get dayForSelectedDate {
    if (_history.isEmpty) return null;
    try {
      final key = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      return _history.firstWhere((d) {
        final dDate = DateTime(d.date.year, d.date.month, d.date.day);
        return dDate == key;
      });
    } catch (_) {
      return null;
    }
  }

  double getCompletionForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _completionCache[key] ?? 0.0;
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      _history = await _workoutRepository.getAllDays();
      // Ensure we have data before computing
      _computeStats();
    } catch (e) {
      debugPrint("Error loading history: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _computeStats() {
    if (_history.isEmpty) {
      _resetStats();
      return;
    }

    // 1. Completion Cache for Heatmap (O(N))
    final newCache = <DateTime, double>{};
    for (var day in _history) {
      final key = DateTime(day.date.year, day.date.month, day.date.day);
      newCache[key] = day.completionPercentage;
    }
    _completionCache = newCache;

    // 2. Sort history for streak calculations
    // History from repo is usually desc, we need both for different stats
    final sortedAsc = List<WorkoutDay>.from(_history)..sort((a, b) => a.date.compareTo(b.date));
    final sortedDesc = sortedAsc.reversed.toList();

    // 3. Current Streak
    _currentStreak = _calculateCurrentStreak(sortedDesc);

    // 4. Longest Streak
    _longestStreak = _calculateLongestStreak(sortedAsc);

    // 5. Basic Counts
    _activeDaysCount = _history.where((d) => d.completionPercentage > 0).length;

    final start = sortedAsc.first.date;
    final end = DateTime.now();
    final todayMidnight = DateTime(end.year, end.month, end.day);
    final startMidnight = DateTime(start.year, start.month, start.day);
    final totalDays = todayMidnight.difference(startMidnight).inDays + 1;
    _missedDaysCount = (totalDays - _activeDaysCount).clamp(0, 99999);

    // 6. Averages
    if (_history.isNotEmpty) {
      final totalComp = _history.fold<double>(0, (sum, day) => sum + day.completionPercentage);
      _totalCompletionAverage = totalComp / _history.length;
    }

    final calorieLogged = _history.where((d) => d.macros != null && d.macros!.calories > 0).toList();
    _averageCalories = calorieLogged.isEmpty
        ? 0
        : calorieLogged.fold<double>(0, (sum, d) => sum + d.macros!.calories) / calorieLogged.length;

    final macroLogged = _history.where((d) => d.macros != null).toList();
    if (macroLogged.isEmpty) {
      _averageMacros = const MacroLog(calories: 0, protein: 0, carbs: 0, fat: 0);
    } else {
      double p = 0, c = 0, f = 0, cal = 0;
      for (var d in macroLogged) {
        if (d.macros != null) {
          p += d.macros!.protein;
          c += d.macros!.carbs;
          f += d.macros!.fat;
          cal += d.macros!.calories;
        }
      }
      final len = macroLogged.length;
      _averageMacros = MacroLog(calories: cal / len, protein: p / len, carbs: c / len, fat: f / len);
    }

    _measurementFrequency = _history.where((d) => d.measurements.isNotEmpty).length;
  }

  void _resetStats() {
    _currentStreak = 0;
    _longestStreak = 0;
    _activeDaysCount = 0;
    _missedDaysCount = 0;
    _totalCompletionAverage = 0.0;
    _averageCalories = 0.0;
    _averageMacros = const MacroLog(calories: 0, protein: 0, carbs: 0, fat: 0);
    _measurementFrequency = 0;
    _completionCache = {};
  }

  int _calculateCurrentStreak(List<WorkoutDay> sortedDesc) {
    if (sortedDesc.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    int streak = 0;
    DateTime nextExpectedDate = today;

    // Is the latest day today or yesterday?
    final latestDate = DateTime(sortedDesc[0].date.year, sortedDesc[0].date.month, sortedDesc[0].date.day);
    if (latestDate.isBefore(yesterday)) return 0;

    for (final day in sortedDesc) {
      final dayDate = DateTime(day.date.year, day.date.month, day.date.day);

      if (dayDate == nextExpectedDate) {
        if (day.isCompleted) {
          streak++;
          nextExpectedDate = nextExpectedDate.subtract(const Duration(days: 1));
        } else {
          // If today isn't done, we look at yesterday
          if (nextExpectedDate == today) {
            nextExpectedDate = yesterday;
            continue;
          }
          break; // Broken streak
        }
      } else if (dayDate.isBefore(nextExpectedDate)) {
        break; // Gap in history
      }
    }
    return streak;
  }

  int _calculateLongestStreak(List<WorkoutDay> sortedAsc) {
    int maxStreak = 0;
    int current = 0;
    DateTime? prevDate;

    for (final day in sortedAsc) {
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
}
