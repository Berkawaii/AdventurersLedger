import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_theme.dart';
import '../models/character.dart';
import '../models/equipment.dart';
import '../view_models/character_view_model.dart';
import '../view_models/equipment_view_model.dart';
import './spell_detail_page.dart';

class CharacterDetailPage extends StatefulWidget {
  final String characterId;

  const CharacterDetailPage({Key? key, required this.characterId})
    : super(key: key);

  @override
  _CharacterDetailPageState createState() => _CharacterDetailPageState();
}

class _CharacterDetailPageState extends State<CharacterDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CharacterViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.selectedCharacter == null ||
            viewModel.selectedCharacter!.id != widget.characterId) {
          viewModel.selectCharacter(widget.characterId);
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final character = viewModel.selectedCharacter!;

        return Scaffold(
          backgroundColor: AppTheme.backgroundDark,
          appBar: AppBar(
            title: Text(character.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _showEditCharacterDialog(context, character);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _confirmDeleteCharacter(context, character);
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Abilities'),
                Tab(text: 'Equipment'),
                Tab(text: 'Spells'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(character),
              _buildAbilitiesTab(character),
              _buildEquipmentTab(character),
              _buildSpellsTab(character),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(Character character) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Character header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: Text(
                      character.name[0],
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          character.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${character.race} ${character.characterClass}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text('Level ${character.level}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Basic stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn('HP', character.hitPoints.toString()),
                  _buildStatColumn('AC', character.armorClass.toString()),
                  _buildStatColumn(
                    'Prof',
                    '+${(character.level / 4).ceil() + 1}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Character details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Character Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Background', character.background ?? 'None'),
                  _buildDetailRow('Alignment', character.alignment ?? 'None'),
                  _buildDetailRow('Created', _formatDate(character.createdAt)),
                  _buildDetailRow(
                    'Last Updated',
                    _formatDate(character.updatedAt),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilitiesTab(Character character) {
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
                      _buildAbilityBlock(
                        'STR',
                        character.strength,
                        character.getAbilityModifier(character.strength),
                      ),
                      _buildAbilityBlock(
                        'DEX',
                        character.dexterity,
                        character.getAbilityModifier(character.dexterity),
                      ),
                      _buildAbilityBlock(
                        'CON',
                        character.constitution,
                        character.getAbilityModifier(character.constitution),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAbilityBlock(
                        'INT',
                        character.intelligence,
                        character.getAbilityModifier(character.intelligence),
                      ),
                      _buildAbilityBlock(
                        'WIS',
                        character.wisdom,
                        character.getAbilityModifier(character.wisdom),
                      ),
                      _buildAbilityBlock(
                        'CHA',
                        character.charisma,
                        character.getAbilityModifier(character.charisma),
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

  Widget _buildEquipmentTab(Character character) {
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
                          leading: const Icon(Icons.inventory),
                          title: Text(character.equipment[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _removeEquipment(
                                character,
                                character.equipment[index],
                              );
                            },
                          ),
                          onTap: () {
                            _showEquipmentDetails(character.equipment[index]);
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
                _showAddEquipmentDialog(character);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Equipment'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpellsTab(Character character) {
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
                              _removeSpell(character, character.spells![index]);
                            },
                          ),
                          onTap: () {
                            _showSpellDetails(character.spells![index]);
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
                _showAddSpellDialog(character);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Spell'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18)),
      ],
    );
  }

  // Method to show equipment details when clicked
  void _showEquipmentDetails(String equipmentName) async {
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
      await equipmentViewModel.loadEquipment();

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
                              (prop) => Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text("• $prop"),
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

  // Method to show spell details when clicked
  void _showSpellDetails(String spellName) {
    // Navigate to spell detail page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SpellDetailPage(spellName: spellName),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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

  Widget _buildAbilityBlock(String label, int score, int modifier) {
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

  void _showEditCharacterDialog(BuildContext context, Character character) {
    // Implement edit dialog
    // This is simplified, for the MVP we could navigate to an edit page instead
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Character'),
            content: const Text(
              'Character editing will be implemented in a future update.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _confirmDeleteCharacter(BuildContext context, Character character) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Character'),
            content: Text(
              'Are you sure you want to delete ${character.name}? This cannot be undone.',
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
                  final viewModel = Provider.of<CharacterViewModel>(
                    context,
                    listen: false,
                  );
                  final success = await viewModel.deleteCharacter(character.id);

                  if (success) {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Return to character list
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  // EQUIPMENT MANAGEMENT METHODS

  void _showAddEquipmentDialog(Character character) {
    final TextEditingController equipmentController = TextEditingController();
    final characterViewModel = Provider.of<CharacterViewModel>(
      context,
      listen: false,
    );
    final equipmentViewModel = EquipmentViewModel();
    bool isManualEntry = true;

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
                                  onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount:
                                        equipmentViewModel.equipment.length,
                                    itemBuilder: (context, index) {
                                      final item =
                                          equipmentViewModel.equipment[index];
                                      final searchTerm =
                                          equipmentController.text
                                              .toLowerCase();
                                      if (searchTerm.isNotEmpty &&
                                          !item.name.toLowerCase().contains(
                                            searchTerm,
                                          )) {
                                        return const SizedBox.shrink();
                                      }

                                      return ListTile(
                                        title: Text(item.name),
                                        onTap: () async {
                                          Navigator.of(context).pop();

                                          final success =
                                              await characterViewModel
                                                  .addEquipmentToCharacter(
                                                    character.id,
                                                    item.name,
                                                  );

                                          if (success && mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Added ${item.name} to inventory',
                                                ),
                                              ),
                                            );
                                          } else if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
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

                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added $equipmentName to inventory'),
                          ),
                        );
                      } else if (mounted) {
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

  void _removeEquipment(Character character, String equipment) {
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

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Removed $equipment from inventory'),
                      ),
                    );
                  } else if (mounted) {
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

  // SPELL MANAGEMENT METHODS

  void _showAddSpellDialog(Character character) {
    final TextEditingController spellController = TextEditingController();
    final viewModel = Provider.of<CharacterViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Spell'),
            content: TextField(
              controller: spellController,
              decoration: const InputDecoration(
                labelText: 'Spell Name',
                hintText: 'e.g., Fireball, Magic Missile, Cure Wounds',
              ),
              autofocus: true,
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
                  final spellName = spellController.text.trim();
                  if (spellName.isEmpty) return;

                  Navigator.of(context).pop();

                  final success = await viewModel.addSpellToCharacter(
                    character.id,
                    spellName,
                  );

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added $spellName to spellbook')),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error adding spell: ${viewModel.errorMessage ?? "Unknown error"}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _removeSpell(Character character, String spell) {
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

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Removed $spell from spellbook')),
                    );
                  } else if (mounted) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
