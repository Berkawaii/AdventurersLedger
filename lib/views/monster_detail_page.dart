import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/monster.dart';
import '../view_models/monster_view_model.dart';

class MonsterDetailPage extends StatefulWidget {
  final String monsterName;

  const MonsterDetailPage({Key? key, required this.monsterName})
    : super(key: key);

  @override
  State<MonsterDetailPage> createState() => _MonsterDetailPageState();
}

class _MonsterDetailPageState extends State<MonsterDetailPage> {
  @override
  void initState() {
    super.initState();

    // Load monster details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MonsterViewModel>(
        context,
        listen: false,
      ).loadMonsterDetailsByName(widget.monsterName);
    });
  }

  /// Convert ability score to modifier
  String _getAbilityModifier(int? score) {
    if (score == null) return "+0";
    final modifier = (score - 10) ~/ 2;
    return modifier >= 0 ? "+$modifier" : "$modifier";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MonsterViewModel>(
      builder: (context, viewModel, child) {
        final monster = viewModel.selectedMonster;
        final isLoading = viewModel.isLoading;
        final errorMessage = viewModel.errorMessage;

        return Scaffold(
          appBar: AppBar(title: Text(widget.monsterName)),
          body:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? Center(child: Text('Error: $errorMessage'))
                  : monster == null
                  ? const Center(child: Text('Monster not found'))
                  : _buildMonsterDetails(context, monster),
        );
      },
    );
  }

  Widget _buildMonsterDetails(BuildContext context, Monster monster) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Text(
              monster.name,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),

          // Basic info
          Center(
            child: Text(
              '${monster.size ?? ''} ${monster.type ?? ''}, ${monster.alignment ?? 'unaligned'}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(),

          // Stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Armor Class, Hit Points, Speed
                  _buildStatRow(
                    'Armor Class',
                    monster.armorClass?.toString() ?? 'Unknown',
                  ),
                  _buildStatRow(
                    'Hit Points',
                    '${monster.hitPoints ?? 'Unknown'} ${monster.hitDice != null ? '(${monster.hitDice})' : ''}',
                  ),
                  _buildStatRow(
                    'Speed',
                    monster.speed?.entries
                            .map((e) => '${e.key} ${e.value} ft.')
                            .join(', ') ??
                        'Unknown',
                  ),
                  const Divider(),

                  // Ability Scores
                  if (monster.abilityScores != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAbilityScore(
                          'STR',
                          monster.abilityScores!['str'],
                        ),
                        _buildAbilityScore(
                          'DEX',
                          monster.abilityScores!['dex'],
                        ),
                        _buildAbilityScore(
                          'CON',
                          monster.abilityScores!['con'],
                        ),
                        _buildAbilityScore(
                          'INT',
                          monster.abilityScores!['int'],
                        ),
                        _buildAbilityScore(
                          'WIS',
                          monster.abilityScores!['wis'],
                        ),
                        _buildAbilityScore(
                          'CHA',
                          monster.abilityScores!['cha'],
                        ),
                      ],
                    ),
                  const Divider(),

                  // Challenge Rating and XP
                  _buildStatRow(
                    'Challenge Rating',
                    monster.challengeRating?.toString() ?? 'Unknown',
                  ),
                  _buildStatRow('XP', monster.xp?.toString() ?? 'Unknown'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description if available
          if (monster.description != null && monster.description!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(monster.description!),
                const SizedBox(height: 16),
              ],
            ),

          // Actions
          if (monster.actions != null && monster.actions!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Actions', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...monster.actions!.map((action) => _buildActionItem(action)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildAbilityScore(String ability, int? score) {
    return Column(
      children: [
        Text(ability, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('${score ?? '-'} (${_getAbilityModifier(score)})'),
      ],
    );
  }

  Widget _buildActionItem(Map<String, dynamic> action) {
    final name = action['name'] ?? 'Unnamed Action';
    final desc = action['desc'] ?? action['description'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(desc),
          ],
        ),
      ),
    );
  }
}
