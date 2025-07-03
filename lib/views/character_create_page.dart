import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../view_models/character_view_model.dart';
import '../view_models/class_view_model.dart';
import '../view_models/race_view_model.dart';

class CharacterCreatePage extends StatefulWidget {
  const CharacterCreatePage({Key? key}) : super(key: key);

  @override
  _CharacterCreatePageState createState() => _CharacterCreatePageState();
}

class _CharacterCreatePageState extends State<CharacterCreatePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  @override
  void initState() {
    super.initState();
    // Initialize data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RaceViewModel>(context, listen: false).loadRaces();
      Provider.of<ClassViewModel>(context, listen: false).loadClasses();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep += 1;
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  Future<void> _saveCharacter() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final formValues = _formKey.currentState!.value;
      final characterViewModel = Provider.of<CharacterViewModel>(
        context,
        listen: false,
      );

      // Update character model with form values
      characterViewModel.updateNewCharacterField('name', formValues['name']);
      characterViewModel.updateNewCharacterField('race', formValues['race']);
      characterViewModel.updateNewCharacterField(
        'characterClass',
        formValues['characterClass'],
      );
      characterViewModel.updateNewCharacterField(
        'level',
        formValues['level']?.toInt() ?? 1,
      );
      characterViewModel.updateNewCharacterField(
        'strength',
        formValues['strength']?.toInt() ?? 10,
      );
      characterViewModel.updateNewCharacterField(
        'dexterity',
        formValues['dexterity']?.toInt() ?? 10,
      );
      characterViewModel.updateNewCharacterField(
        'constitution',
        formValues['constitution']?.toInt() ?? 10,
      );
      characterViewModel.updateNewCharacterField(
        'intelligence',
        formValues['intelligence']?.toInt() ?? 10,
      );
      characterViewModel.updateNewCharacterField(
        'wisdom',
        formValues['wisdom']?.toInt() ?? 10,
      );
      characterViewModel.updateNewCharacterField(
        'charisma',
        formValues['charisma']?.toInt() ?? 10,
      );
      characterViewModel.updateNewCharacterField(
        'background',
        formValues['background'],
      );
      characterViewModel.updateNewCharacterField(
        'alignment',
        formValues['alignment'],
      );

      final success = await characterViewModel.saveNewCharacter();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Character created successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${characterViewModel.errorMessage ?? "Failed to save character"}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Character')),
      body: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            // Stepper indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _totalSteps,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: 12.0,
                    height: 12.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          index == _currentStep
                              ? Colors.blue
                              : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),

            // Form pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildBasicInfoPage(),
                  _buildAbilitiesPage(),
                  _buildBackgroundPage(),
                  _buildReviewPage(),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    ElevatedButton(
                      onPressed: _previousStep,
                      child: const Text('Previous'),
                    )
                  else
                    const SizedBox.shrink(),

                  if (_currentStep < _totalSteps - 1)
                    ElevatedButton(
                      onPressed: _nextStep,
                      child: const Text('Next'),
                    )
                  else
                    ElevatedButton(
                      onPressed: _saveCharacter,
                      child: const Text('Create Character'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          FormBuilderTextField(
            name: 'name',
            decoration: const InputDecoration(
              labelText: 'Character Name',
              border: OutlineInputBorder(),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
            ]),
          ),
          const SizedBox(height: 16),

          Consumer<RaceViewModel>(
            builder: (context, raceViewModel, child) {
              if (raceViewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return FormBuilderDropdown<String>(
                name: 'race',
                decoration: const InputDecoration(
                  labelText: 'Race',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                items:
                    raceViewModel.races
                        .map(
                          (race) => DropdownMenuItem(
                            value: race.name,
                            child: Text(race.name),
                          ),
                        )
                        .toList(),
              );
            },
          ),
          const SizedBox(height: 16),

          Consumer<ClassViewModel>(
            builder: (context, classViewModel, child) {
              if (classViewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return FormBuilderDropdown<String>(
                name: 'characterClass',
                decoration: const InputDecoration(
                  labelText: 'Class',
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                items:
                    classViewModel.classes
                        .map(
                          (dndClass) => DropdownMenuItem(
                            value: dndClass.name,
                            child: Text(dndClass.name),
                          ),
                        )
                        .toList(),
              );
            },
          ),
          const SizedBox(height: 16),

          FormBuilderSlider(
            name: 'level',
            min: 1,
            max: 20,
            initialValue: 1,
            divisions: 19,
            label: 'Level {value}',
            decoration: const InputDecoration(
              labelText: 'Level',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilitiesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ability Scores',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Show explanation
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.blue.shade50,
            child: const Text(
              'Set your ability scores. The standard array is: 15, 14, 13, 12, 10, 8. '
              'You can also roll for stats or use point-buy method.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),

          _buildAbilityScoreField('strength', 'Strength'),
          _buildAbilityScoreField('dexterity', 'Dexterity'),
          _buildAbilityScoreField('constitution', 'Constitution'),
          _buildAbilityScoreField('intelligence', 'Intelligence'),
          _buildAbilityScoreField('wisdom', 'Wisdom'),
          _buildAbilityScoreField('charisma', 'Charisma'),

          const SizedBox(height: 16),

          // Add a "roll for stats" button
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                _rollForStats();
              },
              icon: const Icon(Icons.casino),
              label: const Text('Roll for Stats'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilityScoreField(String name, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FormBuilderSlider(
              name: name,
              min: 3,
              max: 18,
              initialValue: 10,
              divisions: 15,
              label: '{value}',
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Background and Alignment',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          FormBuilderDropdown<String>(
            name: 'background',
            decoration: const InputDecoration(
              labelText: 'Background',
              border: OutlineInputBorder(),
            ),
            items:
                [
                      'Acolyte',
                      'Charlatan',
                      'Criminal',
                      'Entertainer',
                      'Folk Hero',
                      'Guild Artisan',
                      'Hermit',
                      'Noble',
                      'Outlander',
                      'Sage',
                      'Sailor',
                      'Soldier',
                      'Urchin',
                    ]
                    .map(
                      (background) => DropdownMenuItem(
                        value: background,
                        child: Text(background),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 16),

          FormBuilderDropdown<String>(
            name: 'alignment',
            decoration: const InputDecoration(
              labelText: 'Alignment',
              border: OutlineInputBorder(),
            ),
            items:
                [
                      'Lawful Good',
                      'Neutral Good',
                      'Chaotic Good',
                      'Lawful Neutral',
                      'True Neutral',
                      'Chaotic Neutral',
                      'Lawful Evil',
                      'Neutral Evil',
                      'Chaotic Evil',
                    ]
                    .map(
                      (alignment) => DropdownMenuItem(
                        value: alignment,
                        child: Text(alignment),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 16),

          // Character backstory
          FormBuilderTextField(
            name: 'backstory',
            decoration: const InputDecoration(
              labelText: 'Character Backstory (Optional)',
              border: OutlineInputBorder(),
              hintText: 'Write a brief backstory for your character...',
            ),
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewPage() {
    return Consumer<CharacterViewModel>(
      builder: (context, characterViewModel, child) {
        // Make sure we have the latest form values
        if (_formKey.currentState != null) {
          _formKey.currentState!.save();
          final formValues = _formKey.currentState!.value;
          
          // Update character model with form values
          characterViewModel.updateNewCharacterField('name', formValues['name']);
          characterViewModel.updateNewCharacterField('race', formValues['race']);
          characterViewModel.updateNewCharacterField('characterClass', formValues['characterClass']);
          characterViewModel.updateNewCharacterField('level', formValues['level']?.toInt() ?? 1);
          characterViewModel.updateNewCharacterField('strength', formValues['strength']?.toInt() ?? 10);
          characterViewModel.updateNewCharacterField('dexterity', formValues['dexterity']?.toInt() ?? 10);
          characterViewModel.updateNewCharacterField('constitution', formValues['constitution']?.toInt() ?? 10);
          characterViewModel.updateNewCharacterField('intelligence', formValues['intelligence']?.toInt() ?? 10);
          characterViewModel.updateNewCharacterField('wisdom', formValues['wisdom']?.toInt() ?? 10);
          characterViewModel.updateNewCharacterField('charisma', formValues['charisma']?.toInt() ?? 10);
          characterViewModel.updateNewCharacterField('background', formValues['background']);
          characterViewModel.updateNewCharacterField('alignment', formValues['alignment']);
        }
        
        final character = characterViewModel.newCharacter;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Review Character',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
    
              // Character summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name.isNotEmpty ? character.name : 'Unnamed Character',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Race: ${character.race.isNotEmpty ? character.race : 'Not selected'}'),
                      Text(
                        'Class: ${character.characterClass.isNotEmpty ? character.characterClass : 'Not selected'}',
                      ),
                      Text('Level: ${character.level}'),
                      const Divider(),
                      const Text(
                        'Ability Scores:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('STR: ${character.strength}'),
                      Text('DEX: ${character.dexterity}'),
                      Text('CON: ${character.constitution}'),
                      Text('INT: ${character.intelligence}'),
                      Text('WIS: ${character.wisdom}'),
                      Text('CHA: ${character.charisma}'),
                      const Divider(),
                      Text('Background: ${character.background ?? 'None'}'),
                      Text('Alignment: ${character.alignment ?? 'None'}'),
                    ],
                  ),
                ),
              ),
    
              const SizedBox(height: 16),
    
              const Text(
                'Please review your character details. Once you click "Create Character", '
                'your character will be saved and you can edit them later.',
                style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  });
  }
  void _rollForStats() {
    // Simulate rolling 4d6, drop lowest
    final abilities = [
      'strength',
      'dexterity',
      'constitution',
      'intelligence',
      'wisdom',
      'charisma',
    ];
    final random = Random();

    for (final ability in abilities) {
      // Roll 4d6
      final rolls = List.generate(4, (_) => random.nextInt(6) + 1);
      // Drop lowest
      rolls.sort();
      rolls.removeAt(0);
      // Sum remaining 3 dice
      final total = rolls.reduce((a, b) => a + b);

      // Update form
      _formKey.currentState?.fields[ability]?.didChange(total.toDouble());
    }
  }
}
