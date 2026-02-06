import 'package:flutter/foundation.dart';
import '../../domain/entities/tracking_config.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/value_objects/zone_type.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repository;
  TrackingConfig? _config;

  SettingsViewModel(this._repository) {
    loadConfig();
  }

  TrackingConfig? get config => _config;

  Future<void> loadConfig() async {
    _config = await _repository.getConfig();
    notifyListeners();
  }

  Future<void> toggleZone(ZoneType zone, bool enabled) async {
    if (_config == null) return;

    final newZones = Set<ZoneType>.from(_config!.enabledZones);
    if (enabled) {
      newZones.add(zone);
    } else {
      newZones.remove(zone);
    }

    final newConfig = _config!.copyWith(enabledZones: newZones);
    await _repository.saveConfig(newConfig);
    _config = newConfig;
    notifyListeners();
  }

  Future<void> toggleUsePhotoAsAvatar(bool enabled) async {
    if (_config == null) return;
    final newConfig = _config!.copyWith(usePhotoAsAvatar: enabled);
    await _repository.saveConfig(newConfig);
    _config = newConfig;
    notifyListeners();
  }
}
