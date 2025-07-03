import '../models/race.dart';
import '../services/api_service.dart';

/// Repository for fetching and managing race data
class RaceRepository {
  final ApiService _apiService;
  final bool _useOpen5e;

  RaceRepository({ApiService? apiService, bool useOpen5e = true})
    : _apiService = apiService ?? ApiService(),
      _useOpen5e = useOpen5e;

  /// Fetch all available races
  Future<List<Race>> getRaces() async {
    final racesData = await _apiService.fetchRaces(useOpen5e: _useOpen5e);

    return racesData
        .map(
          (raceData) => Race(
            index: raceData['index'] ?? raceData['slug'] ?? '',
            name: raceData['name'],
            url: raceData['url'] ?? '',
          ),
        )
        .toList();
  }

  /// Fetch details for a specific race
  Future<Race> getRaceDetails(String index) async {
    final raceData = await _apiService.fetchRaceDetails(
      index,
      useOpen5e: _useOpen5e,
    );

    // Try to extract ability bonuses if available
    List<Map<String, dynamic>>? abilityBonuses;
    if (raceData['ability_bonuses'] != null) {
      abilityBonuses =
          (raceData['ability_bonuses'] as List)
              .map((bonus) => Map<String, dynamic>.from(bonus as Map))
              .toList();
    }

    // Process languages safely
    List<String> languages = [];
    if (raceData['languages'] != null) {
      if (raceData['languages'] is List) {
        languages =
            (raceData['languages'] as List).map<String>((lang) {
              if (lang is Map) {
                return lang['name']?.toString() ?? '';
              } else {
                return lang?.toString() ?? '';
              }
            }).toList();
      } else if (raceData['languages'] is String) {
        // Handle case where languages is a single string
        languages = [raceData['languages'] as String];
      } else {
        // Fallback for unexpected types
        languages = ['Unknown languages format'];
      }
    }

    // Process traits safely
    List<String> traits = [];
    if (raceData['traits'] != null) {
      if (raceData['traits'] is List) {
        traits =
            (raceData['traits'] as List).map<String>((trait) {
              if (trait is Map) {
                return trait['name']?.toString() ?? '';
              } else {
                return trait?.toString() ?? '';
              }
            }).toList();
      } else if (raceData['traits'] is String) {
        // Handle case where traits is a single string
        traits = [raceData['traits'] as String];
      } else {
        // Fallback for unexpected types
        traits = ['Unknown traits format'];
      }
    }

    // Basic race info
    final race = Race(
      index: raceData['index'] ?? raceData['slug'] ?? '',
      name: raceData['name'],
      url: raceData['url'] ?? '',
      size: raceData['size']?.toString(),
      speed: raceData['speed']?.toString(),
      abilityBonuses: abilityBonuses,
      languages: languages,
      traits: traits,
      description: raceData['desc']?.toString(),
    );

    return race;
  }
}
