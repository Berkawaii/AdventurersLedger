import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../repositories/equipment_repository.dart';
import 'dart:developer';

class EquipmentViewModel extends ChangeNotifier {
  final EquipmentRepository _equipmentRepository;

  List<Equipment> _equipment = [];
  Equipment? _selectedEquipment;
  bool _isLoading = false;
  String? _errorMessage;

  List<Equipment> get equipment => _equipment;
  Equipment? get selectedEquipment => _selectedEquipment;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  EquipmentViewModel({EquipmentRepository? equipmentRepository})
    : _equipmentRepository = equipmentRepository ?? EquipmentRepository();

  /// Load all equipment
  Future<void> loadEquipment() async {
    if (_equipment.isNotEmpty) {
      // Don't reload if we already have data
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      _equipment = await _equipmentRepository.getEquipment();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading equipment: $e';
      log(_errorMessage!);
    } finally {
      _setLoading(false);
    }
  }

  /// Load equipment details by index
  Future<void> loadEquipmentDetails(String index) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _selectedEquipment = await _equipmentRepository.getEquipmentDetails(
        index,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading equipment details: $e';
      log(_errorMessage!);

      // Create a basic equipment item with error info so UI doesn't crash
      _selectedEquipment = Equipment(
        index: index,
        name: 'Error: Equipment Not Found',
        url: '',
        description:
            'Could not load details for this equipment. The item might not exist in the D&D 5e API or there was a connection error.',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Load equipment details by name
  Future<void> loadEquipmentDetailsByName(String name) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _selectedEquipment = await _equipmentRepository.getEquipmentDetailsByName(
        name,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading equipment details by name: $e';
      log(_errorMessage!);

      // Create a basic equipment item with error info so UI doesn't crash
      _selectedEquipment = Equipment(
        index: name.toLowerCase().replaceAll(' ', '-'),
        name: name,
        url: '',
        description:
            'Could not load details for this equipment item. It might be custom equipment not found in the D&D 5e database.',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Find equipment by name (case-insensitive)
  Equipment? findEquipmentByName(String name) {
    try {
      for (var item in _equipment) {
        if (item.name.toLowerCase() == name.toLowerCase()) {
          return item;
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
