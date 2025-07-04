import 'dart:math';

class DiceService {
  final Random _random = Random();

  // Roll a single die with the given number of sides
  int rollDie(int sides) {
    return _random.nextInt(sides) + 1; // +1 because nextInt is 0-based
  }

  // Roll multiple dice with the same number of sides
  List<int> rollMultipleDice(int count, int sides) {
    List<int> results = [];
    for (int i = 0; i < count; i++) {
      results.add(rollDie(sides));
    }
    return results;
  }

  // Roll dice with a modifier (e.g. 2d6+3 or 1d20-2)
  // Returns a map with results and total
  Map<String, dynamic> rollWithModifier(int count, int sides, int modifier) {
    List<int> diceResults = rollMultipleDice(count, sides);
    int total = diceResults.fold(0, (sum, item) => sum + item) + modifier;

    return {'diceResults': diceResults, 'modifier': modifier, 'total': total};
  }

  // Parse a dice notation string like "2d6+3"
  Map<String, dynamic> parseDiceNotation(String notation) {
    // Basic regex to parse dice notation like 2d6+3
    final RegExp diceRegex = RegExp(r'(\d+)d(\d+)([+-]\d+)?');
    final Match? match = diceRegex.firstMatch(notation);

    if (match != null) {
      int count = int.parse(match.group(1)!);
      int sides = int.parse(match.group(2)!);
      int modifier = 0;

      // Parse modifier if it exists
      if (match.group(3) != null) {
        modifier = int.parse(match.group(3)!);
      }

      return rollWithModifier(count, sides, modifier);
    }

    // Default to 1d20 if the notation is invalid
    return rollWithModifier(1, 20, 0);
  }
}
