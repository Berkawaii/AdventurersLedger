import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../services/dice_service.dart';

// TODO: Add these imports after properly installing packages
// import 'package:lottie/lottie.dart';
// import 'package:just_audio/just_audio.dart';

class DiceType {
  final int sides;
  final String name;
  final String assetPath;

  const DiceType({
    required this.sides,
    required this.name,
    required this.assetPath,
  });
}

class DiceRollProvider extends ChangeNotifier {
  final DiceService _diceService = DiceService();
  // TODO: Uncomment when just_audio package is properly installed
  // final AudioPlayer _audioPlayer = AudioPlayer();

  List<Map<String, dynamic>> _rollHistory = [];
  List<Map<String, dynamic>> get rollHistory => _rollHistory;

  Map<String, dynamic>? _currentRoll;
  Map<String, dynamic>? get currentRoll => _currentRoll;

  bool _isRolling = false;
  bool get isRolling => _isRolling;

  final List<DiceType> diceTypes = [
    DiceType(sides: 4, name: 'D4', assetPath: 'assets/animations/d4.json'),
    DiceType(sides: 6, name: 'D6', assetPath: 'assets/animations/d6.json'),
    DiceType(sides: 8, name: 'D8', assetPath: 'assets/animations/d8.json'),
    DiceType(sides: 10, name: 'D10', assetPath: 'assets/animations/d10.json'),
    DiceType(sides: 12, name: 'D12', assetPath: 'assets/animations/d12.json'),
    DiceType(sides: 20, name: 'D20', assetPath: 'assets/animations/d20.json'),
    DiceType(
      sides: 100,
      name: 'D100',
      assetPath: 'assets/animations/d100.json',
    ),
  ];

  DiceRollProvider() {
    // Initialize anything needed here
  }

  // TODO: Uncomment when audio package is installed
  /*
  Future<void> _loadAudio() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/dice_roll.mp3');
    } catch (e) {
      debugPrint('Error loading audio: $e');
    }
  }
  */

  Future<void> rollDice(int count, int sides, int modifier) async {
    _isRolling = true;
    notifyListeners();

    // Play sound effect - disabled until audio package is installed
    /*
    try {
      await _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
    */

    // Simulate rolling animation time
    await Future.delayed(const Duration(milliseconds: 1500));

    // Get the roll result
    final result = _diceService.rollWithModifier(count, sides, modifier);

    // Add timestamp and dice type info
    result['timestamp'] = DateTime.now();
    result['diceType'] = 'd$sides';
    result['count'] = count;

    _currentRoll = result;
    _rollHistory.insert(0, result); // Add to beginning of history

    // Limit history to 20 items
    if (_rollHistory.length > 20) {
      _rollHistory.removeLast();
    }

    _isRolling = false;
    notifyListeners();
  }

  Future<void> rollWithNotation(String notation) async {
    _isRolling = true;
    notifyListeners();

    // Play sound effect - disabled until audio package is installed
    /*
    try {
      await _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
    */

    // Simulate rolling animation time
    await Future.delayed(const Duration(milliseconds: 1500));

    // Parse and roll
    final RegExp diceRegex = RegExp(r'(\d+)d(\d+)([+-]\d+)?');
    final Match? match = diceRegex.firstMatch(notation);

    late Map<String, dynamic> result;
    int count = 1;
    int sides = 20;
    int modifier = 0;

    if (match != null) {
      count = int.parse(match.group(1)!);
      sides = int.parse(match.group(2)!);

      // Parse modifier if it exists
      if (match.group(3) != null) {
        modifier = int.parse(match.group(3)!);
      }

      result = _diceService.rollWithModifier(count, sides, modifier);
    } else {
      result = _diceService.rollWithModifier(1, 20, 0);
    }

    // Add timestamp and dice type info
    result['timestamp'] = DateTime.now();
    result['diceType'] = 'd$sides';
    result['count'] = count;
    result['notation'] = notation;

    _currentRoll = result;
    _rollHistory.insert(0, result); // Add to beginning of history

    // Limit history to 20 items
    if (_rollHistory.length > 20) {
      _rollHistory.removeLast();
    }

    _isRolling = false;
    notifyListeners();
  }

