import 'dart:math';
import '../../domain/entities/workout_day.dart';
import '../../domain/entities/tracking_config.dart';
import '../../domain/value_objects/zone_type.dart';
import 'mock_photo_generator.dart';
import 'mock_measurement_generator.dart';
import 'mock_macro_generator.dart';

class MockDayGenerator {
  static WorkoutDay generateDay({
    required DateTime date,
    required TrackingConfig config,
    required DateTime startDate,
    double startWeight = 85.0,
  }) {
    final random = Random(date.millisecondsSinceEpoch);

    // Determine which zones will be "completed" based on randomness
    // 80% chance for photos, 90% for measurements if enabled
    final List<ZoneType> activeZones = config.enabledZones.toList();

    final photos = <dynamic>[]; // Temporary dynamic list for PhotoRecord
    final measurements = <dynamic>[]; // Temporary dynamic list for Measurement
    dynamic macros;

    for (final zone in activeZones) {
      // Enthusiastic at the beginning and later consistency improvement simulation logic could goes here
      // UI TESTING: Introduce variability in completion to show off the heatmap beauty
      // Newer days have higher consistency than older days
      final daysAgo = DateTime.now().difference(date).inDays;
      double bias = 1.0 - (daysAgo / 200.0); // Older days are slightly less consistent
      bias = bias.clamp(0.4, 0.95);

      // Some days should be completely "off" (rest days or missed days)
      final isRestDay = (date.weekday == 7 && random.nextDouble() < 0.7); // 70% chance Sunday is off
      final roll = random.nextDouble();
      final completionChance = isRestDay ? 0.0 : (bias + (random.nextDouble() * 0.2 - 0.1));

      if (roll < completionChance) {
        if (zone == ZoneType.face ||
            zone == ZoneType.bodyFront ||
            zone == ZoneType.bodySide ||
            zone == ZoneType.bodyBack) {
          photos.add(MockPhotoGenerator.generate(date: date, zoneType: zone));
        } else if (zone == ZoneType.measurements) {
          measurements.addAll(
            MockMeasurementGenerator.generate(date: date, startDate: startDate, startWeight: startWeight),
          );
        } else if (zone == ZoneType.macronutrients) {
          macros = MockMacroGenerator.generate(date: date);
        }
      }
    }

    // Cast back to correct types because of my cautious dynamic usage
    return WorkoutDay(
      date: date,
      photos: photos.cast(),
      measurements: measurements.cast(),
      macros: macros,
      activeZones: activeZones,
    );
  }

  static List<WorkoutDay> generateHistory({required int daysToGenerate, required TrackingConfig config}) {
    final history = <WorkoutDay>[];
    final now = DateTime.now();
    // Start exactly (daysToGenerate - 1) days ago so that the last day is today
    final startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToGenerate - 1));

    for (int i = 0; i < daysToGenerate; i++) {
      final date = startDate.add(Duration(days: i));
      history.add(generateDay(date: date, config: config, startDate: startDate));
    }

    return history;
  }
}
