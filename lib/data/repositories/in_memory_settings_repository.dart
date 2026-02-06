import 'dart:async';
import '../../domain/entities/tracking_config.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/value_objects/zone_type.dart';
import '../datasources/in_memory_store.dart';

class InMemorySettingsRepository implements SettingsRepository {
  final InMemoryStore _store;
  final _controller = StreamController<void>.broadcast();

  InMemorySettingsRepository(this._store);

  @override
  Stream<void> get changes => _controller.stream;

  @override
  Future<TrackingConfig> getConfig() async {
    return _store.currentConfig;
  }

  @override
  Future<void> saveConfig(TrackingConfig config) async {
    _store.currentConfig = config;
    _controller.add(null);
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
    _controller.add(null);
  }
}
