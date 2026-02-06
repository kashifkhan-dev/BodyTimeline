import '../../domain/entities/workout_day.dart';
import '../../domain/entities/photo_record.dart';
import '../../domain/entities/measurement.dart';
import '../../domain/entities/macro_log.dart';
import '../../domain/value_objects/zone_type.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/in_memory_store.dart';
import '../mock/mock_day_generator.dart';

class InMemoryWorkoutRepository implements WorkoutRepository {
  final InMemoryStore _store;

  InMemoryWorkoutRepository(this._store) {
    // ALWAYS re-populate in development to ensure any changes in the
    // MockDayGenerator (like the new variable completion factor)
    // are applied immediately to the heatmap.
    _prePopulate();
  }

  void _prePopulate() {
    // Clear existing to avoid weird merges if any exist
    _store.days.clear();

    final history = MockDayGenerator.generateHistory(daysToGenerate: 90, config: _store.currentConfig);
    for (final day in history) {
      _store.days[_store.dateToKey(day.date)] = day;
    }
  }

  @override
  Future<WorkoutDay?> getDay(DateTime date) async {
    final key = _store.dateToKey(date);
    if (!_store.days.containsKey(key)) {
      // Auto-create for Today if requested, or just return a fresh one
      final isFuture = date.isAfter(DateTime.now().add(const Duration(minutes: 1)));
      if (!isFuture) {
        _store.days[key] = WorkoutDay(date: date, activeZones: _store.currentConfig.enabledZones.toList());
      }
    }
    return _store.days[key];
  }

  @override
  Future<List<WorkoutDay>> getAllDays() async {
    final sortedDays = _store.days.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    return sortedDays;
  }

  @override
  Future<void> savePhoto(DateTime date, PhotoRecord photo) async {
    final day = await getDay(date);
    if (day != null) {
      final updatedPhotos = List<PhotoRecord>.from(day.photos)
        ..removeWhere((p) => p.zoneType == photo.zoneType) // Replace existing for same zone
        ..add(photo);

      _store.days[_store.dateToKey(date)] = WorkoutDay(
        date: day.date,
        photos: updatedPhotos,
        measurements: day.measurements,
        macros: day.macros,
        activeZones: day.activeZones,
      );
    }
  }

  @override
  Future<void> saveMeasurements(DateTime date, List<Measurement> measurements) async {
    final day = await getDay(date);
    if (day != null) {
      _store.days[_store.dateToKey(date)] = WorkoutDay(
        date: day.date,
        photos: day.photos,
        measurements: measurements,
        macros: day.macros,
        activeZones: day.activeZones,
      );
    }
  }

  @override
  Future<void> saveMacros(DateTime date, MacroLog macros) async {
    final day = await getDay(date);
    if (day != null) {
      _store.days[_store.dateToKey(date)] = WorkoutDay(
        date: day.date,
        photos: day.photos,
        measurements: day.measurements,
        macros: macros,
        activeZones: day.activeZones,
      );
    }
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
  }
}

extension IterableExtension<T> on Iterable<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
