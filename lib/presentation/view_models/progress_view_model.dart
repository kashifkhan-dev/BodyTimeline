import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/workout_day.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/repositories/settings_repository.dart';

import '../../domain/value_objects/zone_type.dart';
import '../../domain/entities/photo_record.dart';
import '../../domain/entities/tracking_config.dart';

class ProgressViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;
  final SettingsRepository _settingsRepository;
  List<WorkoutDay> _history = [];
  bool _isLoading = true;
  ZoneType _selectedZone = ZoneType.face;
  TrackingConfig? _config;

  ProgressViewModel(this._workoutRepository, this._settingsRepository) {
    _subscriptions.add(_workoutRepository.changes.listen((_) => refresh()));
    _subscriptions.add(_settingsRepository.changes.listen((_) => refresh()));
    refresh();
  }

  List<WorkoutDay> get history => _history;
  bool get isLoading => _isLoading;
  ZoneType get selectedZone => _selectedZone;

  Set<ZoneType> get availableZones {
    if (_config == null) return {};

    // Filter to only Photo zones that are enabled
    final set = _config!.enabledZones.intersection({
      ZoneType.face,
      ZoneType.bodyFront,
      ZoneType.bodySide,
      ZoneType.bodyBack,
    });

    return set;
  }

  void setSelectedZone(ZoneType zone) {
    if (_selectedZone != zone) {
      _selectedZone = zone;
      notifyListeners();
    }
  }

  int get currentStreak {
    if (_history.isEmpty) return 0;

    // Sort descending (newest first)
    final sorted = List<WorkoutDay>.from(_history)..sort((a, b) => b.date.compareTo(a.date));

    // Based on PRD: "Streak: Based on consecutive shifted days. Breaks only if user stops saving."
    // Since we are time-shifting, the "Latest" day is our "Today".
    // We just count backwards from the newest record.

    int streak = 1; // Start with 1 for the latest day
    DateTime currentDate = sorted[0].date;

    // Check backwards
    for (int i = 1; i < sorted.length; i++) {
      final prevDate = sorted[i].date;

      // Calculate difference in days.
      // Since days are generated at same time, compare YMD.
      final diff = currentDate.difference(prevDate).inDays;

      if (diff == 1) {
        streak++;
        currentDate = prevDate;
      } else {
        break;
      }
    }
    return streak;
  }

  int get totalCompletedDays {
    // "Completed Days: Count = number of saved shifted days"
    return _history.length;
  }

  /// Returns photos for the currently selected zone, sorted by date (oldest first).
  List<PhotoRecord> get latestPhotos {
    final List<PhotoRecord> zonePhotos = [];
    for (var day in _history) {
      for (var photo in day.photos) {
        if (photo.zoneType == _selectedZone) {
          zonePhotos.add(photo);
        }
      }
    }

    // Sort by date ascending (Old -> New)
    zonePhotos.sort((a, b) => a.capturedAt.compareTo(b.capturedAt));

    return zonePhotos;
  }

  Future<void> refresh() async {
    // We don't want to show loading spinner for background updates
    if (_history.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _config = await _settingsRepository.getConfig();

      // Ensure selected zone is still valid, else switch to first available
      if (!availableZones.contains(_selectedZone)) {
        if (availableZones.isNotEmpty) {
          _selectedZone = availableZones.first;
        }
      }

      _history = await _workoutRepository.getAllDays();
    } catch (e) {
      debugPrint("Error loading progress: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  final List<StreamSubscription> _subscriptions = [];

  @override
  void dispose() {
    for (var s in _subscriptions) {
      s.cancel();
    }
    super.dispose();
  }
}
