import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/value_objects/zone_type.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/settings_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final WorkoutRepository _workoutRepository;
  final SettingsRepository _settingsRepository;
  final ImagePicker _picker = ImagePicker();
  StreamSubscription? _subscription;

  String? _avatarPath;
  bool _isLoading = false;

  ProfileViewModel(this._userRepository, this._workoutRepository, this._settingsRepository) {
    _loadProfile();
    _subscription = _workoutRepository.changes.listen((_) => _onWorkoutChanged());
  }

  String? get avatarPath => _avatarPath;
  bool get isLoading => _isLoading;

  Future<void> refresh() async {
    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    _avatarPath = await _userRepository.getAvatarPath();
    notifyListeners();
  }

  Future<void> _onWorkoutChanged() async {
    // Reload config to get latest toggle state
    final config = await _settingsRepository.getConfig();
    if (config.usePhotoAsAvatar) {
      await setLatestFrontBodyAsAvatar();
    }
  }

  Future<void> setLatestFrontBodyAsAvatar() async {
    _isLoading = true;
    notifyListeners();

    // Prioritize Body Front per PRD
    var latestPhoto = await _workoutRepository.getLatestPhoto(
      DateTime.now().add(const Duration(days: 1)), // Ensure we check current day
      ZoneType.bodyFront,
    );

    // Fallback to Face if Body Front missing
    if (latestPhoto == null) {
      latestPhoto = await _workoutRepository.getLatestPhoto(DateTime.now().add(const Duration(days: 1)), ZoneType.face);
    }

    if (latestPhoto != null) {
      _avatarPath = latestPhoto.filePath;
      await _userRepository.saveAvatarPath(_avatarPath);
    } else {
      // If auto-use is on but no photos exist, we don't clear the path
      // yet as it might be a gallery image?
      // Actually, if auto-use is on, it should probably clear if no photo found.
      // But let's follow user rules: "When no user-selected image is available, use /assets/images/front.png"
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _avatarPath = image.path;
      await _userRepository.saveAvatarPath(_avatarPath);
      notifyListeners();
    }
  }

  Future<void> deleteAllData() async {
    await _workoutRepository.deleteAllData();
    await _settingsRepository.resetConfig();
    await _userRepository.saveAvatarPath(null);
    _avatarPath = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
