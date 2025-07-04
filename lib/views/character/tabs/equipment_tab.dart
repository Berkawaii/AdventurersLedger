import 'package:flutter/material.dart';

import '../../../models/character.dart';
import '../dialogs/equipment_dialog.dart';

class EquipmentTab extends StatelessWidget {
  final Character character;

  const EquipmentTab({Key? key, required this.character}) : super(key: key);

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
                    'Equipment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (character.equipment.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: character.equipment.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.inventory_2),
                          title: Text(character.equipment[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              EquipmentDialog.showRemoveEquipmentDialog(
                                context,
                                character,
                                character.equipment[index],
                              );
                            },
                          ),
                          onTap: () {
                            EquipmentDialog.showEquipmentDetails(
                              context,
                              character.equipment[index],
                            );
                          },
                        );
                      },
                    )
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No equipment added yet'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Add equipment button
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                EquipmentDialog.showAddEquipmentDialog(context, character);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Equipment'),
            ),
          ),
        ],
      ),
    );
  }
}
