import '../models/character.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Repository for managing character data in local storage
class CharacterRepository {
  static const String _charactersBoxName = 'characters';
  late Box<Map> _charactersBox;
  bool _initialized = false;

  // Singleton instance
  static final CharacterRepository _instance = CharacterRepository._internal();

  factory CharacterRepository() {
    return _instance;
  }

  CharacterRepository._internal();

  /// Initialize the repository and Hive boxes
  Future<void> init() async {
    if (_initialized) return;

    // Initialize Hive
    await Hive.initFlutter();

    // Open the characters box
    _charactersBox = await Hive.openBox<Map>(_charactersBoxName);

    _initialized = true;
  }

  /// Get all characters
  Future<List<Character>> getAllCharacters() async {
    if (!_initialized) await init();

    final List<Character> characters = [];

    for (final data in _charactersBox.values) {
      try {
        // Convert the dynamic map to the correct type safely
        final Map<String, dynamic> characterData = {};
        data.forEach((key, value) {
          characterData[key.toString()] = value;
        });

        characters.add(Character.fromJson(characterData));
      } catch (e) {
        print('Error parsing character: $e');
        // Skip invalid characters
      }
    }

    return characters;
  }

  /// Get a character by ID
  Future<Character?> getCharacterById(String id) async {
    if (!_initialized) await init();

    final data = _charactersBox.get(id);
    if (data == null) return null;

    try {
      // Convert the dynamic map to the correct type safely
      final Map<String, dynamic> characterData = {};
      data.forEach((key, value) {
        characterData[key.toString()] = value;
      });

      return Character.fromJson(characterData);
    } catch (e) {
      print('Error parsing character $id: $e');
      return null;
    }
  }

  /// Save a character
  Future<void> saveCharacter(Character character) async {
    if (!_initialized) await init();

    // Make sure we're storing a clean Map<String, dynamic>
    final Map<String, dynamic> jsonData = character.toJson();

    // Sanitize the additionalTraits field to ensure it's a proper Map<String, dynamic>
    if (jsonData['additionalTraits'] != null) {
      final Map<String, dynamic> cleanTraits = {};
      jsonData['additionalTraits'].forEach((key, value) {
        cleanTraits[key.toString()] = value;
      });
      jsonData['additionalTraits'] = cleanTraits;
    }

    await _charactersBox.put(character.id, jsonData);
  }

  /// Delete a character
  Future<void> deleteCharacter(String id) async {
    if (!_initialized) await init();

    await _charactersBox.delete(id);
  }

  /// Get characters that need to be synced
  Future<List<Character>> getCharactersNeedingSync() async {
    if (!_initialized) await init();

    return _charactersBox.values
        .map((data) => Character.fromJson(Map<String, dynamic>.from(data)))
        .where((character) => character.needsSync)
        .toList();
  }

  /// Mark a character as synced
  Future<void> markCharacterSynced(String id) async {
    if (!_initialized) await init();

    final character = await getCharacterById(id);
    if (character == null) return;

    final updatedCharacter = character.copyWith(needsSync: false);
    await saveCharacter(updatedCharacter);
  }
}
