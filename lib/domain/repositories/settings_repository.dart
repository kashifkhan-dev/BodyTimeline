import '../entities/tracking_config.dart';

abstract class SettingsRepository {
  Stream<void> get changes;
  Future<TrackingConfig> getConfig();
  Future<void> saveConfig(TrackingConfig config);
  Future<void> resetConfig();
}
