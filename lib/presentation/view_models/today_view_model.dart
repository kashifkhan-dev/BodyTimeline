import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/workout_day.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/entities/macro_log.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/entities/photo_record.dart';
import '../../domain/value_objects/zone_type.dart';

class TodayViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;
  final SettingsRepository _settingsRepository;
  WorkoutDay? _today;
  bool _isLoading = true;

  // Data captured in the current viewing session.
  final Map<ZoneType, PhotoRecord> _sessionPhotos = {};
  MacroLog? _sessionMacros;
  List<Measurement>? _sessionMeasurements;

  TodayViewModel(this._workoutRepository, this._settingsRepository) {
    _subscriptions.add(_workoutRepository.changes.listen((_) => refresh()));
    _subscriptions.add(_settingsRepository.changes.listen((_) => refresh()));
    refresh();
  }

  WorkoutDay? get today => _today;
  bool get isLoading => _isLoading;

  void onScreenVisible() {
    _sessionPhotos.clear();
    _sessionMacros = null;
    _sessionMeasurements = null;
    refresh();
  }

  bool isZoneCompleted(ZoneType zone) {
    if (zone == ZoneType.macronutrients) return _sessionMacros != null;
    if (zone == ZoneType.measurements) return _sessionMeasurements != null;
    return _sessionPhotos.containsKey(zone);
  }

  PhotoRecord? getSessionPhoto(ZoneType zone) => _sessionPhotos[zone];

  double get completionPercentage {
    if (_today == null) return 0.0;
    final active = _today!.activeZones;
    if (active.isEmpty) return 0.0;

    int completed = 0;
    for (var zone in active) {
      if (isZoneCompleted(zone)) completed++;
    }
    return completed / active.length;
  }

  Future<void> refresh() async {
    // We don't set _isLoading = true on reactive refreshes to avoid flickers
    // but we do on the first load.
    if (_today == null) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final config = await _settingsRepository.getConfig();
      final allDays = await _workoutRepository.getAllDays();

      // The PRD says each parameter has its own timeline.
      // However, the Today screen wants to show "What is next".
      // We'll construct a "virtual" today that shows what's done IN SESSION
      // and what's pending.

      _today = WorkoutDay(
        date: allDays.isNotEmpty
            ? allDays.first.date.add(const Duration(days: 1))
            : DateTime.now().subtract(const Duration(days: 30)),
        photos: [], // We don't show history photos in the Today "Pending" tiles
        activeZones: config.enabledZones.toList(),
      );
    } catch (e) {
      debugPrint("Error loading today: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSessionPhoto(ZoneType zone, PhotoRecord photo) async {
    _sessionPhotos[zone] = photo;
    notifyListeners();
  }

  Future<void> updateMacros(double calories, double protein, double carbs, double fat) async {
    final macros = MacroLog(calories: calories, protein: protein, carbs: carbs, fat: fat);
    await _workoutRepository.saveMacros(DateTime.now(), macros);
    _sessionMacros = macros;
    notifyListeners();
  }

  Future<void> updateMeasurements(List<Measurement> measurements) async {
    await _workoutRepository.saveMeasurements(DateTime.now(), measurements);
    _sessionMeasurements = measurements;
    notifyListeners();
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
