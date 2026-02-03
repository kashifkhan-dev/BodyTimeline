import '../entities/workout_day.dart';
import '../repositories/workout_repository.dart';
import '../repositories/settings_repository.dart';

abstract class GetTodayWorkout {
  Future<WorkoutDay> call();
}

abstract class SavePhoto {
  Future<void> call(DateTime date, String filePath, dynamic zoneType);
}

abstract class ToggleZone {
  Future<void> call(dynamic zoneType, bool enabled);
}
