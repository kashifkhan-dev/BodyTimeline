import '../value_objects/zone_type.dart';

class TrackingConfig {
  final Set<ZoneType> enabledZones;
  final bool usePhotoAsAvatar;

  const TrackingConfig({required this.enabledZones, this.usePhotoAsAvatar = false});

  bool isEnabled(ZoneType zone) => enabledZones.contains(zone);

  TrackingConfig copyWith({Set<ZoneType>? enabledZones, bool? usePhotoAsAvatar}) {
    return TrackingConfig(
      enabledZones: enabledZones ?? this.enabledZones,
      usePhotoAsAvatar: usePhotoAsAvatar ?? this.usePhotoAsAvatar,
    );
  }
}
