import '../models/monster.dart';
import '../services/api_service.dart';
import 'dart:developer';

/// Repository for fetching and managing monster data
class MonsterRepository {
  final ApiService _apiService;
  final bool _useOpen5e;

  MonsterRepository({ApiService? apiService, bool useOpen5e = true})
    : _apiService = apiService ?? ApiService(),
      _useOpen5e = useOpen5e;

  /// Fetch all monsters, optionally filtered by search term or challenge rating
  Future<List<Monster>> getMonsters({
    String? searchQuery,
    String? challengeRating,
  }) async {
    try {
      final monstersData = await _apiService.fetchMonsters(
        searchQuery: searchQuery,
        challengeRating: challengeRating,
      );

      return monstersData.map((monsterData) {
        // Create ability scores map
        Map<String, int>? abilityScores;
        if (monsterData['strength'] != null) {
          // Open5e format
          abilityScores = {
            'str': monsterData['strength'] as int? ?? 10,
            'dex': monsterData['dexterity'] as int? ?? 10,
            'con': monsterData['constitution'] as int? ?? 10,
            'int': monsterData['intelligence'] as int? ?? 10,
            'wis': monsterData['wisdom'] as int? ?? 10,
            'cha': monsterData['charisma'] as int? ?? 10,
          };
        } else if (monsterData['strength_score'] != null) {
          // Alternative format
          abilityScores = {
            'str': monsterData['strength_score'] as int? ?? 10,
            'dex': monsterData['dexterity_score'] as int? ?? 10,
            'con': monsterData['constitution_score'] as int? ?? 10,
            'int': monsterData['intelligence_score'] as int? ?? 10,
            'wis': monsterData['wisdom_score'] as int? ?? 10,
            'cha': monsterData['charisma_score'] as int? ?? 10,
          };
        }

        // Handle speed which could be in different formats
        Map<String, int>? speed;
        if (monsterData['speed'] != null) {
          if (monsterData['speed'] is Map) {
            // DnD 5e API format
            speed = (monsterData['speed'] as Map).map(
              (key, value) => MapEntry(
                key.toString(),
                int.tryParse(
                      value.toString().replaceAll(RegExp(r'[^0-9]'), ''),
                    ) ??
                    0,
              ),
            );
          } else if (monsterData['speed'] is String) {
            // Open5e format with speed as string
            final speedStr = monsterData['speed'].toString();
            speed = {
              'walk':
                  int.tryParse(speedStr.replaceAll(RegExp(r'[^0-9]'), '')) ??
                  30,
            };
          }
        }

        // Handle challenge rating
        String? cr;
        if (monsterData['challenge_rating'] != null) {
          cr = monsterData['challenge_rating'].toString();
        } else if (monsterData['cr'] != null) {
          cr = monsterData['cr'].toString();
        }

        return Monster(
          index: monsterData['slug'] ?? monsterData['index'] ?? '',
          name: monsterData['name'] ?? 'Unknown Monster',
          url: monsterData['url'] ?? '',
          size: monsterData['size'],
          type: monsterData['type'],
          alignment: monsterData['alignment'],
          armorClass:
              monsterData['armor_class'] is int
                  ? monsterData['armor_class']
                  : (monsterData['armor_class'] is List &&
                          monsterData['armor_class'].isNotEmpty
                      ? monsterData['armor_class'][0]['value']
                      : null),
          hitPoints:
              monsterData['hit_points'] is int
                  ? monsterData['hit_points']
                  : int.tryParse(monsterData['hit_points']?.toString() ?? '0'),
          hitDice: monsterData['hit_dice']?.toString(),
          speed: speed,
          abilityScores: abilityScores,
          challengeRating: cr,
          xp:
              monsterData['xp'] is int
                  ? monsterData['xp']
                  : int.tryParse(monsterData['xp']?.toString() ?? '0'),
          actions:
              monsterData['actions'] is List
                  ? List<Map<String, dynamic>>.from(monsterData['actions'])
                  : null,
          description: monsterData['desc'] ?? monsterData['description'],
        );
      }).toList();
    } catch (e) {
      log('Error fetching monsters: $e');
      return [];
    }
  }

