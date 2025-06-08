import 'package:flutter/cupertino.dart';

import '../api/ApiService.dart';
import '../models/Department.dart';


class DepartmentProvider extends ChangeNotifier {
  List<Department> _departments = [];
  bool _isLoading = false;

  List<Department> get departments => _departments;
  bool get isLoading => _isLoading;

  DepartmentProvider() {
    fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    try {
      _isLoading = true;
      notifyListeners();

      _departments = await ApiService().fetchDepartments();
    } catch (e) {
      // Handle error appropriately
      debugPrint('Error fetching departments: $e');
      _departments = []; // Reset to empty list on error
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createDepartment(String name) async {
    final newDepartment = await ApiService().createDepartment(name);
    _departments.add(newDepartment);
    notifyListeners();
  }

  Future<void> updateDepartment(int id, String name) async {
    final updatedDepartment = await ApiService().updateDepartment(id, name);
    int index = _departments.indexWhere((dept) => dept.id == id);
    if (index != -1) {
      _departments[index] = updatedDepartment;
      notifyListeners();
    }
  }

  Future<void> deleteDepartment(int id) async {
    await ApiService().deleteDepartment(id);
    _departments.removeWhere((dept) => dept.id == id);
    notifyListeners();
  }
}