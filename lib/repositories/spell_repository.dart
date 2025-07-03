import '../models/spell.dart';
import '../services/api_service.dart';
import 'dart:developer';

/// Repository for fetching and managing spell data
class SpellRepository {
  final ApiService _apiService;
  final bool _useOpen5e;

  SpellRepository({ApiService? apiService, bool useOpen5e = false})
    : _apiService = apiService ?? ApiService(),
      _useOpen5e = useOpen5e;

  /// Fetch all spells, optionally filtered by search term
  Future<List<Spell>> getSpells({String? searchQuery}) async {
    try {
      final spellsData = await _apiService.fetchSpells(
        searchQuery: searchQuery,
        useOpen5e: _useOpen5e,
      );

      return spellsData
          .map(
            (spellData) => Spell(
              index: spellData['index'] ?? spellData['slug'] ?? '',
              name: spellData['name'],
              url: spellData['url'] ?? '',
              // Other fields would be populated in the getSpellDetails method
            ),
          )
          .toList();
    } catch (e) {
      log('Error fetching spells: $e');
      return [];
    }
  }

  /// Fetch details for a specific spell by index
  Future<Spell> getSpellDetails(String index) async {
    try {
      Map<String, dynamic> spellData;

      if (_useOpen5e) {
        // For Open5e, the spellsData already contains all the details
        final spellsData = await _apiService.fetchSpells(
          searchQuery: index,
          useOpen5e: true,
        );

        if (spellsData.isEmpty) {
          throw Exception('Spell not found in Open5e API');
        }

        // Find the spell by slug/index
        final spell = spellsData.firstWhere(
          (s) =>
              s['slug'] == index ||
              s['name'].toLowerCase() == index.toLowerCase(),
          orElse: () => spellsData.first,
        );

        spellData = Map<String, dynamic>.from(spell);
      } else {
        // For DnD 5e API, we need to fetch the specific spell
        try {
          spellData = await _apiService.fetchFromDnd5eApi('/api/spells/$index');
        } catch (e) {
          log('Error fetching from DnD 5e API: $e');

          // Create a placeholder spell for custom/unfound spells
          final displayName = index
              .replaceAll('-', ' ')
              .split(' ')
              .map(
                (word) =>
                    word.isNotEmpty
                        ? word[0].toUpperCase() + word.substring(1)
                        : '',
              )
              .join(' ');

          return Spell(
            index: index,
            name: displayName,
            url: '/api/spells/$index',
            description:
                'This appears to be a custom spell not found in the DnD 5e database.',
          );
        }
      }

      return Spell(
        index: spellData['index'] ?? spellData['slug'] ?? '',
        name: spellData['name'],
        url: spellData['url'] ?? '',
        level: spellData['level']?.toString(),
        school: spellData['school']?['name'] ?? spellData['school'],
        castingTime: spellData['casting_time'],
        range: spellData['range'],
        components: spellData['components']?.cast<String>(),
        material: spellData['material'],
        duration: spellData['duration'],
        description: _formatDescription(spellData),
        higherLevel: spellData['higher_level']?.join('\n'),
        ritual: spellData['ritual'] ?? false,
        concentration: spellData['concentration'] ?? false,
      );
    } catch (e) {
      log('Error in getSpellDetails: $e');

      // For custom spells or errors, return a minimal valid spell
      final displayName = index
          .replaceAll('-', ' ')
          .split(' ')
          .map(
            (word) =>
                word.isNotEmpty
                    ? word[0].toUpperCase() + word.substring(1)
                    : '',
          )
          .join(' ');

      return Spell(
        index: index,
        name: displayName,
        url: '',
        description:
            'Could not load spell details. This might be a custom spell or there was an error connecting to the database.',
      );
    }
  }

  /// Fetch spell details by name
  Future<Spell> getSpellDetailsByName(String name) async {
    try {
      // First try to get all spells
      final allSpells = await getSpells();

      // Find the spell with matching name
      for (var spell in allSpells) {
        if (spell.name.toLowerCase() == name.toLowerCase()) {
          // Found a match, get full details
          return getSpellDetails(spell.index);
        }
      }

      // If no match found, convert name to potential index
      final potentialIndex = name.toLowerCase().replaceAll(' ', '-');
      return getSpellDetails(potentialIndex);
    } catch (e) {
      log('Error in getSpellDetailsByName: $e');

      // For custom spells or errors, return a minimal valid spell
      return Spell(
        index: name.toLowerCase().replaceAll(' ', '-'),
        name: name,
        url: '',
        description:
            'This appears to be a custom spell. No details are available in the database.',
      );
    }
  }

  // Helper to format description which might be in different formats
  String _formatDescription(Map<String, dynamic> spellData) {
    if (spellData['desc'] != null) {
      return spellData['desc'] is List
          ? (spellData['desc'] as List).join('\n\n')
          : spellData['desc'].toString();
    } else if (spellData['description'] != null) {
      return spellData['description'] is List
          ? (spellData['description'] as List).join('\n\n')
          : spellData['description'].toString();
    }
    return '';
  }
}
