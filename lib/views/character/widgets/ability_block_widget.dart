import 'package:flutter/material.dart';

class AbilityBlockWidget extends StatelessWidget {
  final String label;
  final int score;
  final int modifier;

  const AbilityBlockWidget({
    Key? key,
    required this.label,
    required this.score,
    required this.modifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(score.toString(), style: const TextStyle(fontSize: 18)),
          Text(
            modifier >= 0 ? '+$modifier' : '$modifier',
            style: TextStyle(
              fontSize: 16,
              color: modifier >= 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
