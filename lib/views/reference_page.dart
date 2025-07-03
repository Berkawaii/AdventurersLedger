import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/class_view_model.dart';
import '../view_models/race_view_model.dart';
import '../view_models/spell_view_model.dart';
import '../view_models/monster_view_model.dart';
import 'spell_detail_page.dart';
import 'monster_detail_page.dart';

class ReferencePage extends StatefulWidget {
  const ReferencePage({super.key});

  @override
  _ReferencePageState createState() => _ReferencePageState();
}

class _ReferencePageState extends State<ReferencePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClassViewModel>(context, listen: false).loadClasses();
      Provider.of<RaceViewModel>(context, listen: false).loadRaces();
      Provider.of<SpellViewModel>(context, listen: false).loadSpells();
      Provider.of<MonsterViewModel>(context, listen: false).loadMonsters();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    final currentIndex = _tabController.index;

    switch (currentIndex) {
      case 0: // Classes - client side filtering
        // The class view model doesn't support search yet, so we just reload all
        Provider.of<ClassViewModel>(context, listen: false).loadClasses();
        break;
      case 1: // Races - client side filtering
        // The race view model doesn't support search yet, so we just reload all
        Provider.of<RaceViewModel>(context, listen: false).loadRaces();
        break;
      case 2: // Spells - API supports search
        Provider.of<SpellViewModel>(
          context,
          listen: false,
        ).updateSearchQuery(query);
        break;
      case 3: // Monsters - API supports search
        Provider.of<MonsterViewModel>(
          context,
          listen: false,
        ).updateSearchQuery(query);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _performSearch('');
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onSubmitted: _performSearch,
          ),
        ),

        // Tab bar
        TabBar(
          controller: _tabController,
          onTap: (_) {
            // Clear search when changing tabs
            _searchController.clear();
          },
          tabs: const [
            Tab(text: 'Classes'),
            Tab(text: 'Races'),
            Tab(text: 'Spells'),
            Tab(text: 'Monsters'),
          ],
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildClassesTab(),
              _buildRacesTab(),
              _buildSpellsTab(),
              _buildMonstersTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassesTab() {
    return Consumer<ClassViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Error: ${viewModel.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
                ElevatedButton(
                  onPressed: () => viewModel.loadClasses(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Filter classes if search term is provided
        final searchTerm = _searchController.text.toLowerCase();
        final filteredClasses =
            searchTerm.isEmpty
                ? viewModel.classes
                : viewModel.classes
                    .where((c) => c.name.toLowerCase().contains(searchTerm))
                    .toList();

        return ListView.builder(
          itemCount: filteredClasses.length,
          itemBuilder: (context, index) {
            final dndClass = filteredClasses[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 8.0,
              ),
              child: ListTile(
                leading: const Icon(Icons.shield),
                title: Text(dndClass.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  viewModel.loadClassDetails(dndClass.index);
                  _showClassDetailDialog(context, dndClass.name);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRacesTab() {
    return Consumer<RaceViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Error: ${viewModel.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
                ElevatedButton(
                  onPressed: () => viewModel.loadRaces(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Filter races if search term is provided
        final searchTerm = _searchController.text.toLowerCase();
        final filteredRaces =
            searchTerm.isEmpty
                ? viewModel.races
                : viewModel.races
                    .where((r) => r.name.toLowerCase().contains(searchTerm))
                    .toList();

        return ListView.builder(
          itemCount: filteredRaces.length,
          itemBuilder: (context, index) {
            final race = filteredRaces[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 8.0,
              ),
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(race.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  viewModel.loadRaceDetails(race.index);
                  _showRaceDetailDialog(context, race.name);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSpellsTab() {
    return Consumer<SpellViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Error: ${viewModel.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
                ElevatedButton(
                  onPressed: () => viewModel.loadSpells(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: viewModel.spells.length,
          itemBuilder: (context, index) {
            final spell = viewModel.spells[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 8.0,
              ),
              child: ListTile(
                leading: const Icon(Icons.auto_fix_high),
                title: Text(spell.name),
                subtitle: Text(
                  spell.level != null ? 'Level ${spell.level}' : '',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => SpellDetailPage(spellIndex: spell.index),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMonstersTab() {
    return Consumer<MonsterViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Error: ${viewModel.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
                ElevatedButton(
                  onPressed: () => viewModel.loadMonsters(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Add CR filter dropdown
        final crOptions = [
          'All',
          '0',
          '1/8',
          '1/4',
          '1/2',
          '1',
          '2',
          '3',
          '4',
          '5',
          '6',
          '7',
          '8',
          '9',
          '10+',
          '15+',
          '20+',
          '25+',
          '30',
        ];
        final currentCr = viewModel.challengeRatingFilter ?? 'All';

        return Column(
          children: [
            // Challenge Rating filter
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  const Text(
                    'Challenge Rating: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: currentCr,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        viewModel.updateChallengeRatingFilter(
                          newValue == 'All' ? null : newValue,
                        );
                      }
                    },
                    items:
                        crOptions.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),

            // Monster list
            Expanded(
              child: ListView.builder(
                itemCount: viewModel.monsters.length,
                itemBuilder: (context, index) {
                  final monster = viewModel.monsters[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.catching_pokemon),
                      title: Text(monster.name),
                      subtitle: Text(
                        '${monster.size ?? ''} ${monster.type ?? ''} • CR ${monster.challengeRating ?? '?'}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => MonsterDetailPage(
                                  monsterName: monster.name,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClassDetailDialog(BuildContext context, String className) {
    showDialog(
      context: context,
      builder:
          (context) => Consumer<ClassViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading || viewModel.selectedClass == null) {
                return AlertDialog(
                  title: Text(className),
                  content: const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              }

              final classDetails = viewModel.selectedClass!;

              return AlertDialog(
                title: Text(classDetails.name),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (classDetails.hitDie != null)
                        Text('Hit Die: d${classDetails.hitDie}'),
                      const SizedBox(height: 8),

                      if (classDetails.proficiencies != null &&
                          classDetails.proficiencies!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Proficiencies:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            ...classDetails.proficiencies!.map(
                              (prof) => Padding(
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  bottom: 2.0,
                                ),
                                child: Text('• $prof'),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 8),

                      if (classDetails.savingThrows != null &&
                          classDetails.savingThrows!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Saving Throws:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            ...classDetails.savingThrows!.map(
                              (save) => Padding(
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  bottom: 2.0,
                                ),
                                child: Text('• $save'),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showRaceDetailDialog(BuildContext context, String raceName) {
    showDialog(
      context: context,
      builder:
          (context) => Consumer<RaceViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading || viewModel.selectedRace == null) {
                return AlertDialog(
                  title: Text(raceName),
                  content: const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              }

              final raceDetails = viewModel.selectedRace!;

              return AlertDialog(
                title: Text(raceDetails.name),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (raceDetails.size != null)
                        Text('Size: ${raceDetails.size}'),
                      if (raceDetails.speed != null)
                        Text('Speed: ${raceDetails.speed}'),
                      const SizedBox(height: 8),

                      if (raceDetails.abilityBonuses != null &&
                          raceDetails.abilityBonuses!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ability Bonuses:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            ...raceDetails.abilityBonuses!.map((bonus) {
                              final ability =
                                  bonus['ability_score']?['name'] ??
                                  bonus['ability_name'] ??
                                  '';
                              final value =
                                  bonus['bonus'] ?? bonus['value'] ?? '';
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  bottom: 2.0,
                                ),
                                child: Text('• $ability: +$value'),
                              );
                            }),
                          ],
                        ),

                      const SizedBox(height: 8),

                      // Languages section with null safety and type checking
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Languages:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          if (raceDetails.languages == null ||
                              raceDetails.languages!.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(left: 16.0, bottom: 2.0),
                              child: Text('• None specified'),
                            )
                          else
                            ...raceDetails.languages!.map(
                              (lang) => Padding(
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  bottom: 2.0,
                                ),
                                child: Text('• ${lang.toString()}'),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Traits section with null safety and type checking
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Traits:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          if (raceDetails.traits == null ||
                              raceDetails.traits!.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(left: 16.0, bottom: 2.0),
                              child: Text('• None specified'),
                            )
                          else
                            ...raceDetails.traits!.map(
                              (trait) => Padding(
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  bottom: 2.0,
                                ),
                                child: Text('• ${trait.toString()}'),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      if (raceDetails.description != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(raceDetails.description!),
                          ],
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          ),
    );
  }
}
