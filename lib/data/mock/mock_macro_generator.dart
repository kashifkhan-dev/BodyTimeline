import 'dart:math';
import '../../domain/entities/macro_log.dart';

class MockMacroGenerator {
  static MacroLog generate({required DateTime date}) {
    final random = Random(date.millisecondsSinceEpoch);

    // Base targets
    const targetCalories = 2200.0;
    const targetProtein = 160.0;

    // Calorie-protein balanced targets
    final calories = targetCalories + (random.nextDouble() * 400 - 200);
    final protein = targetProtein + (random.nextDouble() * 30 - 15);
    final carbs = 180.0 + (random.nextDouble() * 60 - 30);
    final fat = 65.0 + (random.nextDouble() * 20 - 10);

    return MacroLog(
      calories: calories.roundToDouble(),
      protein: protein.roundToDouble(),
      carbs: carbs.roundToDouble(),
      fat: fat.roundToDouble(),
    );
  }
}