  void clearHistory() {
    _rollHistory = [];
    notifyListeners();
  }

  @override
  void dispose() {
    // Disabled until audio package is installed
    // _audioPlayer.dispose();
    super.dispose();
  }
}

class DiceRollerDialog extends StatefulWidget {
  final Function(Map<String, dynamic>)? onRollComplete;

  const DiceRollerDialog({Key? key, this.onRollComplete}) : super(key: key);

  @override
  _DiceRollerDialogState createState() => _DiceRollerDialogState();
}

class _DiceRollerDialogState extends State<DiceRollerDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _diceNotationController = TextEditingController();
  int _selectedDiceType = 20; // Default to D20
  int _diceCount = 1;
  int _modifier = 0;
  bool _showCustomNotation = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DiceRollProvider(),
      child: Builder(
        builder: (context) {
          final diceProvider = Provider.of<DiceRollProvider>(context);

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(color: AppTheme.secondaryColor, width: 1.5),
            ),
            backgroundColor: AppTheme.accentColor,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Roll The Dice',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dice animation
                  if (diceProvider.isRolling) ...[
                    SizedBox(
                      height: 150,
                      // Temporarily replace Lottie animation with a simple rotating icon
                      child: Center(
                        child: RotationTransition(
                          turns: AlwaysStoppedAnimation(
                            DateTime.now().millisecond / 1000,
                          ),
                          child: Icon(
                            Icons.casino,
                            size: 80,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ),
                      // TODO: Uncomment when Lottie package is installed
                      /*
                      child: Lottie.asset(
                        diceProvider.diceTypes.firstWhere(
                          (type) => type.sides == _selectedDiceType,
                          orElse: () => diceProvider.diceTypes.last,
                        ).assetPath,
                        repeat: true,
                        animate: true,
                      ),
                      */
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rolling...',
                      style: TextStyle(fontSize: 18, color: AppTheme.textLight),
                    ),
                  ] else if (diceProvider.currentRoll != null) ...[
                    // Show the result
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundDark.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Result: ${diceProvider.currentRoll!['total']}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dice: ${(diceProvider.currentRoll!['diceResults'] as List).join(', ')}',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textLight,
                            ),
                          ),
                          if (diceProvider.currentRoll!['modifier'] != 0)
                            Text(
                              'Modifier: ${diceProvider.currentRoll!['modifier'] > 0 ? '+' : ''}${diceProvider.currentRoll!['modifier']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textLight,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Toggle between standard and custom notation
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                !_showCustomNotation
                                    ? AppTheme.primaryColor
                                    : AppTheme.backgroundDark,
                            foregroundColor:
                                !_showCustomNotation
                                    ? AppTheme.textLight
                                    : AppTheme.textLight.withOpacity(0.7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _showCustomNotation = false;
                            });
                          },
                          child: const Text('Standard'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _showCustomNotation
                                    ? AppTheme.primaryColor
                                    : AppTheme.backgroundDark,
                            foregroundColor:
                                _showCustomNotation
                                    ? AppTheme.textLight
                                    : AppTheme.textLight.withOpacity(0.7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _showCustomNotation = true;
                            });
                          },
                          child: const Text('Custom'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (!_showCustomNotation) ...[
                    // Dice type selector
                    Container(
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundDark.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: diceProvider.diceTypes.length,
                        itemBuilder: (context, index) {
                          final diceType = diceProvider.diceTypes[index];
                          final isSelected =
                              diceType.sides == _selectedDiceType;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDiceType = diceType.sides;
                              });
                            },
                            child: Container(
                              width: 60,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? AppTheme.primaryColor
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? AppTheme.secondaryColor
                                          : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                diceType.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected
                                          ? AppTheme.textLight
                                          : AppTheme.textLight.withOpacity(0.8),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dice count and modifier
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Number of Dice',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textLight,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    color: AppTheme.secondaryColor,
                                    onPressed:
                                        _diceCount > 1
                                            ? () => setState(() => _diceCount--)
                                            : null,
                                  ),
                                  Text(
                                    '$_diceCount',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: AppTheme.secondaryColor,
                                    onPressed:
                                        _diceCount < 10
                                            ? () => setState(() => _diceCount++)
                                            : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Modifier',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textLight,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    color: AppTheme.secondaryColor,
                                    onPressed:
                                        () => setState(() => _modifier--),
                                  ),
                                  Text(
                                    _modifier >= 0
                                        ? '+$_modifier'
                                        : '$_modifier',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: AppTheme.secondaryColor,
                                    onPressed:
                                        () => setState(() => _modifier++),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'Formula: $_diceCount'
                      'd$_selectedDiceType'
                      '${_modifier >= 0 ? '+$_modifier' : '$_modifier'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ] else ...[
                    // Custom dice notation
                    TextField(
                      controller: _diceNotationController,
                      decoration: InputDecoration(
                        hintText: 'Enter dice notation (e.g. 2d6+3)',
                        hintStyle: TextStyle(
                          color: AppTheme.textLight.withOpacity(0.6),
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundDark.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primaryColor.withOpacity(0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ),
                      style: TextStyle(fontSize: 18, color: AppTheme.textLight),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Format: [count]d[sides]+/-[modifier]',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textLight.withOpacity(0.7),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Roll button
                  ElevatedButton.icon(
                    icon: const Icon(Icons.casino),
                    label: Text(
                      diceProvider.isRolling ? 'Rolling...' : 'Roll Dice',
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.textLight,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppTheme.secondaryColor,
                          width: 1,
                        ),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed:
                        diceProvider.isRolling
                            ? null
                            : () async {
                              if (_showCustomNotation) {
                                final notation =
                                    _diceNotationController.text.trim();
                                if (notation.isNotEmpty) {
                                  await diceProvider.rollWithNotation(notation);
                                } else {
                                  await diceProvider.rollWithNotation('1d20');
                                }
                              } else {
                                await diceProvider.rollDice(
                                  _diceCount,
                                  _selectedDiceType,
                                  _modifier,
                                );
                              }

                              if (widget.onRollComplete != null &&
                                  diceProvider.currentRoll != null) {
                                widget.onRollComplete!(
                                  diceProvider.currentRoll!,
                                );
                              }
                            },
                  ),

                  const SizedBox(height: 16),

                  // Roll history
                  if (diceProvider.rollHistory.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text(
                            'History',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            icon: Icon(
                              Icons.clear_all,
                              size: 16,
                              color: AppTheme.textLight.withOpacity(0.7),
                            ),
                            label: Text(
                              'Clear',
                              style: TextStyle(
                                color: AppTheme.textLight.withOpacity(0.7),
                              ),
                            ),
                            onPressed: () => diceProvider.clearHistory(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundDark.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: diceProvider.rollHistory.length,
                          itemBuilder: (context, index) {
                            final roll = diceProvider.rollHistory[index];
                            final List<int> diceResults = roll['diceResults'];
                            final int modifier = roll['modifier'];
                            final int total = roll['total'];
                            final String diceType = roll['diceType'];
                            final int count = roll['count'];

                            return ListTile(
                              dense: true,
                              title: Text(
                                'Roll: $total',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                              subtitle: Text(
                                '$count$diceType${modifier != 0 ? (modifier > 0 ? '+$modifier' : '$modifier') : ''} = ${diceResults.join(', ')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textLight.withOpacity(0.8),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.refresh, size: 16),
                                color: AppTheme.primaryColor,
                                onPressed: () {
                                  if (_showCustomNotation) {
                                    final notation =
                                        roll['notation'] ??
                                        '$count$diceType${modifier != 0 ? (modifier > 0 ? '+$modifier' : '$modifier') : ''}';
                                    diceProvider.rollWithNotation(notation);
                                  } else {
                                    diceProvider.rollDice(
                                      count,
                                      int.parse(diceType.substring(1)),
                                      modifier,
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _diceNotationController.dispose();
    super.dispose();
  }
}

// Function to show the dice roller dialog anywhere in the app
Future<Map<String, dynamic>?> showDiceRoller(BuildContext context) async {
  Map<String, dynamic>? result;

  await showDialog(
    context: context,
    builder:
        (context) => DiceRollerDialog(
          onRollComplete: (rollResult) {
            result = rollResult;
          },
        ),
  );

  return result;
}
