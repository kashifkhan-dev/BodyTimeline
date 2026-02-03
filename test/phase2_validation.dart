import 'package:workout/data/datasources/in_memory_store.dart';
import 'package:workout/data/repositories/in_memory_workout_repository.dart';
import 'package:workout/domain/value_objects/zone_type.dart';

void main() async {
  print("--- Validating Phase 2 Data Layer ---");

  final store = InMemoryStore();
  final repo = InMemoryWorkoutRepository(store);

  final days = await repo.getAllDays();
  print("Generated ${days.length} days of history.");

  if (days.isNotEmpty) {
    print("Example Day: ${days.first.date}");
    print("Completion: ${(days.first.completionPercentage * 100).toStringAsFixed(0)}%");
    print("Photos captured: ${days.first.photos.length}");
  }

  final today = await repo.getDay(DateTime.now());
  print("\nToday's Day Object: ${today?.date}");
  print("Today's Active Zones: ${today?.activeZones.map((e) => e.name).toList()}");

  final latestFace = await repo.getLatestPhoto(DateTime.now(), ZoneType.face);
  if (latestFace != null) {
    print("\nGhost Overlay Found!");
    print("Latest Face Photo from: ${latestFace.capturedAt}");
    print("Path: ${latestFace.filePath}");
  } else {
    print("\nNo previous Face photo found (yet).");
  }

  print("\n--- Validation Complete ---");
}