  /// Fetch details for a specific monster by index/slug
  Future<Monster> getMonsterDetails(String index) async {
    try {
      // ApiService şimdi hem D&D 5e API hem de Open5e API'yi deneyecek
      final monsterData = await _apiService.fetchMonsterDetails(index);

      // Eğer buraya gelebildiysek, geçerli verimiz var demektir
      log('Successfully fetched monster: ${monsterData['name']}');

      // Yetenek puanları haritası oluştur
      Map<String, int> abilityScores = {
        'str': monsterData['strength'] ?? monsterData['strength_score'] ?? 10,
        'dex': monsterData['dexterity'] ?? monsterData['dexterity_score'] ?? 10,
        'con':
            monsterData['constitution'] ??
            monsterData['constitution_score'] ??
            10,
        'int':
            monsterData['intelligence'] ??
            monsterData['intelligence_score'] ??
            10,
        'wis': monsterData['wisdom'] ?? monsterData['wisdom_score'] ?? 10,
        'cha': monsterData['charisma'] ?? monsterData['charisma_score'] ?? 10,
      };

      // Hız farklı formatlarda olabilir
      Map<String, int> speed = {};
      if (monsterData['speed'] != null) {
        if (monsterData['speed'] is Map) {
          speed = (monsterData['speed'] as Map).map(
            (key, value) => MapEntry(
              key.toString(),
              int.tryParse(
                    value.toString().replaceAll(RegExp(r'[^0-9]'), ''),
                  ) ??
                  0,
            ),
          );
        } else if (monsterData['speed'] is String) {
          final speedStr = monsterData['speed'].toString();
          speed = {
            'walk':
                int.tryParse(speedStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 30,
          };
        }
      }

      return Monster(
        index: monsterData['index'] ?? monsterData['slug'] ?? index,
        name: monsterData['name'] ?? 'Unknown Monster',
        url: monsterData['url'] ?? '',
        size: monsterData['size'],
        type: monsterData['type'],
        alignment: monsterData['alignment'],
        armorClass:
            monsterData['armor_class'] is int
                ? monsterData['armor_class']
                : (monsterData['armor_class'] is List &&
                        monsterData['armor_class'].isNotEmpty
                    ? monsterData['armor_class'][0]['value']
                    : null),
        hitPoints:
            monsterData['hit_points'] is int
                ? monsterData['hit_points']
                : int.tryParse(monsterData['hit_points']?.toString() ?? '0'),
        hitDice: monsterData['hit_dice']?.toString(),
        speed: speed,
        abilityScores: abilityScores,
        challengeRating:
            monsterData['challenge_rating']?.toString() ??
            monsterData['cr']?.toString(),
        xp:
            monsterData['xp'] is int
                ? monsterData['xp']
                : int.tryParse(monsterData['xp']?.toString() ?? '0'),
        actions:
            monsterData['actions'] is List
                ? List<Map<String, dynamic>>.from(monsterData['actions'])
                : null,
        description: monsterData['desc'] ?? monsterData['description'],
      );
    } catch (e) {
      log('Error fetching monster details: $e');

      // Alternatif olarak arama yöntemiyle canavari bulmaya çalışalım
      try {
        log('Direct lookup failed, searching for monster by name: $index');

        // İsimle canavar aramayı deneyelim
        final nameToSearch = index.replaceAll('-', ' ');

        // Arama sorgusuna uyan canavarların listesini alalım
        final monstersData = await _apiService.fetchMonsters(
          searchQuery: nameToSearch,
        );

        if (monstersData.isEmpty) {
          throw Exception('No monsters found with search: $nameToSearch');
        }

        // En alakalı sonucu bulalım
        Map<String, dynamic>? bestMatch;
        for (var monster in monstersData) {
          final monsterName = (monster['name'] ?? '').toString().toLowerCase();
          if (monsterName == nameToSearch.toLowerCase()) {
            // Tam eşleşme, bunu kullanalım
            bestMatch = monster;
            break;
          } else if (monsterName.contains(nameToSearch.toLowerCase())) {
            // Kısmi eşleşme, yedek olarak kullanalım
            bestMatch ??= monster;
          }
        }

        // Eğer bir eşleşme bulduysak kullanalım
        if (bestMatch != null) {
          log('Found matching monster through search: ${bestMatch['name']}');

          // Yetenek puanları haritası oluştur
          Map<String, int> abilityScores = {
            'str': bestMatch['strength'] ?? bestMatch['strength_score'] ?? 10,
            'dex': bestMatch['dexterity'] ?? bestMatch['dexterity_score'] ?? 10,
            'con':
                bestMatch['constitution'] ??
                bestMatch['constitution_score'] ??
                10,
            'int':
                bestMatch['intelligence'] ??
                bestMatch['intelligence_score'] ??
                10,
            'wis': bestMatch['wisdom'] ?? bestMatch['wisdom_score'] ?? 10,
            'cha': bestMatch['charisma'] ?? bestMatch['charisma_score'] ?? 10,
          };

          // Hız
          Map<String, int> speed = {};
          if (bestMatch['speed'] != null) {
            if (bestMatch['speed'] is Map) {
              speed = (bestMatch['speed'] as Map).map(
                (key, value) => MapEntry(
                  key.toString(),
                  int.tryParse(
                        value.toString().replaceAll(RegExp(r'[^0-9]'), ''),
                      ) ??
                      0,
                ),
              );
            } else if (bestMatch['speed'] is String) {
              final speedStr = bestMatch['speed'].toString();
              speed = {
                'walk':
                    int.tryParse(speedStr.replaceAll(RegExp(r'[^0-9]'), '')) ??
                    30,
              };
            }
          }

          // Arama sonucundan canavar oluştur
          return Monster(
            index: bestMatch['index'] ?? bestMatch['slug'] ?? index,
            name: bestMatch['name'] ?? 'Unknown Monster',
            url: bestMatch['url'] ?? '',
            size: bestMatch['size'],
            type: bestMatch['type'],
            alignment: bestMatch['alignment'],
            armorClass:
                bestMatch['armor_class'] is int
                    ? bestMatch['armor_class']
                    : (bestMatch['armor_class'] is List &&
                            bestMatch['armor_class'].isNotEmpty
                        ? bestMatch['armor_class'][0]['value']
                        : null),
            hitPoints:
                bestMatch['hit_points'] is int
                    ? bestMatch['hit_points']
                    : int.tryParse(bestMatch['hit_points']?.toString() ?? '0'),
            hitDice: bestMatch['hit_dice']?.toString(),
            speed: speed,
            abilityScores: abilityScores,
            challengeRating:
                bestMatch['challenge_rating']?.toString() ??
                bestMatch['cr']?.toString(),
            xp:
                bestMatch['xp'] is int
                    ? bestMatch['xp']
                    : int.tryParse(bestMatch['xp']?.toString() ?? '0'),
            actions:
                bestMatch['actions'] is List
                    ? List<Map<String, dynamic>>.from(bestMatch['actions'])
                    : null,
            description: bestMatch['desc'] ?? bestMatch['description'],
          );
        }

        // Eşleşme bulunamadıysa hata fırlatalım
        throw Exception('No matching monster found');
      } catch (searchError) {
        // Hem doğrudan arama hem de sorgulama başarısız oldu
        log('Error searching for monster: $searchError');
        log('All approaches failed for monster: $index');

        // Kullanıcı dostu bir hata canavarı dönelim
        return Monster(
          index: index,
          name: 'Monster Not Found',
          url: '',
          description:
              'Bu canavarın ayrıntıları API kaynaklarından yüklenemedi. '
              'Canavar mevcut olmayabilir veya API servislerinde bir sorun olabilir.\n\n'
              'Hata detayı: $e',
        );
      }
    }
  }

  /// Fetch monster details by name
  Future<Monster> getMonsterDetailsByName(String name) async {
    try {
      // First try to get all monsters with name filter
      final monsters = await getMonsters(searchQuery: name);

      // Find the monster with matching name
      for (var monster in monsters) {
        if (monster.name.toLowerCase() == name.toLowerCase()) {
          // Found a match, get full details
          return getMonsterDetails(monster.index);
        }
      }

      // If not found with exact match, use the first result if available
      if (monsters.isNotEmpty) {
        return getMonsterDetails(monsters.first.index);
      }

      // If no matches, convert name to potential index
      final potentialIndex = name.toLowerCase().replaceAll(' ', '-');
      return getMonsterDetails(potentialIndex);
    } catch (e) {
      log('Error in getMonsterDetailsByName: $e');

      // Return minimal valid monster
      return Monster(
        index: name.toLowerCase().replaceAll(' ', '-'),
        name: name,
        url: '',
        description: 'Could not find details for this monster in the database.',
      );
    }
  }
}
