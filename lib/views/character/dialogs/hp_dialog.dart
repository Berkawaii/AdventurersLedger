import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_theme.dart';
import '../../../models/character.dart';
import '../../../view_models/character_view_model.dart';

class HPDialog {
  static void show(BuildContext context, Character character) {
    final TextEditingController controller = TextEditingController();
    final viewModel = Provider.of<CharacterViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.accentColor,
            title: Text(
              'Update Hit Points',
              style: TextStyle(color: AppTheme.secondaryColor),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current HP: ${character.currentHitPoints}/${character.hitPoints}',
                  style: TextStyle(color: AppTheme.textLight),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'New HP Value',
                    labelStyle: TextStyle(color: AppTheme.textLight),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: AppTheme.backgroundDark.withOpacity(0.3),
                  ),
                  style: TextStyle(color: AppTheme.textLight),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.textLight),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Parse the new HP value
                  int? newHp = int.tryParse(controller.text);
                  if (newHp != null) {
                    // Calculate the difference from current HP
                    int diff = newHp - character.currentHitPoints;
                    viewModel.updateCharacterHP(character.id, diff);
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  'Update',
                  style: TextStyle(color: AppTheme.secondaryColor),
                ),
              ),
            ],
          ),
    );
  }
}
