import 'package:flutter/cupertino.dart';

import '../services/api_service.dart';
import '../models/Department.dart';


class DepartmentProvider extends ChangeNotifier {
  final ApiService apiService;
  List<Department> _departments = [];
  bool _isLoading = false;

  List<Department> get departments => _departments;
  bool get isLoading => _isLoading;

  DepartmentProvider(this.apiService) {
    fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    try {
      _isLoading = true;
      notifyListeners();

      _departments = await apiService.fetchDepartments();
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
}