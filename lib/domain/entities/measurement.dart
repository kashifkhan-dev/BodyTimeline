import '../value_objects/measurement_type.dart';

class Measurement {
  final MeasurementType type;
  final double value;
  final String unit; // e.g., 'kg', 'cm', 'in'

  const Measurement({required this.type, required this.value, this.unit = 'cm'});
}
