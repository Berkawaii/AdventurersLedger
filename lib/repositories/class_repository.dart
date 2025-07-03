import '../models/dnd_class.dart';
import '../services/api_service.dart';

/// Repository for fetching and managing DnD class data
class ClassRepository {
  final ApiService _apiService;

  ClassRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Fetch all available classes
  Future<List<DndClass>> getClasses() async {
    final classesData = await _apiService.fetchClasses();

    return classesData
        .map(
          (classData) => DndClass(
            index: classData['index'],
            name: classData['name'],
            url: classData['url'],
          ),
        )
        .toList();
  }

  /// Fetch details for a specific class
  Future<DndClass> getClassDetails(String index) async {
    final classData = await _apiService.fetchClassDetails(index);

    // Basic class info
    final dndClass = DndClass(
      index: classData['index'],
      name: classData['name'],
      url: classData['url'],
      hitDie: classData['hit_die'],
      proficiencies:
          classData['proficiencies']
              ?.map<String>((prof) => prof['name'] as String)
              .toList(),
      // Add more fields as needed based on the API response
    );

    return dndClass;
  }
}
