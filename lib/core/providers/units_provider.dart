import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UnitSystem { metric, imperial }

class UnitsProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _key = 'unit_system';

  late UnitSystem _unitSystem;

  UnitsProvider(this._prefs) {
    final stored = _prefs.getString(_key);
    _unitSystem = stored == 'imperial' ? UnitSystem.imperial : UnitSystem.metric;
  }

  UnitSystem get unitSystem => _unitSystem;
  bool get isMetric => _unitSystem == UnitSystem.metric;

  void toggleUnitSystem() {
    _unitSystem = _unitSystem == UnitSystem.metric ? UnitSystem.imperial : UnitSystem.metric;
    _prefs.setString(_key, _unitSystem.name);
    notifyListeners();
  }

  void setUnitSystem(UnitSystem system) {
    if (_unitSystem != system) {
      _unitSystem = system;
      _prefs.setString(_key, _unitSystem.name);
      notifyListeners();
    }
  }

  String get heightUnit => isMetric ? 'cm' : 'ft';
  String get weightUnit => isMetric ? 'kg' : 'lbs';
}
