import '../models/equipment.dart';
import '../services/api_service.dart';
import 'dart:developer';

/// Repository for fetching and managing equipment data
class EquipmentRepository {
  final ApiService _apiService;

  EquipmentRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Fetch all available equipment
  Future<List<Equipment>> getEquipment() async {
    try {
      final equipmentData = await _apiService.fetchEquipment();

      return equipmentData
          .map(
            (data) => Equipment(
              index: data['index'] ?? '',
              name: data['name'] ?? '',
              url: data['url'] ?? '',
            ),
          )
          .toList();
    } catch (e) {
      log('Error fetching equipment: $e');
      return [];
    }
  }

  /// Fetch details for a specific equipment item by index
  Future<Equipment> getEquipmentDetails(String index) async {
    try {
      final data = await _apiService.fetchEquipmentDetails(index);

      // Create equipment from json using the model's fromJson method
      return Equipment.fromJson(data);
    } catch (e) {
      log('Error fetching equipment details: $e');

      // Return minimal equipment object with error indication
      return Equipment(
        index: index,
        name: 'Unknown Equipment',
        url: '',
        description:
            'Could not load equipment details. The item might not exist in the D&D 5e API or there was an error.',
      );
    }
  }

  /// Fetch equipment details by name
  Future<Equipment> getEquipmentDetailsByName(String name) async {
    try {
      // First try to get all equipment to find the index
      final allEquipment = await getEquipment();

      // Find equipment with matching name
      String? matchingIndex;
      for (var equipment in allEquipment) {
        if (equipment.name.toLowerCase() == name.toLowerCase()) {
          matchingIndex = equipment.index;
          break;
        }
      }

      // If found, get details by index
      if (matchingIndex != null) {
        return getEquipmentDetails(matchingIndex);
      }

      // If not found, try using a normalized version of the name as index
      final normalizedIndex = name.toLowerCase().replaceAll(' ', '-');
      return getEquipmentDetails(normalizedIndex);
    } catch (e) {
      log('Error fetching equipment details by name: $e');

      // Return minimal equipment object with error indication
      return Equipment(
        index: name.toLowerCase().replaceAll(' ', '-'),
        name: name,
        url: '',
        description:
            'Could not find details for this equipment item in the D&D 5e database.',
      );
    }
  }
}
