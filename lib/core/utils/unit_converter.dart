class UnitConverter {
  // Height: cm <-> ft/in
  static double cmToInches(double cm) => cm / 2.54;
  static double inchesToCm(double inches) => inches * 2.54;

  static double mToFt(double m) => m * 3.28084;
  static double ftToM(double ft) => ft / 3.28084;

  static Map<String, int> cmToFeetInches(double cm) {
    final totalInches = cm / 2.54;
    final feet = (totalInches / 12).floor();
    final inches = (totalInches % 12).round();
    return {'feet': feet, 'inches': inches};
  }

  static double feetInchesToCm(int feet, int inches) {
    final totalInches = (feet * 12) + inches;
    return totalInches * 2.54;
  }

  // Weight: kg <-> lbs
  static double kgToLbs(double kg) => kg * 2.20462;
  static double lbsToKg(double lbs) => lbs / 2.20462;

  // Macros: g <-> oz
  static double gToOz(double g) => g * 0.035274;
  static double ozToG(double oz) => oz / 0.035274;

  // Formatters
  static String formatCmAsFeetInches(double cm) {
    final map = cmToFeetInches(cm);
    return "${map['feet']}'${map['inches']}\"";
  }
}
