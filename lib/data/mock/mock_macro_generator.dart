import 'dart:math';
import '../../domain/entities/macro_log.dart';

class MockMacroGenerator {
  static MacroLog generate({required DateTime date}) {
    final random = Random(date.millisecondsSinceEpoch);

    // Base targets
    const targetCalories = 2200.0;
    const targetProtein = 160.0;

    // Vary calories by +/- 200
    final calories = targetCalories + (random.nextDouble() * 400 - 200);
    // Protein stays relatively stable
    final protein = targetProtein + (random.nextDouble() * 20 - 10);

    return MacroLog(
      calories: double.parse(calories.toStringAsFixed(0)),
      protein: double.parse(protein.toStringAsFixed(0)),
      carbs: 200.0,
      fat: 70.0,
    );
  }
}
