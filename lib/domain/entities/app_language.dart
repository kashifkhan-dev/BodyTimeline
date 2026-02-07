enum AppLanguage {
  english('en'),
  spanish('es'),
  french('fr');

  final String code;
  const AppLanguage(this.code);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere((l) => l.code == code, orElse: () => AppLanguage.english);
  }
}
