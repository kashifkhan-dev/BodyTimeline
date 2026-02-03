import 'dart:math';
import '../../domain/entities/measurement.dart';
import '../../domain/value_objects/measurement_type.dart';

class MockMeasurementGenerator {
  static List<Measurement> generate({
    required DateTime date,
    required DateTime startDate,
    required double startWeight,
  }) {
    final random = Random(date.millisecondsSinceEpoch);

    // Calculate days passed to simulate progress
    final daysPassed = date.difference(startDate).inDays;

    // Weight trends downward: -0.1kg per day on average with noise
    final weightLoss = (daysPassed * 0.05) + (random.nextDouble() * 0.5);
    final currentWeight = startWeight - weightLoss;

    return [
      Measurement(type: MeasurementType.weight, value: double.parse(currentWeight.toStringAsFixed(1)), unit: 'kg'),
      Measurement(type: MeasurementType.waist, value: 85.0 - (daysPassed * 0.02), unit: 'cm'),
      Measurement(type: MeasurementType.chest, value: 100.0 - (daysPassed * 0.01), unit: 'cm'),
    ];
  }
}
