import 'package:flutter/material.dart';

class StatColumnWidget extends StatelessWidget {
  final String label;
  final String value;

  const StatColumnWidget({Key? key, required this.label, required this.value})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18)),
      ],
    );
  }
}
