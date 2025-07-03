import 'package:flutter/material.dart';
import '../models/character.dart';
import '../repositories/character_repository.dart';
import '../utils/connectivity_service.dart';

/// View model for character management and creation
class CharacterViewModel extends ChangeNotifier {
  final CharacterRepository _characterRepository;
  final ConnectivityService _connectivityService;

  // List of all characters
  List<Character> _characters = [];
  List<Character> get characters => _characters;

  // Currently selected character
  Character? _selectedCharacter;
  Character? get selectedCharacter => _selectedCharacter;

  // Character creation form data
  final Character _newCharacter = Character(
    name: '',
    race: '',
    characterClass: '',
  );
  Character get newCharacter => _newCharacter;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CharacterViewModel({
    CharacterRepository? characterRepository,
    ConnectivityService? connectivityService,
  }) : _characterRepository = characterRepository ?? CharacterRepository(),
       _connectivityService = connectivityService ?? ConnectivityService();

  /// Initialize the view model
  Future<void> init() async {
    _setLoading(true);
    try {
      await _characterRepository.init();
      await loadCharacters();
    } catch (e) {
      _errorMessage = 'Error initializing: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Load all characters
  Future<void> loadCharacters() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _characters = await _characterRepository.getAllCharacters();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading characters: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Select a character
  void selectCharacter(String id) {
    _selectedCharacter = _characters.firstWhere(
      (character) => character.id == id,
    );
    notifyListeners();
  }

  /// Save a new character
  Future<bool> saveNewCharacter() async {
    _setLoading(true);
    _errorMessage = null;

    // Validate character
    if (_newCharacter.name.isEmpty ||
        _newCharacter.race.isEmpty ||
        _newCharacter.characterClass.isEmpty) {
      _errorMessage = 'Name, race, and class are required';
      _setLoading(false);
      return false;
    }

    try {
      // Calculate derived stats
      _newCharacter.calculateDerivedStats();

      // Mark as complete
      _newCharacter.isComplete = true;

      // Make a deep copy to avoid reference issues
      final characterToSave = Character(
        name: _newCharacter.name,
        race: _newCharacter.race,
        characterClass: _newCharacter.characterClass,
        level: _newCharacter.level,
        strength: _newCharacter.strength,
        dexterity: _newCharacter.dexterity,
        constitution: _newCharacter.constitution,
        intelligence: _newCharacter.intelligence,
        wisdom: _newCharacter.wisdom,
        charisma: _newCharacter.charisma,
        hitPoints: _newCharacter.hitPoints,
        armorClass: _newCharacter.armorClass,
        background: _newCharacter.background,
        alignment: _newCharacter.alignment,
        equipment:
            _newCharacter.equipment.isNotEmpty
                ? List<String>.from(_newCharacter.equipment)
                : [],
        spells:
            _newCharacter.spells != null
                ? List<String>.from(_newCharacter.spells!)
                : null,
        additionalTraits: Map<String, dynamic>.from(
          _newCharacter.additionalTraits,
        ),
        isComplete: true,
      );

      // Save to repository
      await _characterRepository.saveCharacter(characterToSave);

      // Add to the characters list
      _characters.add(characterToSave);

      // Try to sync if online
      if (await _connectivityService.isOnline()) {
        // TODO: Implement cloud sync
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error saving character: $e';
      _setLoading(false);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing character
  Future<bool> updateCharacter(Character updatedCharacter) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Mark for sync
      final characterToUpdate = updatedCharacter.copyWith(needsSync: true);

      // Save to repository
      await _characterRepository.saveCharacter(characterToUpdate);

      // Update in the characters list
      final index = _characters.indexWhere((c) => c.id == characterToUpdate.id);
      if (index >= 0) {
        _characters[index] = characterToUpdate;
      }

      // Update selected character if needed
      if (_selectedCharacter?.id == characterToUpdate.id) {
        _selectedCharacter = characterToUpdate;
      }

      // Try to sync if online
      if (await _connectivityService.isOnline()) {
        // TODO: Implement cloud sync
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating character: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a character
  Future<bool> deleteCharacter(String id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Delete from repository
      await _characterRepository.deleteCharacter(id);

      // Remove from the characters list
      _characters.removeWhere((c) => c.id == id);

      // Clear selected character if needed
      if (_selectedCharacter?.id == id) {
        _selectedCharacter = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error deleting character: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Add equipment to a character
  Future<bool> addEquipmentToCharacter(
    String characterId,
    String equipment,
  ) async {
    try {
      final character = _characters.firstWhere((c) => c.id == characterId);

      // Create a new list with the added equipment
      final updatedEquipment = List<String>.from(character.equipment)
        ..add(equipment);

      // Create an updated character
      final updatedCharacter = character.copyWith(equipment: updatedEquipment);

      // Update the character
      return await updateCharacter(updatedCharacter);
    } catch (e) {
      _errorMessage = 'Error adding equipment: $e';
      return false;
    }
  }

  /// Remove equipment from a character
  Future<bool> removeEquipmentFromCharacter(
    String characterId,
    String equipment,
  ) async {
    try {
      final character = _characters.firstWhere((c) => c.id == characterId);

      // Create a new list without the removed equipment
      final updatedEquipment = List<String>.from(character.equipment)
        ..remove(equipment);

      // Create an updated character
      final updatedCharacter = character.copyWith(equipment: updatedEquipment);

      // Update the character
      return await updateCharacter(updatedCharacter);
    } catch (e) {
      _errorMessage = 'Error removing equipment: $e';
      return false;
    }
  }

  /// Add a spell to a character
  Future<bool> addSpellToCharacter(String characterId, String spell) async {
    try {
      final character = _characters.firstWhere((c) => c.id == characterId);

      // Create a new list with the added spell
      List<String> updatedSpells = [];
      if (character.spells != null) {
        updatedSpells = List<String>.from(character.spells!)..add(spell);
      } else {
        updatedSpells = [spell];
      }

      // Create an updated character
      final updatedCharacter = character.copyWith(spells: updatedSpells);

      // Update the character
      return await updateCharacter(updatedCharacter);
    } catch (e) {
      _errorMessage = 'Error adding spell: $e';
      return false;
    }
  }

  /// Remove a spell from a character
  Future<bool> removeSpellFromCharacter(
    String characterId,
    String spell,
  ) async {
    try {
      final character = _characters.firstWhere((c) => c.id == characterId);

      if (character.spells == null) {
        return true; // Nothing to remove
      }

      // Create a new list without the removed spell
      final updatedSpells = List<String>.from(character.spells!)..remove(spell);

      // Create an updated character
      final updatedCharacter = character.copyWith(spells: updatedSpells);

      // Update the character
      return await updateCharacter(updatedCharacter);
    } catch (e) {
      _errorMessage = 'Error removing spell: $e';
      return false;
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Update character creation form data
  void updateNewCharacterField(String field, dynamic value) {
    switch (field) {
      case 'name':
        _newCharacter.name = value;
        break;
      case 'race':
        _newCharacter.race = value;
        break;
      case 'characterClass':
        _newCharacter.characterClass = value;
        break;
      case 'level':
        _newCharacter.level = value;
        break;
      case 'strength':
        _newCharacter.strength = value;
        break;
      case 'dexterity':
        _newCharacter.dexterity = value;
        break;
      case 'constitution':
        _newCharacter.constitution = value;
        break;
      case 'intelligence':
        _newCharacter.intelligence = value;
        break;
      case 'wisdom':
        _newCharacter.wisdom = value;
        break;
      case 'charisma':
        _newCharacter.charisma = value;
        break;
      case 'background':
        _newCharacter.background = value;
        break;
      case 'alignment':
        _newCharacter.alignment = value;
        break;
    }

    notifyListeners();
  }
}
