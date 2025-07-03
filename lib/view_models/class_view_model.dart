import 'package:flutter/material.dart';
import '../models/dnd_class.dart';
import '../repositories/class_repository.dart';

/// View model for D&D classes
class ClassViewModel extends ChangeNotifier {
  final ClassRepository _classRepository;

  // List of all classes
  List<DndClass> _classes = [];
  List<DndClass> get classes => _classes;

  // Selected class details
  DndClass? _selectedClass;
  DndClass? get selectedClass => _selectedClass;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ClassViewModel({ClassRepository? classRepository})
    : _classRepository = classRepository ?? ClassRepository();

  /// Load all classes
  Future<void> loadClasses() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _classes = await _classRepository.getClasses();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading classes: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Load details for a specific class
  Future<void> loadClassDetails(String index) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _selectedClass = await _classRepository.getClassDetails(index);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading class details: $e';
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
