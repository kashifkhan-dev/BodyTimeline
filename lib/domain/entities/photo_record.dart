import '../value_objects/zone_type.dart';

class PhotoRecord {
  final String id;
  final String filePath;
  final DateTime capturedAt;
  final ZoneType zoneType;

  const PhotoRecord({required this.id, required this.filePath, required this.capturedAt, required this.zoneType});
}
