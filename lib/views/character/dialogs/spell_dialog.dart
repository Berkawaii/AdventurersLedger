import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../models/character.dart';
import '../../../models/spell.dart';
import '../../../view_models/character_view_model.dart';
import '../../../view_models/spell_view_model.dart';

class SpellDialog {
  static void showAddSpellDialog(BuildContext context, Character character) {
    final TextEditingController spellController = TextEditingController();
    final characterViewModel = Provider.of<CharacterViewModel>(
      context,
      listen: false,
    );
    final spellViewModel = SpellViewModel();
    bool isManualEntry = true;
    Timer? _debounce;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Spell'),
              content:
                  isManualEntry
                      ? SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: spellController,
                              decoration: const InputDecoration(
                                labelText: 'Spell Name',
                                hintText:
                                    'e.g., Fireball, Magic Missile, Cure Wounds',
                              ),
                              autofocus: true,
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isManualEntry = false;
                                  spellViewModel.loadSpells();
                                });
                              },
                              child: const Text('Browse D&D Spells'),
                            ),
                          ],
                        ),
                      )
                      : FutureBuilder(
                        future: spellViewModel.loadSpells(),
                        builder: (context, snapshot) {
                          if (spellViewModel.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (spellViewModel.errorMessage != null) {
                            return Center(
                              child: Text(
                                'Error: ${spellViewModel.errorMessage}',
                              ),
                            );
                          }

                          if (spellViewModel.spells.isEmpty) {
                            return const Center(child: Text('No spells found'));
                          }

                          // Filter spells based on search text
                          final filteredSpells =
                              spellController.text.isEmpty
                                  ? spellViewModel.spells
                                  : spellViewModel.spells
                                      .where(
                                        (spell) =>
                                            spell.name.toLowerCase().contains(
                                              spellController.text.toLowerCase(),
                                            ),
                                      )
                                      .toList();

                          return SizedBox(
                            width: double.maxFinite,
                            height: 300,
                            child: Column(
                              children: [
                                TextField(
                                  controller: spellController,
                                  decoration: const InputDecoration(
                                    labelText: 'Search Spells',
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                  onChanged: (value) {
                                    // Debounce logic: cancel previous timer
                                    if (_debounce?.isActive ?? false) {
                                      _debounce!.cancel();
                                    }

                                    // Set a new timer to update the UI after 500ms of inactivity
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
                                    itemCount: filteredSpells.length,
                                    itemBuilder: (context, index) {
                                      final spell = filteredSpells[index];
                                      return ListTile(
                                        title: Text(spell.name),
                                        subtitle: spell.level != null
                                            ? Text('Level ${spell.level} - ${spell.school ?? ""}')
                                            : null,
                                        onTap: () async {
                                          Navigator.of(context).pop();

                                          final success =
                                              await characterViewModel
                                                  .addSpellToCharacter(
                                            character.id,
                                            spell.name,
                                          );

                                          if (success && context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Added ${spell.name} to spellbook',
                                                ),
                                              ),
                                            );
                                          } else if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error adding spell: ${characterViewModel.errorMessage ?? "Unknown error"}',
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
                                  child: const Text('Enter Manual Spell'),
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
                      final spellName = spellController.text.trim();
                      if (spellName.isEmpty) return;

                      Navigator.of(context).pop();

                      final success = await characterViewModel
                          .addSpellToCharacter(character.id, spellName);

                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added $spellName to spellbook'),
                          ),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error adding spell: ${characterViewModel.errorMessage ?? "Unknown error"}',
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

  static void showRemoveSpellDialog(
      BuildContext context, Character character, String spell) {
    final viewModel = Provider.of<CharacterViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Spell'),
            content: Text(
              'Are you sure you want to remove "$spell" from your spellbook?',
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

                  final success = await viewModel.removeSpellFromCharacter(
                    character.id,
                    spell,
                  );

                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Removed $spell from spellbook')),
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error removing spell: ${viewModel.errorMessage ?? "Unknown error"}',
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

  static void showSpellDetails(BuildContext context, String spellName) {
    // Create a local SpellViewModel instead of using Provider
    final spellViewModel = SpellViewModel();

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
                Text("Loading spell details..."),
              ],
            ),
          ),
    );

    try {
      // Load detailed spell info by name
      spellViewModel.loadSpellDetailsByName(spellName).then((_) {
        // Close loading dialog
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        if (spellViewModel.selectedSpell != null && context.mounted) {
          final spell = spellViewModel.selectedSpell!;

          // Show spell details
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(spell.name),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (spell.level != null)
                          _buildDetailRow("Level:", spell.level!),
                        if (spell.school != null)
                          _buildDetailRow("School:", spell.school!),
                        if (spell.castingTime != null)
                          _buildDetailRow("Casting Time:", spell.castingTime!),
                        if (spell.range != null)
                          _buildDetailRow("Range:", spell.range!),
                        if (spell.duration != null)
                          _buildDetailRow("Duration:", spell.duration!),
                        if (spell.components != null &&
                            spell.components!.isNotEmpty)
                          _buildDetailRow(
                            "Components:",
                            spell.components!.join(", "),
                          ),
                        if (spell.material != null)
                          _buildDetailRow("Materials:", spell.material!),
                        const Divider(),
                        if (spell.description != null) ...[
                          const Text(
                            "Description:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(spell.description!),
                        ],
                        if (spell.higherLevel != null) ...[
                          const SizedBox(height: 8),
                          const Text(
                            "At Higher Levels:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(spell.higherLevel!),
                        ],
                        if (spell.classes != null &&
                            spell.classes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            "Classes:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(spell.classes!.join(", ")),
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
          // Show error if spell details not found
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not find details for $spellName")),
          );
        }
      });
    } catch (e) {
      // Close loading dialog and show error
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading spell details: $e")),
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
