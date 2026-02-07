import 'dart:async';
import '../../domain/entities/workout_day.dart';
import '../../domain/entities/photo_record.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/entities/macro_log.dart';
import '../../domain/value_objects/zone_type.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/in_memory_store.dart';
import '../datasources/sqlite_persistence_service.dart';

class InMemoryWorkoutRepository implements WorkoutRepository {
  final InMemoryStore _store;
  final SqlitePersistenceService _persistence;
  final StreamController<void> _changesController = StreamController<void>.broadcast();

  InMemoryWorkoutRepository(this._store, this._persistence);

  Future<void> init() async {
    final allDays = await _persistence.loadAllDays();
    for (var day in allDays) {
      final key = _store.dateToKey(day.date);
      _store.days[key] = day;
    }
  }

  @override
  Stream<void> get changes => _changesController.stream;

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
    final day = await _getOrCreateDay(date);

    // Rule: One image per parameter per day
    final List<PhotoRecord> updatedPhotos = List<PhotoRecord>.from(day.photos);
    updatedPhotos.removeWhere((p) => p.zoneType == photo.zoneType);
    updatedPhotos.add(photo);

    _store.days[_store.dateToKey(date)] = WorkoutDay(
      date: date,
      photos: updatedPhotos,
      measurements: day.measurements,
      macros: day.macros,
      activeZones: day.activeZones,
    );

    // Persist to SQLite immediately
    await _persistence.savePhoto(date, photo);
    _changesController.add(null);
  }

  @override
  Future<void> saveMeasurements(DateTime date, List<Measurement> measurements) async {
    final day = await _getOrCreateDay(date);

    _store.days[_store.dateToKey(date)] = WorkoutDay(
      date: date,
      photos: day.photos,
      measurements: measurements,
      macros: day.macros,
      activeZones: day.activeZones,
    );

    // Persist to SQLite immediately
    await _persistence.saveMeasurements(date, measurements);
    _changesController.add(null);
  }

  @override
  Future<void> saveMacros(DateTime date, MacroLog macros) async {
    final day = await _getOrCreateDay(date);

    _store.days[_store.dateToKey(date)] = WorkoutDay(
      date: date,
      photos: day.photos,
      measurements: day.measurements,
      macros: macros,
      activeZones: day.activeZones,
    );

    // Persist to SQLite immediately
    await _persistence.saveMacros(date, macros);
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
    await _persistence.clearAll();
    _changesController.add(null);
  }
}

extension IterableExtension<T> on Iterable<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
