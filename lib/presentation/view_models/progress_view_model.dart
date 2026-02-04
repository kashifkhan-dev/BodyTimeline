import 'package:flutter/foundation.dart';
import '../../domain/entities/workout_day.dart';
import '../../domain/repositories/workout_repository.dart';

import '../../domain/value_objects/zone_type.dart';
import '../../domain/entities/photo_record.dart';

class ProgressViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;

  List<WorkoutDay> _history = [];
  bool _isLoading = true;
  ZoneType _selectedZone = ZoneType.face;

  ProgressViewModel(this._workoutRepository) {
    refresh();
  }

  List<WorkoutDay> get history => _history;
  bool get isLoading => _isLoading;
  ZoneType get selectedZone => _selectedZone;

  void setSelectedZone(ZoneType zone) {
    if (_selectedZone != zone) {
      _selectedZone = zone;
      notifyListeners();
    }
  }

  int get currentStreak {
    if (_history.isEmpty) return 0;

    // Sort descending for streak calculation
    final sorted = List<WorkoutDay>.from(_history)..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var i = 0; i < sorted.length; i++) {
      final dayDate = DateTime(sorted[i].date.year, sorted[i].date.month, sorted[i].date.day);

      // If the first item is not today or yesterday, streak is 0 (or whatever it was)
      if (i == 0 && dayDate.isBefore(today.subtract(const Duration(days: 1)))) {
        break;
      }

      if (sorted[i].isCompleted) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int get totalCompletedDays {
    return _history.where((d) => d.isCompleted).length;
  }

  List<String> get photoPaths {
    // Collect all real photo records for the selected zone
    final List<PhotoRecord> realPhotos = [];
    for (var day in _history) {
      for (var photo in day.photos) {
        if (photo.zoneType == _selectedZone) {
          realPhotos.add(photo);
        }
      }
    }

    // Sort real photos by date
    realPhotos.sort((a, b) => a.capturedAt.compareTo(b.capturedAt));

    if (realPhotos.isNotEmpty) {
      return realPhotos.map((p) => p.filePath).toList();
    }

    // FALLBACK: Mock images (1.png to 19.png)
    return List.generate(19, (index) => 'assets/images/transformation/${index + 1}.png');
  }

  List<DateTime> get photoDates {
    final List<DateTime> dates = [];
    for (var day in _history) {
      for (var photo in day.photos) {
        if (photo.zoneType == _selectedZone) {
          dates.add(photo.capturedAt);
        }
      }
    }
    dates.sort();

    if (dates.isNotEmpty) return dates;

    // Fallback dates for mock images: starting from 19 days ago
    final now = DateTime.now();
    return List.generate(19, (index) => now.subtract(Duration(days: 18 - index)));
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    _history = await _workoutRepository.getAllDays();
    _isLoading = false;
    notifyListeners();
  }
}
