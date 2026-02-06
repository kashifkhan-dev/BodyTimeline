abstract class UserRepository {
  Future<String?> getAvatarPath();
  Future<void> saveAvatarPath(String? path);
}
