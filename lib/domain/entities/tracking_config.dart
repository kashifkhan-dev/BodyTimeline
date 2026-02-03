import '../value_objects/zone_type.dart';

class TrackingConfig {
  final Set<ZoneType> enabledZones;

  const TrackingConfig({required this.enabledZones});

  bool isEnabled(ZoneType zone) => enabledZones.contains(zone);

  TrackingConfig copyWith({Set<ZoneType>? enabledZones}) {
    return TrackingConfig(enabledZones: enabledZones ?? this.enabledZones);
  }
}
