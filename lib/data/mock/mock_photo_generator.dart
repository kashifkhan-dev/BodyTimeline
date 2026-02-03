import 'dart:math';
import '../../domain/entities/photo_record.dart';
import '../../domain/value_objects/zone_type.dart';

class MockPhotoGenerator {
  static PhotoRecord generate({required DateTime date, required ZoneType zoneType}) {
    final random = Random(date.millisecondsSinceEpoch + zoneType.index);
    final id = "photo_${date.millisecondsSinceEpoch}_${zoneType.name}";

    // Simulating placeholder paths
    final path = "assets/mocks/${zoneType.name.toLowerCase()}_${date.day % 5}.jpg";

    return PhotoRecord(
      id: id,
      filePath: path,
      capturedAt: date.add(Duration(hours: 8, minutes: random.nextInt(60))),
      zoneType: zoneType,
    );
  }
}
