import 'package:flutter/material.dart';
import '../models/spell.dart';
import '../repositories/spell_repository.dart';
import 'dart:developer';

/// View model for D&D spells
class SpellViewModel extends ChangeNotifier {
  final SpellRepository _spellRepository;

  // List of all spells
  List<Spell> _spells = [];
  List<Spell> get spells => _spells;

  // Selected spell details
  Spell? _selectedSpell;
  Spell? get selectedSpell => _selectedSpell;

  // Search query
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  SpellViewModel({SpellRepository? spellRepository})
    : _spellRepository = spellRepository ?? SpellRepository();

  /// Load all spells, optionally filtered by search
  Future<void> loadSpells({String? searchQuery}) async {
    _setLoading(true);
    _errorMessage = null;

    if (searchQuery != null) {
      _searchQuery = searchQuery;
    }

    try {
      _spells = await _spellRepository.getSpells(
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading spells: $e';
      log(_errorMessage!);
    } finally {
      _setLoading(false);
    }
  }

  /// Load details for a specific spell by index
  Future<void> loadSpellDetails(String index) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _selectedSpell = await _spellRepository.getSpellDetails(index);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading spell details: $e';
      log(_errorMessage!);

      // Create a fallback spell object so UI doesn't crash
      _selectedSpell = Spell(
        index: index,
        name: index
            .replaceAll('-', ' ')
            .split(' ')
            .map(
              (word) =>
                  word.isNotEmpty
                      ? word[0].toUpperCase() + word.substring(1)
                      : '',
            )
            .join(' '),
        url: '',
        description: 'Could not load spell details due to an error.',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Load spell details by name
  Future<void> loadSpellDetailsByName(String name) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _selectedSpell = await _spellRepository.getSpellDetailsByName(name);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading spell details by name: $e';
      log(_errorMessage!);

      // Create a fallback spell object so UI doesn't crash
      _selectedSpell = Spell(
        index: name.toLowerCase().replaceAll(' ', '-'),
        name: name,
        url: '',
        description:
            'This appears to be a custom spell not found in the database.',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Update search query and reload spells
  Future<void> updateSearchQuery(String query) async {
    _searchQuery = query;
    notifyListeners();
    await loadSpells();
  }

  /// Find a spell by name
  Spell? findSpellByName(String name) {
    try {
      for (var spell in _spells) {
        if (spell.name.toLowerCase() == name.toLowerCase()) {
          return spell;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
