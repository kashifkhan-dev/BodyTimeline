import '../entities/tracking_config.dart';

abstract class SettingsRepository {
  Future<TrackingConfig> getConfig();
  Future<void> saveConfig(TrackingConfig config);
}
