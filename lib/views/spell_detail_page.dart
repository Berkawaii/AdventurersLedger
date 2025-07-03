import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/spell_view_model.dart';

class SpellDetailPage extends StatefulWidget {
  final String? spellIndex;
  final String? spellName;

  const SpellDetailPage({Key? key, this.spellIndex, this.spellName})
    : assert(
        spellIndex != null || spellName != null,
        'Either spellIndex or spellName must be provided',
      ),
      super(key: key);

  @override
  _SpellDetailPageState createState() => _SpellDetailPageState();
}

class _SpellDetailPageState extends State<SpellDetailPage> {
  bool _searchingByName = false;

  @override
  void initState() {
    super.initState();
    _searchingByName = widget.spellIndex == null && widget.spellName != null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final spellViewModel = Provider.of<SpellViewModel>(
        context,
        listen: false,
      );

      if (_searchingByName) {
        // Search by name
        _searchSpellByName(spellViewModel);
      } else {
        // Load by index
        spellViewModel.loadSpellDetails(widget.spellIndex!);
      }
    });
  }

  Future<void> _searchSpellByName(SpellViewModel viewModel) async {
    try {
      // Load spell details directly by name
      await viewModel.loadSpellDetailsByName(widget.spellName!);

      // If we get here, loading was successful
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching for spell: $e')),
        );
        Navigator.of(context).pop(); // Go back
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<SpellViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.selectedSpell != null) {
              return Text(viewModel.selectedSpell!.name);
            }
            return const Text('Spell Details');
          },
        ),
      ),
      body: Consumer<SpellViewModel>(
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
                    onPressed: () {
                      if (widget.spellIndex != null) {
                        viewModel.loadSpellDetails(widget.spellIndex!);
                      } else if (widget.spellName != null) {
                        _searchSpellByName(viewModel);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.selectedSpell == null) {
            return const Center(child: Text('Spell not found'));
          }

          final spell = viewModel.selectedSpell!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Spell header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spell.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getSpellSubtitle(spell),
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Spell details
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSpellProperty('Casting Time', spell.castingTime),
                        _buildSpellProperty('Range', spell.range),
                        _buildSpellProperty(
                          'Components',
                          spell.components != null
                              ? spell.components!.join(', ')
                              : null,
                        ),
                        if (spell.material != null &&
                            spell.material!.isNotEmpty)
                          _buildSpellProperty('Materials', spell.material),
                        _buildSpellProperty('Duration', spell.duration),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Spell description
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(spell.description ?? 'No description available'),

                        if (spell.higherLevel != null &&
                            spell.higherLevel!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'At Higher Levels',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(spell.higherLevel!),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Classes that can use this spell
                if (spell.classes != null && spell.classes!.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Classes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children:
                                spell.classes!
                                    .map(
                                      (className) => Chip(
                                        label: Text(className),
                                        backgroundColor: Colors.blue.shade100,
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getSpellSubtitle(dynamic spell) {
    String level = spell.level != null ? 'Level ${spell.level}' : '';
    String school = spell.school != null ? spell.school : '';

    if (level.isNotEmpty && school.isNotEmpty) {
      return '$level $school';
    } else if (level.isNotEmpty) {
      return level;
    } else if (school.isNotEmpty) {
      return school;
    } else {
      return 'Spell';
    }
  }

  Widget _buildSpellProperty(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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
