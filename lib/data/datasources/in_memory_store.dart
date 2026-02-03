import '../../domain/entities/workout_day.dart';
import '../../domain/entities/tracking_config.dart';
import '../../domain/value_objects/zone_type.dart';

class InMemoryStore {
  // Singleton pattern for simplicity in this phase
  static final InMemoryStore _instance = InMemoryStore._internal();
  factory InMemoryStore() => _instance;
  InMemoryStore._internal();

  final Map<String, WorkoutDay> days = {};
  TrackingConfig currentConfig = const TrackingConfig(
    enabledZones: {ZoneType.face, ZoneType.bodyFront, ZoneType.measurements},
  );

  String dateToKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
