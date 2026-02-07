import 'package:flutter/material.dart';
import '../../domain/entities/app_language.dart';
import '../../domain/repositories/locale_repository.dart';

class LocaleViewModel extends ChangeNotifier {
  final LocaleRepository _repository;
  AppLanguage _currentLanguage = AppLanguage.english;

  LocaleViewModel(this._repository) {
    _loadLocale();
  }

  AppLanguage get currentLanguage => _currentLanguage;
  Locale get locale => Locale(_currentLanguage.code);

  Future<void> _loadLocale() async {
    _currentLanguage = await _repository.getLanguage();
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;
    _currentLanguage = language;
    await _repository.saveLanguage(language);
    notifyListeners();
  }
}
