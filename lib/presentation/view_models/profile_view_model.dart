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

  String? _avatarPath;
  bool _isLoading = false;

  ProfileViewModel(this._userRepository, this._workoutRepository, this._settingsRepository) {
    _loadProfile();
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

  Future<void> setLatestFrontBodyAsAvatar() async {
    _isLoading = true;
    notifyListeners();

    final latestPhoto = await _workoutRepository.getLatestPhoto(DateTime.now(), ZoneType.bodyFront);
    if (latestPhoto != null) {
      _avatarPath = latestPhoto.filePath;
      await _userRepository.saveAvatarPath(_avatarPath);
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
}
