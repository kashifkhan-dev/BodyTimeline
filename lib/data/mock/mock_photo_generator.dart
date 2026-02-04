import 'dart:math';
import '../../domain/entities/photo_record.dart';
import '../../domain/value_objects/zone_type.dart';

class MockPhotoGenerator {
  static PhotoRecord generate({required DateTime date, required ZoneType zoneType}) {
    final random = Random(date.millisecondsSinceEpoch + zoneType.index);
    final id = "photo_${date.millisecondsSinceEpoch}_${zoneType.name}";

    // Use provided transformation images (1.png to 19.png)
    // We Map the date to one of the 19 images to simulate progress in mock data
    final dayIndex = (date.day % 19) + 1;
    final path = "assets/images/transformation/$dayIndex.png";

    return PhotoRecord(
      id: id,
      filePath: path,
      capturedAt: date.add(Duration(hours: 8, minutes: random.nextInt(60))),
      zoneType: zoneType,
    );
  }
}
