import 'package:flutter/material.dart';

import '../../../models/character.dart';
import '../widgets/ability_block_widget.dart';

class AbilitiesTab extends StatelessWidget {
  final Character character;

  const AbilitiesTab({Key? key, required this.character}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ability scores
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ability Scores',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AbilityBlockWidget(
                        label: 'STR',
                        score: character.strength,
                        modifier: character.getAbilityModifier(character.strength),
                      ),
                      AbilityBlockWidget(
                        label: 'DEX',
                        score: character.dexterity,
                        modifier: character.getAbilityModifier(character.dexterity),
                      ),
                      AbilityBlockWidget(
                        label: 'CON',
                        score: character.constitution,
                        modifier: character.getAbilityModifier(character.constitution),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AbilityBlockWidget(
                        label: 'INT',
                        score: character.intelligence,
                        modifier: character.getAbilityModifier(character.intelligence),
                      ),
                      AbilityBlockWidget(
                        label: 'WIS',
                        score: character.wisdom,
                        modifier: character.getAbilityModifier(character.wisdom),
                      ),
                      AbilityBlockWidget(
                        label: 'CHA',
                        score: character.charisma,
                        modifier: character.getAbilityModifier(character.charisma),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Skills
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Skills & Proficiencies',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Skills
                  if (character.skills.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Skills:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children:
                              character.skills
                                  .map(
                                    (skill) => Chip(
                                      label: Text(skill),
                                      backgroundColor: Colors.blue.shade100,
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    )
                  else
                    const Text('No skills selected'),

                  const SizedBox(height: 16),

                  // Proficiencies
                  if (character.proficiencies.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Proficiencies:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children:
                              character.proficiencies
                                  .map(
                                    (prof) => Chip(
                                      label: Text(prof),
                                      backgroundColor: Colors.green.shade100,
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    )
                  else
                    const Text('No proficiencies selected'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
