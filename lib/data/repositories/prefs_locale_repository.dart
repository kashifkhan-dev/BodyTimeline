import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/app_language.dart';
import '../../domain/repositories/locale_repository.dart';

class PrefsLocaleRepository implements LocaleRepository {
  static const String _key = 'app_language';

  @override
  Future<AppLanguage> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code == null) return AppLanguage.english;
    return AppLanguage.fromCode(code);
  }

  @override
  Future<void> saveLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, language.code);
  }
}
