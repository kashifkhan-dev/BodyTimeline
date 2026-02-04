import 'photo_record.dart';
import 'measurement.dart';
import 'macro_log.dart';
import '../value_objects/zone_type.dart';

class WorkoutDay {
  final DateTime date;
  final List<PhotoRecord> photos;
  final List<Measurement> measurements;
  final MacroLog? macros;
  final List<ZoneType> activeZones; // What was required on this day

  const WorkoutDay({
    required this.date,
    this.photos = const [],
    this.measurements = const [],
    this.macros,
    required this.activeZones,
  });

  bool isZoneCompleted(ZoneType zone) {
    switch (zone) {
      case ZoneType.face:
      case ZoneType.bodyFront:
      case ZoneType.bodySide:
      case ZoneType.bodyBack:
        return photos.any((p) => p.zoneType == zone);
      case ZoneType.measurements:
        return measurements.isNotEmpty;
      case ZoneType.macronutrients:
        if (macros == null) return false;
        return macros!.calories > 0 && macros!.protein > 0 && macros!.carbs > 0 && macros!.fat > 0;
    }
  }

  double get completionPercentage {
    if (activeZones.isEmpty) return 1.0;
    final int completed = activeZones.where((z) => isZoneCompleted(z)).length;
    return completed / activeZones.length;
  }

  bool get isCompleted => completionPercentage >= 1.0;
}
