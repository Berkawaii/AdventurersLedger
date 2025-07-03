import 'package:flutter/material.dart';
import '../models/monster.dart';
import '../repositories/monster_repository.dart';
import 'dart:developer';

/// View model for D&D monsters
class MonsterViewModel extends ChangeNotifier {
  final MonsterRepository _monsterRepository;

  // List of all monsters
  List<Monster> _monsters = [];
  List<Monster> get monsters => _monsters;

  // Selected monster details
  Monster? _selectedMonster;
  Monster? get selectedMonster => _selectedMonster;

  // Search query
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Challenge rating filter
  String? _challengeRatingFilter;
  String? get challengeRatingFilter => _challengeRatingFilter;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  MonsterViewModel({MonsterRepository? monsterRepository})
    : _monsterRepository = monsterRepository ?? MonsterRepository();

  /// Load all monsters, optionally filtered by search and/or challenge rating
  Future<void> loadMonsters({
    String? searchQuery,
    String? challengeRating,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    if (searchQuery != null) {
      _searchQuery = searchQuery;
    }

    if (challengeRating != null) {
      _challengeRatingFilter = challengeRating;
    }

    try {
      _monsters = await _monsterRepository.getMonsters(
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        challengeRating: _challengeRatingFilter,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading monsters: $e';
      log(_errorMessage!);
    } finally {
      _setLoading(false);
    }
  }

  /// Load details for a specific monster by index
  Future<void> loadMonsterDetails(String index) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _selectedMonster = await _monsterRepository.getMonsterDetails(index);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading monster details: $e';
      log(_errorMessage!);

      // Create a fallback monster object so UI doesn't crash
      _selectedMonster = Monster(
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
        description: 'Could not load monster details due to an error.',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Load monster details by name
  Future<void> loadMonsterDetailsByName(String name) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _selectedMonster = await _monsterRepository.getMonsterDetailsByName(name);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading monster details by name: $e';
      log(_errorMessage!);

      // Create a fallback monster object so UI doesn't crash
      _selectedMonster = Monster(
        index: name.toLowerCase().replaceAll(' ', '-'),
        name: name,
        url: '',
        description:
            'This appears to be a custom monster not found in the database.',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Update search query and reload monsters
  Future<void> updateSearchQuery(String query) async {
    _searchQuery = query;
    notifyListeners();
    await loadMonsters();
  }

  /// Update challenge rating filter and reload monsters
  Future<void> updateChallengeRatingFilter(String? cr) async {
    _challengeRatingFilter = cr;
    notifyListeners();
    await loadMonsters();
  }

  /// Find a monster by name
  Monster? findMonsterByName(String name) {
    try {
      for (var monster in _monsters) {
        if (monster.name.toLowerCase() == name.toLowerCase()) {
          return monster;
        }
      }
      return null;
    } catch (e) {
      log('Error finding monster by name: $e');
      return null;
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
