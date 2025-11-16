import 'package:dio/dio.dart';

import '../models/Department.dart';

class DepartmentService {
  final Dio _dio;

  DepartmentService(this._dio);

  Future<List<Department>> fetchDepartments() async {
    try {
      final response = await _dio.get('/departments');
      return (response.data as List)
          .map((json) => Department.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}