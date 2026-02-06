import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/user_repository.dart';

class InMemoryUserRepository implements UserRepository {
  static const String _avatarKey = 'profile_avatar_path';
  final SharedPreferences _prefs;

  InMemoryUserRepository(this._prefs);

  @override
  Future<String?> getAvatarPath() async {
    return _prefs.getString(_avatarKey);
  }

  @override
  Future<void> saveAvatarPath(String? path) async {
    if (path == null) {
      await _prefs.remove(_avatarKey);
    } else {
      await _prefs.setString(_avatarKey, path);
    }
  }

  Future<void> clear() async {
    await _prefs.remove(_avatarKey);
  }
}
