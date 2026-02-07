import 'dart:async';
import 'dart:developer' as dev;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/tracking_config.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/value_objects/zone_type.dart';
import '../datasources/in_memory_store.dart';

class InMemorySettingsRepository implements SettingsRepository {
  final InMemoryStore _store;
  final SharedPreferences _prefs;
  final _controller = StreamController<void>.broadcast();

  static const String _keyEnabledZones = 'settings_enabled_zones';
  static const String _keyUsePhotoAsAvatar = 'settings_use_photo_as_avatar';

  InMemorySettingsRepository(this._store, this._prefs);

  Future<void> init() async {
    dev.log("PREFS: Initializing settings from SharedPreferences...");
    final enabledZonesRaw = _prefs.getStringList(_keyEnabledZones);
    final usePhotoAsAvatar = _prefs.getBool(_keyUsePhotoAsAvatar) ?? false;

    Set<ZoneType> enabledZones;
    if (enabledZonesRaw == null) {
      enabledZones = {
        ZoneType.face,
        ZoneType.bodyFront,
        ZoneType.bodySide,
        ZoneType.bodyBack,
        ZoneType.measurements,
        ZoneType.macronutrients,
      };
    } else {
      enabledZones = enabledZonesRaw.map((name) => ZoneType.values.firstWhere((e) => e.name == name)).toSet();
    }

    dev.log("PREFS: Successfully loaded settings [Zones: ${enabledZones.length}, AsyncAvatar: $usePhotoAsAvatar]");
    _store.currentConfig = TrackingConfig(enabledZones: enabledZones, usePhotoAsAvatar: usePhotoAsAvatar);
  }

  @override
  Stream<void> get changes => _controller.stream;

  @override
  Future<TrackingConfig> getConfig() async {
    return _store.currentConfig;
  }

  @override
  Future<void> saveConfig(TrackingConfig config) async {
    dev.log("PREFS: Persisting new config to SharedPreferences...");
    _store.currentConfig = config;

    await _prefs.setStringList(_keyEnabledZones, config.enabledZones.map((e) => e.name).toList());
    await _prefs.setBool(_keyUsePhotoAsAvatar, config.usePhotoAsAvatar);

    _controller.add(null);
  }

  @override
  Future<void> resetConfig() async {
    const config = TrackingConfig(
      enabledZones: {
        ZoneType.face,
        ZoneType.bodyFront,
        ZoneType.bodySide,
        ZoneType.bodyBack,
        ZoneType.measurements,
        ZoneType.macronutrients,
      },
    );
    await saveConfig(config);
  }
}
