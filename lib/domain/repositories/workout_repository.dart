import '../value_objects/zone_type.dart';
import '../entities/workout_day.dart';
import '../entities/photo_record.dart';
import '../entities/measurement.dart';
import '../entities/macro_log.dart';

abstract class WorkoutRepository {
  Future<WorkoutDay?> getDay(DateTime date);
  Future<List<WorkoutDay>> getAllDays();
  Future<void> savePhoto(DateTime date, PhotoRecord photo);
  Future<void> saveMeasurements(DateTime date, List<Measurement> measurements);
  Future<void> saveMacros(DateTime date, MacroLog macros);
  Future<PhotoRecord?> getLatestPhoto(DateTime before, ZoneType zoneType);
}
