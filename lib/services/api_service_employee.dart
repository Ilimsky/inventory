import 'package:dio/dio.dart';

import '../models/Employee.dart';

class EmployeeService {
  final Dio _dio;

  EmployeeService(this._dio);

  Future<List<Employee>> fetchEmployees() async {
    try {
      final response = await _dio.get('/employees');
      // debugPrint('Ответ API: ${response.data}');
      return (response.data as List)
          .map((json) => Employee.fromJson(json))
          .toList();
    } catch (e) {
      // debugPrint('Ошибка в fetchEmployees: $e');
      rethrow;
    }
  }
}