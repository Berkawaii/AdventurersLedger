import 'dart:developer';

import 'package:flutter/material.dart';
import '../models/race.dart';
import '../repositories/race_repository.dart';

/// View model for D&D races
class RaceViewModel extends ChangeNotifier {
  final RaceRepository _raceRepository;

  // List of all races
  List<Race> _races = [];
  List<Race> get races => _races;

  // Selected race details
  Race? _selectedRace;
  Race? get selectedRace => _selectedRace;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  RaceViewModel({RaceRepository? raceRepository})
    : _raceRepository = raceRepository ?? RaceRepository();

  /// Load all races
  Future<void> loadRaces() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _races = await _raceRepository.getRaces();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading races: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Load details for a specific race
  Future<void> loadRaceDetails(String index) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _selectedRace = await _raceRepository.getRaceDetails(index);

      // Validate race data to avoid possible errors
      if (_selectedRace != null) {
        // Ensure languages and traits are never null, but empty lists if missing or invalid types
        _selectedRace = Race(
          index: _selectedRace!.index,
          name: _selectedRace!.name,
          url: _selectedRace!.url,
          size: _selectedRace!.size,
          speed: _selectedRace!.speed,
          abilityBonuses: _selectedRace!.abilityBonuses,
          // Ensure languages is always a properly formatted list
          languages: _selectedRace!.languages ?? [],
          // Ensure traits is always a properly formatted list
          traits: _selectedRace!.traits ?? [],
          description: _selectedRace!.description,
        );
      }

      notifyListeners();
    } catch (e) {
      log('Error in RaceViewModel.loadRaceDetails: $e');
      _errorMessage = 'Error loading race details: $e';

      // Provide a fallback race to avoid UI crashes
      _selectedRace = Race(
        index: index,
        name: 'Unknown Race',
        url: '',
        languages: [],
        traits: [],
      );

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
