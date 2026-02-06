import '../../domain/entities/tracking_config.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/value_objects/zone_type.dart';
import '../datasources/in_memory_store.dart';

class InMemorySettingsRepository implements SettingsRepository {
  final InMemoryStore _store;

  InMemorySettingsRepository(this._store);

  @override
  Future<TrackingConfig> getConfig() async {
    return _store.currentConfig;
  }

  @override
  Future<void> saveConfig(TrackingConfig config) async {
    _store.currentConfig = config;
  }

  @override
  Future<void> resetConfig() async {
    _store.currentConfig = const TrackingConfig(
      enabledZones: {
        ZoneType.face,
        ZoneType.bodyFront,
        ZoneType.bodySide,
        ZoneType.bodyBack,
        ZoneType.measurements,
        ZoneType.macronutrients,
      },
    );
  }
}
