import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';

import '../constants/app_theme.dart';
import '../constants/icon_helper.dart';
import '../view_models/character_view_model.dart';
import '../view_models/class_view_model.dart';
import '../view_models/race_view_model.dart';

class CharacterCreatePage extends StatefulWidget {
  const CharacterCreatePage({Key? key}) : super(key: key);

  @override
  _CharacterCreatePageState createState() => _CharacterCreatePageState();
}

class _CharacterCreatePageState extends State<CharacterCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form controllers
  final _nameController = TextEditingController();
  String? _selectedRace;
  String? _selectedClass;
  double _level = 1;

  // Ability scores
  double _strength = 10;
  double _dexterity = 10;
  double _constitution = 10;
  double _intelligence = 10;
  double _wisdom = 10;
  double _charisma = 10;

  // Background and alignment
  String? _selectedBackground;
  String? _selectedAlignment;
  final _backstoryController = TextEditingController();

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
    _nameController.dispose();
    _backstoryController.dispose();
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
    if (_formKey.currentState!.validate()) {
      final characterViewModel = Provider.of<CharacterViewModel>(
        context,
        listen: false,
      );

      // Update character model with form values
      characterViewModel.updateNewCharacterField('name', _nameController.text);
      characterViewModel.updateNewCharacterField('race', _selectedRace);
      characterViewModel.updateNewCharacterField(
        'characterClass',
        _selectedClass,
      );
      characterViewModel.updateNewCharacterField('level', _level.toInt());
      characterViewModel.updateNewCharacterField('strength', _strength.toInt());
      characterViewModel.updateNewCharacterField(
        'dexterity',
        _dexterity.toInt(),
      );
      characterViewModel.updateNewCharacterField(
        'constitution',
        _constitution.toInt(),
      );
      characterViewModel.updateNewCharacterField(
        'intelligence',
        _intelligence.toInt(),
      );
      characterViewModel.updateNewCharacterField('wisdom', _wisdom.toInt());
      characterViewModel.updateNewCharacterField('charisma', _charisma.toInt());
      characterViewModel.updateNewCharacterField(
        'background',
        _selectedBackground,
      );
      characterViewModel.updateNewCharacterField(
        'alignment',
        _selectedAlignment,
      );
      characterViewModel.updateNewCharacterField(
        'backstory',
        _backstoryController.text,
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
      appBar: AppBar(
        title: const Text('Create Character'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.accentColor, AppTheme.backgroundDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundDark,
          image: DecorationImage(
            image: const AssetImage('assets/images/fantasy_background.jpg'),
            fit: BoxFit.cover,
            opacity: 0.2,
            colorFilter: ColorFilter.mode(
              AppTheme.backgroundDark,
              BlendMode.overlay,
            ),
          ),
        ),
        child: Form(
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
                                ? AppTheme.secondaryColor
                                : AppTheme.primaryColor.withOpacity(0.3),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: AppTheme.textLight,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Previous'),
                      )
                    else
                      const SizedBox.shrink(),

                    if (_currentStep < _totalSteps - 1)
                      ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          foregroundColor: AppTheme.textDark,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Next'),
                      )
                    else
                      ElevatedButton(
                        onPressed: _saveCharacter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          foregroundColor: AppTheme.textDark,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Create Character'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.secondaryColor.withOpacity(0.6),
            width: 1.5,
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // Character Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Character Name',
                labelStyle: TextStyle(color: AppTheme.textLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.secondaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.secondaryColor.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.secondaryColor),
                ),
                filled: true,
                fillColor: AppTheme.backgroundDark.withOpacity(0.3),
              ),
              style: TextStyle(color: AppTheme.textLight),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Race Selection
            Consumer<RaceViewModel>(
              builder: (context, raceViewModel, child) {
                if (raceViewModel.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.secondaryColor,
                      ),
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  value: _selectedRace,
                  decoration: InputDecoration(
                    labelText: 'Race',
                    labelStyle: TextStyle(color: AppTheme.textLight),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.secondaryColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.secondaryColor.withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.secondaryColor),
                    ),
                    filled: true,
                    fillColor: AppTheme.backgroundDark.withOpacity(0.3),
                  ),
                  dropdownColor: AppTheme.accentColor,
                  style: TextStyle(color: AppTheme.textLight),
                  validator:
                      (value) => value == null ? 'Please select a race' : null,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRace = newValue;
                    });
                  },
                  items:
                      raceViewModel.races
                          .map<DropdownMenuItem<String>>(
                            (race) => DropdownMenuItem(
                              value: race.name,
                              child: Text(race.name),
                            ),
                          )
                          .toList(),
                );
              },
            ),
            const SizedBox(height: 20),

            // Class Selection
            Consumer<ClassViewModel>(
              builder: (context, classViewModel, child) {
                if (classViewModel.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.secondaryColor,
                      ),
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  value: _selectedClass,
                  decoration: InputDecoration(
                    labelText: 'Class',
                    labelStyle: TextStyle(color: AppTheme.textLight),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.secondaryColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.secondaryColor.withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.secondaryColor),
                    ),
                    filled: true,
                    fillColor: AppTheme.backgroundDark.withOpacity(0.3),
                  ),
                  dropdownColor: AppTheme.accentColor,
                  style: TextStyle(color: AppTheme.textLight),
                  validator:
                      (value) => value == null ? 'Please select a class' : null,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedClass = newValue;
                    });
                  },
                  items:
                      classViewModel.classes
                          .map<DropdownMenuItem<String>>(
                            (dndClass) => DropdownMenuItem(
                              value: dndClass.name,
                              child: Text(dndClass.name),
                            ),
                          )
                          .toList(),
                );
              },
            ),
            const SizedBox(height: 20),

            // Level Slider
            Text(
              'Level: ${_level.toInt()}',
              style: TextStyle(fontSize: 16, color: AppTheme.textLight),
            ),
            Slider(
              value: _level,
              min: 1,
              max: 20,
              divisions: 19,
              activeColor: AppTheme.secondaryColor,
              inactiveColor: AppTheme.primaryColor.withOpacity(0.3),
              label: '${_level.toInt()}',
              onChanged: (value) {
                setState(() {
                  _level = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbilitiesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.secondaryColor.withOpacity(0.6),
            width: 1.5,
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ability Scores',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // Show explanation
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
              ),
              child: Text(
                'Set your ability scores. The standard array is: 15, 14, 13, 12, 10, 8. '
                'You can also roll for stats or use point-buy method.',
                style: TextStyle(fontSize: 14, color: AppTheme.textLight),
              ),
            ),
            const SizedBox(height: 20),

            _buildAbilityScoreSlider('Strength', _strength, (value) {
              setState(() {
                _strength = value;
              });
            }),
            _buildAbilityScoreSlider('Dexterity', _dexterity, (value) {
              setState(() {
                _dexterity = value;
              });
            }),
            _buildAbilityScoreSlider('Constitution', _constitution, (value) {
              setState(() {
                _constitution = value;
              });
            }),
            _buildAbilityScoreSlider('Intelligence', _intelligence, (value) {
              setState(() {
                _intelligence = value;
              });
            }),
            _buildAbilityScoreSlider('Wisdom', _wisdom, (value) {
              setState(() {
                _wisdom = value;
              });
            }),
            _buildAbilityScoreSlider('Charisma', _charisma, (value) {
              setState(() {
                _charisma = value;
              });
            }),

            const SizedBox(height: 24),

            // Add a "roll for stats" button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _rollForStats();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.textLight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppTheme.secondaryColor, width: 1),
                  ),
                ),
                icon: const Icon(Icons.casino),
                label: const Text('Roll for Stats'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbilityScoreSlider(
    String label,
    double value,
    Function(double) onChanged,
  ) {
    final abilityModifier = ((value - 10) / 2).floor();
    final modifierText =
        abilityModifier >= 0 ? '+$abilityModifier' : '$abilityModifier';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.secondaryColor.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '${value.toInt()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    Text(
                      ' ($modifierText)',
                      style: TextStyle(fontSize: 14, color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.secondaryColor,
              inactiveTrackColor: AppTheme.primaryColor.withOpacity(0.3),
              thumbColor: AppTheme.secondaryColor,
              overlayColor: AppTheme.secondaryColor.withOpacity(0.3),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: 3,
              max: 18,
              divisions: 15,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.secondaryColor.withOpacity(0.6),
            width: 1.5,
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Background and Alignment',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _selectedBackground,
              decoration: InputDecoration(
                labelText: 'Background',
                labelStyle: TextStyle(color: AppTheme.textLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.secondaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.secondaryColor.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.secondaryColor),
                ),
                filled: true,
                fillColor: AppTheme.backgroundDark.withOpacity(0.3),
              ),
              dropdownColor: AppTheme.accentColor,
              style: TextStyle(color: AppTheme.textLight),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBackground = newValue;
                });
              },
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
                      .map<DropdownMenuItem<String>>(
                        (background) => DropdownMenuItem(
                          value: background,
                          child: Text(background),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _selectedAlignment,
              decoration: InputDecoration(
                labelText: 'Alignment',
                labelStyle: TextStyle(color: AppTheme.textLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.secondaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.secondaryColor.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.secondaryColor),
                ),
                filled: true,
                fillColor: AppTheme.backgroundDark.withOpacity(0.3),
              ),
              dropdownColor: AppTheme.accentColor,
              style: TextStyle(color: AppTheme.textLight),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedAlignment = newValue;
                });
              },
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
                      .map<DropdownMenuItem<String>>(
                        (alignment) => DropdownMenuItem(
                          value: alignment,
                          child: Text(alignment),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 20),

            // Character backstory
            TextFormField(
              controller: _backstoryController,
              decoration: InputDecoration(
                labelText: 'Character Backstory (Optional)',
                labelStyle: TextStyle(color: AppTheme.textLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.secondaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.secondaryColor.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.secondaryColor),
                ),
                filled: true,
                fillColor: AppTheme.backgroundDark.withOpacity(0.3),
                hintText: 'Write a brief backstory for your character...',
                hintStyle: TextStyle(
                  color: AppTheme.textLight.withOpacity(0.6),
                ),
              ),
              style: TextStyle(color: AppTheme.textLight),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewPage() {
    // Update character model with form values only when page is active
    if (_currentStep == 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final characterViewModel = Provider.of<CharacterViewModel>(
          context,
          listen: false,
        );
        characterViewModel.updateNewCharacterField(
          'name',
          _nameController.text,
        );
        characterViewModel.updateNewCharacterField('race', _selectedRace);
        characterViewModel.updateNewCharacterField(
          'characterClass',
          _selectedClass,
        );
        characterViewModel.updateNewCharacterField('level', _level.toInt());
        characterViewModel.updateNewCharacterField(
          'strength',
          _strength.toInt(),
        );
        characterViewModel.updateNewCharacterField(
          'dexterity',
          _dexterity.toInt(),
        );
        characterViewModel.updateNewCharacterField(
          'constitution',
          _constitution.toInt(),
        );
        characterViewModel.updateNewCharacterField(
          'intelligence',
          _intelligence.toInt(),
        );
        characterViewModel.updateNewCharacterField('wisdom', _wisdom.toInt());
        characterViewModel.updateNewCharacterField(
          'charisma',
          _charisma.toInt(),
        );
        characterViewModel.updateNewCharacterField(
          'background',
          _selectedBackground,
        );
        characterViewModel.updateNewCharacterField(
          'alignment',
          _selectedAlignment,
        );
        characterViewModel.updateNewCharacterField(
          'backstory',
          _backstoryController.text,
        );
      });
    }

    return Consumer<CharacterViewModel>(
      builder: (context, characterViewModel, child) {
        final character = characterViewModel.newCharacter;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.secondaryColor.withOpacity(0.6),
                width: 1.5,
              ),
              boxShadow: AppTheme.cardShadow,
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review Character',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Character summary
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDark.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.primaryColor,
                            radius: 24,
                            child: IconHelper.getClassIcon(
                              character.characterClass,
                              size: IconHelper.sizeMedium,
                              color: AppTheme.textLight,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  character.name.isNotEmpty
                                      ? character.name
                                      : 'Unnamed Character',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.secondaryColor,
                                  ),
                                ),
                                Text(
                                  '${character.race.isNotEmpty ? character.race : 'Unknown Race'} ${character.characterClass.isNotEmpty ? character.characterClass : 'Unknown Class'}',
                                  style: TextStyle(
                                    color: AppTheme.textLight,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Level ${character.level}',
                                  style: TextStyle(
                                    color: AppTheme.secondaryColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        color: AppTheme.primaryColor.withOpacity(0.5),
                        height: 30,
                      ),

                      // Ability Scores
                      Text(
                        'Ability Scores:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAbilityScoreBadge('STR', character.strength),
                          _buildAbilityScoreBadge('DEX', character.dexterity),
                          _buildAbilityScoreBadge(
                            'CON',
                            character.constitution,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAbilityScoreBadge(
                            'INT',
                            character.intelligence,
                          ),
                          _buildAbilityScoreBadge('WIS', character.wisdom),
                          _buildAbilityScoreBadge('CHA', character.charisma),
                        ],
                      ),

                      Divider(
                        color: AppTheme.primaryColor.withOpacity(0.5),
                        height: 30,
                      ),

                      // Background & Alignment
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Background:',
                                style: TextStyle(color: AppTheme.textLight),
                              ),
                              Text(
                                character.background ?? 'None',
                                style: TextStyle(
                                  color: AppTheme.secondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Alignment:',
                                style: TextStyle(color: AppTheme.textLight),
                              ),
                              Text(
                                character.alignment ?? 'None',
                                style: TextStyle(
                                  color: AppTheme.secondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Backstory Section
                const SizedBox(height: 20),

                if (_backstoryController.text.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundDark.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.secondaryColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Character Backstory:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _backstoryController.text,
                          style: TextStyle(
                            color: AppTheme.textLight,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    'Please review your character details. Once you click "Create Character", '
                    'your character will be saved and you can edit them later.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAbilityScoreBadge(String abbr, int value) {
    final modifier = ((value - 10) / 2).floor();
    final modString = modifier >= 0 ? '+$modifier' : '$modifier';

    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            abbr,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.textLight,
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryColor,
            ),
          ),
          Text(
            modString,
            style: TextStyle(fontSize: 12, color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }

  void _rollForStats() {
    // Simulate rolling 4d6, drop lowest
    final abilities = {
      'strength': (double value) => _strength = value,
      'dexterity': (double value) => _dexterity = value,
      'constitution': (double value) => _constitution = value,
      'intelligence': (double value) => _intelligence = value,
      'wisdom': (double value) => _wisdom = value,
      'charisma': (double value) => _charisma = value,
    };
    final random = Random();

    setState(() {
      abilities.forEach((ability, setter) {
        // Roll 4d6
        final rolls = List.generate(4, (_) => random.nextInt(6) + 1);
        // Drop lowest
        rolls.sort();
        rolls.removeAt(0);
        // Sum remaining 3 dice
        final total = rolls.reduce((a, b) => a + b);

        // Update state
        setter(total.toDouble());
      });
    });
  }
}
