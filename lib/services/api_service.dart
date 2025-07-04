// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

/// Main API service for handling requests to D&D 5e API and Open5e API
class ApiService {
  static const String dnd5eBaseUrl = 'https://www.dnd5eapi.co';
  static const String open5eBaseUrl = 'https://api.open5e.com';

  final http.Client _httpClient;
  final Dio _dio;

  ApiService({http.Client? httpClient, Dio? dio})
    : _httpClient = httpClient ?? http.Client(),
      _dio = dio ?? Dio();

  // Generic method to fetch data from D&D 5e API
  Future<Map<String, dynamic>> fetchFromDnd5eApi(String endpoint) async {
    final response = await _httpClient.get(Uri.parse('$dnd5eBaseUrl$endpoint'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to load data from D&D 5e API: ${response.statusCode}',
      );
    }
  }

  // Generic method to fetch data from Open5e API
  Future<Map<String, dynamic>> fetchFromOpen5eApi(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    String url = '$open5eBaseUrl$endpoint';

    if (queryParams != null && queryParams.isNotEmpty) {
      final queryString =
          Uri(
            queryParameters: queryParams.map(
              (key, value) => MapEntry(key, value.toString()),
            ),
          ).query;
      url = '$url?$queryString';
    }

    final response = await _httpClient.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to load data from Open5e API: ${response.statusCode}',
      );
    }
  }

  // Fetch all classes from D&D 5e API
  Future<List<dynamic>> fetchClasses() async {
    final data = await fetchFromDnd5eApi('/api/classes');
    return data['results'];
  }

  // Fetch specific class details
  Future<Map<String, dynamic>> fetchClassDetails(String index) async {
    return fetchFromDnd5eApi('/api/classes/$index');
  }

  // Fetch all races from D&D 5e API or Open5e API
  Future<List<dynamic>> fetchRaces({bool useOpen5e = true}) async {
    if (useOpen5e) {
      final data = await fetchFromOpen5eApi('/races');
      return data['results'];
    } else {
      final data = await fetchFromDnd5eApi('/api/races');
      return data['results'];
    }
  }

  // Fetch specific race details
  Future<Map<String, dynamic>> fetchRaceDetails(
    String index, {
    bool useOpen5e = true,
  }) async {
    try {
      if (useOpen5e) {
        final data = await fetchFromOpen5eApi('/races/$index');
        // Add logging here if needed
        return data;
      } else {
        final data = await fetchFromDnd5eApi('/api/races/$index');
        // Add logging here if needed
        return data;
      }
    } catch (e) {
      log('Error fetching race details for index $index: $e');
      // Return a minimal valid race object to avoid crashes
      return {
        'name': 'Unknown Race',
        'index': index,
        'languages': <String>[],
        'traits': <String>[],
      };
    }
  }

  // Fetch all spells with optional search parameter
  Future<List<dynamic>> fetchSpells({
    String? searchQuery,
    bool useOpen5e = false,
  }) async {
    if (useOpen5e) {
      final queryParams = searchQuery != null ? {'search': searchQuery} : null;
      final data = await fetchFromOpen5eApi(
        '/spells',
        queryParams: queryParams,
      );
      return data['results'];
    } else {
      final data = await fetchFromDnd5eApi('/api/spells');
      final results = data['results'] as List;

      if (searchQuery != null) {
        // Client-side filtering for D&D 5e API since it doesn't support search
        return results
            .where(
              (spell) => spell['name'].toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
            )
            .toList();
      }

      return results;
    }
  }

  // Fetch all equipment
  Future<List<dynamic>> fetchEquipment() async {
    final data = await fetchFromDnd5eApi('/api/equipment');
    return data['results'];
  }

  // Fetch specific equipment details
  Future<Map<String, dynamic>> fetchEquipmentDetails(String index) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$dnd5eBaseUrl/api/equipment/$index'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        log('Equipment not found: $index');

        // Try fetching from /api/magic-items/ if not found in equipment
        try {
          final magicResponse = await _httpClient.get(
            Uri.parse('$dnd5eBaseUrl/api/magic-items/$index'),
          );

          if (magicResponse.statusCode == 200) {
            final data = json.decode(magicResponse.body);
            // Add equipment_category if not present
            if (!data.containsKey('equipment_category')) {
              data['equipment_category'] = {'name': 'Magic Item'};
            }
            return data;
          }
        } catch (innerError) {
          log('Also failed to find as magic item: $innerError');
        }

        // Return minimal valid equipment object
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

        return {
          'index': index,
          'name': displayName,
          'url': '/api/equipment/$index',
          'equipment_category': {'name': 'Custom'},
          'description': 'This equipment item was not found in the D&D 5e API.',
        };
      } else {
        throw Exception(
          'Failed to load equipment details: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      log('Error fetching equipment details: $e');
      // Return minimal valid equipment object in case of error
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

      return {
        'index': index,
        'name': displayName,
        'url': '/api/equipment/$index',
        'equipment_category': {'name': 'Unknown'},
        'description':
            'Could not load equipment details. Please check your connection and try again.',
      };
    }
  }

  // Fetch all monsters with optional filters
  Future<List<dynamic>> fetchMonsters({
    String? searchQuery,
    String? challengeRating,
  }) async {
    final queryParams = <String, dynamic>{};

    if (searchQuery != null) {
      queryParams['search'] = searchQuery;
    }

    if (challengeRating != null) {
      queryParams['cr'] = challengeRating;
    }

    final data = await fetchFromOpen5eApi(
      '/monsters',
      queryParams: queryParams,
    );
    return data['results'];
  }

  // Fetch specific monster details
  Future<Map<String, dynamic>> fetchMonsterDetails(String index) async {
    try {
      // First try D&D 5e API
      log('Fetching monster details from D&D 5e API: $index');
      return await fetchFromDnd5eApi('/api/monsters/$index');
    } catch (e) {
      // If D&D 5e API fails, try Open5e API
      log('D&D 5e API failed for monster: $index. Trying Open5e API...');
      try {
        final data = await fetchFromOpen5eApi('/monsters/$index');
        log('Successfully fetched monster from Open5e API: ${data['name']}');
        return data;
      } catch (open5eError) {
        // If both APIs fail, rethrow the original error
        log('Open5e API also failed for monster: $index');
        throw Exception('Monster not found in either API source: $e');
      }
    }
  }

  // Fetch backgrounds from Open5e
  Future<List<dynamic>> fetchBackgrounds({String? searchQuery}) async {
    final queryParams = searchQuery != null ? {'search': searchQuery} : null;
    final data = await fetchFromOpen5eApi(
      '/backgrounds',
      queryParams: queryParams,
    );
    return data['results'];
  }

  // Fetch skills from Open5e
  Future<List<dynamic>> fetchSkills() async {
    final data = await fetchFromOpen5eApi('/skills');
    return data['results'];
  }

  // Fetch feats from Open5e
  Future<List<dynamic>> fetchFeats({String? searchQuery}) async {
    final queryParams = searchQuery != null ? {'search': searchQuery} : null;
    final data = await fetchFromOpen5eApi('/feats', queryParams: queryParams);
    return data['results'];
  }

  // Dispose of the HTTP client when the service is no longer needed
  void dispose() {
    _httpClient.close();
  }
}
