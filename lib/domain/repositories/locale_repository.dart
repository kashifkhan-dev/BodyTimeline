import '../entities/app_language.dart';

abstract class LocaleRepository {
  Future<AppLanguage> getLanguage();
  Future<void> saveLanguage(AppLanguage language);
}
