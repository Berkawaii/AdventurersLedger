import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../models/character.dart';
import '../../../models/equipment.dart';
import '../../../view_models/character_view_model.dart';
import '../../../view_models/equipment_view_model.dart';

class EquipmentDialog {
  static void showAddEquipmentDialog(BuildContext context, Character character) {
    final TextEditingController equipmentController = TextEditingController();
    final characterViewModel = Provider.of<CharacterViewModel>(
      context,
      listen: false,
    );
    final equipmentViewModel = EquipmentViewModel();
    bool isManualEntry = true;
    Timer? _debounce;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Equipment'),
              content:
                  isManualEntry
                      ? SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: equipmentController,
                              decoration: const InputDecoration(
                                labelText: 'Equipment Name',
                                hintText:
                                    'e.g., Longsword, Chain Mail, Potion of Healing',
                              ),
                              autofocus: true,
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isManualEntry = false;
                                  equipmentViewModel.loadEquipment();
                                });
                              },
                              child: const Text('Browse D&D Equipment'),
                            ),
                          ],
                        ),
                      )
                      : FutureBuilder(
                        future: equipmentViewModel.loadEquipment(),
                        builder: (context, snapshot) {
                          if (equipmentViewModel.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (equipmentViewModel.errorMessage != null) {
                            return Center(
                              child: Text(
                                'Error: ${equipmentViewModel.errorMessage}',
                              ),
                            );
                          }

                          if (equipmentViewModel.equipment.isEmpty) {
                            return const Center(
                              child: Text('No equipment found'),
                            );
                          }

                          // Filter equipment based on search text
                          final filteredEquipment =
                              equipmentController.text.isEmpty
                                  ? equipmentViewModel.equipment
                                  : equipmentViewModel.equipment
                                      .where(
                                        (equipment) => equipment.name
                                            .toLowerCase()
                                            .contains(
                                              equipmentController.text
                                                  .toLowerCase(),
                                            ),
                                      )
                                      .toList();

                          return SizedBox(
                            width: double.maxFinite,
                            height: 300,
                            child: Column(
                              children: [
                                TextField(
                                  controller: equipmentController,
                                  decoration: const InputDecoration(
                                    labelText: 'Search Equipment',
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                  onChanged: (value) {
                                    // Debounce logic
                                    if (_debounce?.isActive ?? false) {
                                      _debounce!.cancel();
                                    }

                                    // Wait 500ms before applying the filter
                                    _debounce = Timer(
                                      const Duration(milliseconds: 500),
                                      () {
                                        setState(() {
                                          // Empty setState will rebuild with new filter
                                        });
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: filteredEquipment.length,
                                    itemBuilder: (context, index) {
                                      final equipment =
                                          filteredEquipment[index];
                                      return ListTile(
                                        title: Text(equipment.name),
                                        subtitle:
                                            equipment.category != null
                                                ? Text(equipment.category!)
                                                : null,
                                        onTap: () async {
                                          Navigator.of(context).pop();

                                          final success =
                                              await characterViewModel
                                                  .addEquipmentToCharacter(
                                            character.id,
                                            equipment.name,
                                          );

                                          if (success && context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Added ${equipment.name} to inventory',
                                                ),
                                              ),
                                            );
                                          } else if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error adding equipment: ${characterViewModel.errorMessage ?? "Unknown error"}',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isManualEntry = true;
                                    });
                                  },
                                  child: const Text('Enter Manual Equipment'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              actions: [
                TextButton(
                  onPressed: () {
                    _debounce?.cancel(); // Cancel any pending debounce timer
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                if (isManualEntry)
                  TextButton(
                    onPressed: () async {
                      final equipmentName = equipmentController.text.trim();
                      if (equipmentName.isEmpty) return;

                      Navigator.of(context).pop();

                      final success = await characterViewModel
                          .addEquipmentToCharacter(character.id, equipmentName);

                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added $equipmentName to inventory'),
                          ),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error adding equipment: ${characterViewModel.errorMessage ?? "Unknown error"}',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text('Add'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  static void showRemoveEquipmentDialog(
      BuildContext context, Character character, String equipment) {
    final viewModel = Provider.of<CharacterViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Equipment'),
            content: Text(
              'Are you sure you want to remove "$equipment" from your inventory?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  final success = await viewModel.removeEquipmentFromCharacter(
                    character.id,
                    equipment,
                  );

                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Removed $equipment from inventory'),
                      ),
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error removing equipment: ${viewModel.errorMessage ?? "Unknown error"}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Remove'),
              ),
            ],
          ),
    );
  }

  static void showEquipmentDetails(BuildContext context, String equipmentName) {
    // Create a local EquipmentViewModel instead of using Provider
    final equipmentViewModel = EquipmentViewModel();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading equipment details..."),
              ],
            ),
          ),
    );

    try {
      // Load the equipment list
      equipmentViewModel.loadEquipment().then((_) async {
        // Load detailed equipment info directly by name
        await equipmentViewModel.loadEquipmentDetailsByName(equipmentName);

        // Close loading dialog
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        if (equipmentViewModel.selectedEquipment != null && context.mounted) {
          final equipment = equipmentViewModel.selectedEquipment!;

          // Show equipment details
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(equipment.name),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (equipment.category != null)
                          _buildDetailRow("Category:", equipment.category!),
                        if (equipment.weight != null)
                          _buildDetailRow("Weight:", "${equipment.weight} lbs"),
                        if (equipment.cost != null && equipment.costUnit != null)
                          _buildDetailRow(
                            "Cost:",
                            "${equipment.cost} ${equipment.costUnit}",
                          ),
                        const Divider(),
                        if (equipment.description != null) ...[
                          const Text(
                            "Description:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(equipment.description!),
                        ],
                        if (equipment.properties != null &&
                            equipment.properties!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            "Properties:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          ...equipment.properties!
                              .map(
                                (p) => Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    bottom: 4.0,
                                  ),
                                  child: Text("• $p"),
                                ),
                              )
                              .toList(),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Close"),
                    ),
                  ],
                ),
          );
        } else if (context.mounted) {
          // Show error if equipment details not found
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not find details for $equipmentName")),
          );
        }
      });
    } catch (e) {
      // Close loading dialog and show error
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading equipment details: $e")),
        );
      }
    }
  }

  static Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
