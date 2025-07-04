import 'package:flutter/material.dart';

import '../../../models/character.dart';
import '../dialogs/spell_dialog.dart';

class SpellsTab extends StatelessWidget {
  final Character character;

  const SpellsTab({Key? key, required this.character}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Spells',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (character.spells != null && character.spells!.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: character.spells!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.auto_fix_high),
                          title: Text(character.spells![index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              SpellDialog.showRemoveSpellDialog(
                                context,
                                character,
                                character.spells![index],
                              );
                            },
                          ),
                          onTap: () {
                            SpellDialog.showSpellDetails(
                              context,
                              character.spells![index],
                            );
                          },
                        );
                      },
                    )
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No spells added yet'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Add spell button
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                SpellDialog.showAddSpellDialog(context, character);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Spell'),
            ),
          ),
        ],
      ),
    );
  }
}
