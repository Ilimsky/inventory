import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../models/Department.dart';
import '../models/Employee.dart';
import '../models/Binding.dart';
import '../models/Sked.dart';
import '../models/SkedHistory.dart';
import '../models/User.dart';
import '../models/UserDepartmentBinding.dart';
import '../screens/sked_screen/pagination_response.dart';
import 'api_service_binding.dart';
import 'api_service_department.dart';
import 'api_service_employee.dart';
import 'api_service_sked.dart';
import 'auth_service.dart';

class ApiService {
  final Dio _dio;
  final AuthService _authService;
  final DepartmentService _departmentService;
  final EmployeeService _employeeService;
  final BindingService _bindingService;
  final SkedService _skedService;

  ApiService(this._dio, this._authService)
      : _departmentService = DepartmentService(_dio),
        _employeeService = EmployeeService(_dio),
        _bindingService = BindingService(_dio),
        _skedService = SkedService(_dio);

  Future<List<Department>> fetchDepartments() async {
    return await _departmentService.fetchDepartments();
  }

  Future<List<Employee>> fetchEmployees() async {
    return await _employeeService.fetchEmployees();
  }

  Future<List<Binding>> fetchBindings() async {
    return await _bindingService.fetchBindings();
  }

  Future<Sked> updateSked(
    int skedId, {
    required String skedNumber,
    required int departmentId,
    required int employeeId,
    required String assetCategory,
    required DateTime dateReceived,
    required String itemName,
    required String serialNumber,
    required int count,
    required String measure,
    required double price,
    required String place,
    required String comments,
    required bool available,
  }) =>
      _skedService.updateSked(
        skedId,
        skedNumber: skedNumber,
        departmentId: departmentId,
        employeeId: employeeId,
        assetCategory: assetCategory,
        dateReceived: dateReceived,
        itemName: itemName,
        serialNumber: serialNumber,
        count: count,
        measure: measure,
        price: price,
        place: place,
        comments: comments,
        available: available,
      );

  Future<Sked> createSked({
    required int departmentId,
    required int employeeId,
    required String assetCategory,
    required DateTime dateReceived,
    required String itemName,
    required String serialNumber,
    required int count,
    required String measure,
    required double price,
    required String place,
    required String comments,
    bool available = false,
  }) =>
      _skedService.createSked(
        departmentId: departmentId,
        employeeId: employeeId,
        assetCategory: assetCategory,
        dateReceived: dateReceived,
        itemName: itemName,
        serialNumber: serialNumber,
        count: count,
        measure: measure,
        price: price,
        place: place,
        comments: comments,
        available: available,
      );

  Future<void> deleteSked(int skedId) => _skedService.deleteSked(skedId);

  Future<PaginationResponse<Sked>> fetchAllSkedsPaged({
    int page = 0,
    int size = 20,
    String? sort,
  }) =>
      _skedService.fetchAllSkedsPaged(page: page, size: size, sort: sort);

  Future<PaginationResponse<Sked>> fetchSkedsByDepartmentPaged({
    required int departmentId,
    int page = 0,
    int size = 20,
    String? sort,
  }) =>
      _skedService.fetchSkedsByDepartmentPaged(
        departmentId: departmentId,
        page: page,
        size: size,
        sort: sort,
      );

  Future<List<Sked>> fetchAllSkeds() => _skedService.fetchAllSkeds();

  Future<List<Sked>> fetchSkedsByDepartment(int departmentId) =>
      _skedService.fetchSkedsByDepartment(departmentId);

  Future<void> releaseSkedNumber(int skedId) =>
      _skedService.releaseSkedNumber(skedId);

  Future<void> writeOffSked(int skedId, String reason) =>
      _skedService.writeOffSked(skedId, reason);

  Future<List<SkedHistory>> getSkedHistory(int skedId) =>
      _skedService.getSkedHistory(skedId);

  Future<Sked> transferSked(int skedId, int newDepartmentId, String reason) =>
      _skedService.transferSked(skedId, newDepartmentId, reason);

  Future<List<UserDepartmentBinding>> fetchUserDepartmentBindings() async {
    try {
      final response = await _dio
          .get('/user-departments'); // Убедитесь что это правильный endpoint
      if (response.data is List) {
        final list = (response.data as List)
            .map((e) => UserDepartmentBinding.fromJson(e))
            .toList();
        debugPrint(
            'ApiService: Parsed ${list.length} user-department bindings.');
        return list;
      } else {
        debugPrint('ApiService: Response data is not a List: ${response.data}');
        return [];
      }
    } catch (e) {
      debugPrint('ApiService: fetchUserDepartmentBindings failed: $e');
      rethrow;
    }
  }

  Future<List<User>> fetchUsers() async {
    final response = await _dio.get('/users');
    return (response.data as List).map((e) => User.fromJson(e)).toList();
  }
}
