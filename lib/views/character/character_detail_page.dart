import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../models/character.dart';
import '../../view_models/character_view_model.dart';
import 'tabs/overview_tab.dart';
import 'tabs/abilities_tab.dart';
import 'tabs/equipment_tab.dart';
import 'tabs/spells_tab.dart';

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
              OverviewTab(
                character: character, 
                updateHP: _updateHP,
                updateInspiration: _updateInspiration,
                formatDate: _formatDate,
              ),
              AbilitiesTab(character: character),
              EquipmentTab(character: character),
              SpellsTab(character: character),
            ],
          ),
        );
      },
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

  // Update character's HP
  void _updateHP(BuildContext context, String characterId, int amount) async {
    final viewModel = Provider.of<CharacterViewModel>(context, listen: false);
    await viewModel.updateCharacterHP(characterId, amount);
  }

  // Update character's inspiration
  void _updateInspiration(
    BuildContext context,
    String characterId,
    int newValue,
  ) async {
    final viewModel = Provider.of<CharacterViewModel>(context, listen: false);
    final character = viewModel.selectedCharacter;

    if (character != null) {
      // Calculate the difference to reach the new value
      int diff = newValue - character.inspiration;
      await viewModel.updateCharacterInspiration(characterId, diff);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
