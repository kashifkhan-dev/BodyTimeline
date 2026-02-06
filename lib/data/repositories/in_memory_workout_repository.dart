import 'dart:async';
import '../../domain/entities/workout_day.dart';
import '../../domain/entities/photo_record.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/entities/macro_log.dart';
import '../../domain/value_objects/zone_type.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/in_memory_store.dart';

class InMemoryWorkoutRepository implements WorkoutRepository {
  final InMemoryStore _store;
  final DateTime _baseDate;
  final StreamController<void> _changesController = StreamController<void>.broadcast();

  // Tracks number of saves per parameter to support independent timelines
  final Map<ZoneType, int> _parameterCounts = {};

  InMemoryWorkoutRepository(this._store) : _baseDate = DateTime.now().subtract(const Duration(days: 30));

  @override
  Stream<void> get changes => _changesController.stream;

  DateTime _getTargetDateForParameter(ZoneType type) {
    final count = _parameterCounts[type] ?? 0;
    return _baseDate.add(Duration(days: count));
  }

  void _incrementCount(ZoneType type) {
    _parameterCounts[type] = (_parameterCounts[type] ?? 0) + 1;
  }

  Future<WorkoutDay> _getOrCreateDay(DateTime date) async {
    final key = _store.dateToKey(date);
    if (!_store.days.containsKey(key)) {
      _store.days[key] = WorkoutDay(date: date, activeZones: _store.currentConfig.enabledZones.toList());
    }
    return _store.days[key]!;
  }

  @override
  Future<WorkoutDay?> getDay(DateTime date) async {
    final key = _store.dateToKey(date);
    return _store.days[key];
  }

  @override
  Future<List<WorkoutDay>> getAllDays() async {
    final sortedDays = _store.days.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    return sortedDays;
  }

  @override
  Future<void> savePhoto(DateTime date, PhotoRecord photo) async {
    final targetDate = _getTargetDateForParameter(photo.zoneType);
    final day = await _getOrCreateDay(targetDate);

    // Merge photo into the day
    final updatedPhotos = List<PhotoRecord>.from(day.photos)..add(photo);
    _store.days[_store.dateToKey(targetDate)] = WorkoutDay(
      date: targetDate,
      photos: updatedPhotos,
      measurements: day.measurements,
      macros: day.macros,
      activeZones: day.activeZones,
    );

    _incrementCount(photo.zoneType);
    _changesController.add(null);
  }

  @override
  Future<void> saveMeasurements(DateTime date, List<Measurement> measurements) async {
    final type = ZoneType.measurements;
    final targetDate = _getTargetDateForParameter(type);
    final day = await _getOrCreateDay(targetDate);

    _store.days[_store.dateToKey(targetDate)] = WorkoutDay(
      date: targetDate,
      photos: day.photos,
      measurements: measurements,
      macros: day.macros,
      activeZones: day.activeZones,
    );

    _incrementCount(type);
    _changesController.add(null);
  }

  @override
  Future<void> saveMacros(DateTime date, MacroLog macros) async {
    final type = ZoneType.macronutrients;
    final targetDate = _getTargetDateForParameter(type);
    final day = await _getOrCreateDay(targetDate);

    _store.days[_store.dateToKey(targetDate)] = WorkoutDay(
      date: targetDate,
      photos: day.photos,
      measurements: day.measurements,
      macros: macros,
      activeZones: day.activeZones,
    );

    _incrementCount(type);
    _changesController.add(null);
  }

  @override
  Future<PhotoRecord?> getLatestPhoto(DateTime before, ZoneType zoneType) async {
    // Sort keys descending to walk backwards
    final sortedDates = _store.days.keys.toList()..sort((a, b) => b.compareTo(a));
    final beforeKey = _store.dateToKey(before);

    for (final key in sortedDates) {
      if (key.compareTo(beforeKey) <= 0) {
        final day = _store.days[key]!;
        final photo = day.photos.where((p) => p.zoneType == zoneType).lastOrNull;
        if (photo != null) return photo;
      }
    }
    return null;
  }

  @override
  Future<void> deleteAllData() async {
    _store.clearAll();
    _parameterCounts.clear();
    _changesController.add(null);
  }
}

extension IterableExtension<T> on Iterable<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
