import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../models/Department.dart';
import '../models/Employee.dart';
import '../models/Binding.dart';
import '../models/Sked.dart';
import '../screens/sked_screen/pagination_response.dart';

class ApiService {
  // final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8060/api'));

  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://inventory-3z06.onrender.com/api'));


  Future<PaginationResponse<Sked>> fetchAllSkedsPaged({
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    try {
      final response = await _dio.get(
        '/skeds/paged',
        queryParameters: {
          'page': page.toString(), // Явное преобразование в строку
          'size': size.toString(),
          if (sort != null) 'sort': sort,
        },
      );
      // print('API Response: ${response.data}');
      // print('Request URL: ${response.requestOptions.uri}');
      if (response.data is Map<String, dynamic>) {
        return PaginationResponse.fromJson(
          response.data as Map<String, dynamic>,
              (json) => Sked.fromJson(json),
        );
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('Error in fetchAllSkedsPaged: $e');
      rethrow;
    }
  }

  Future<PaginationResponse<Sked>> fetchSkedsByDepartmentPaged({
    required int departmentId,
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    try {
      final response = await _dio.get(
        '/skeds/department/$departmentId/paged',
        queryParameters: {
          'page': page,
          'size': size,
          if (sort != null) 'sort': sort,
        },
      );

      return PaginationResponse.fromJson(
        response.data as Map<String, dynamic>,
            (json) => Sked.fromJson(json),
      );
    } catch (e) {
      debugPrint('Error fetching department skeds: $e');
      rethrow;
    }
  }



Future<List<Sked>> fetchAllSkeds() async {
  try {
    final response = await _dio.get(
      '/skeds',
      options: Options(
        validateStatus: (status) => status! < 500,
      ),
    );

    if (response.statusCode == 200) {
      return (response.data as List).map((json) {
        return Sked.fromJson(json);
      }).toList();
    } else {
      throw Exception('Failed to load skeds');
    }
  } catch (e) {
    debugPrint('Error fetching skeds: $e');
    rethrow;
  }
}

Future<List<Sked>> fetchSkedsByDepartment(int departmentId) async {
  try {
    final response = await _dio.get('/skeds/department/$departmentId');
    return (response.data as List)
        .map((json) => Sked.fromJson(json))
        .toList();
  } catch (e) {
    rethrow;
  }
}

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
}) async {
  try {
    final response = await _dio.post(
      '/skeds',
      data: {
        'departmentId': departmentId,
        'employeeId': employeeId,
        'assetCategory': assetCategory,
        'dateReceived': DateFormat('yyyy-MM-dd').format(dateReceived),
        'itemName': itemName,
        'serialNumber': serialNumber,
        'count': count,
        'measure': measure,
        'price': price,
        'place': place,
        'comments': comments,
      },
    );
    return Sked.fromJson(response.data);
  } catch (e) {
    rethrow;
  }
}

Future<Sked> updateSked(int skedId, {
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
}) async {
  try {
    final requestData = {
      'skedNumber': skedNumber,
      'departmentId': departmentId,
      'employeeId': employeeId,
      'assetCategory': assetCategory,
      'dateReceived': DateFormat('yyyy-MM-dd').format(dateReceived),
      'itemName': itemName,
      'serialNumber': serialNumber,
      'count': count,
      'measure': measure,
      'price': price,
      'place': place,
      'comments': comments,
    };

    final response = await _dio.put(
      '/skeds/$skedId',
      data: requestData,
    );

    return Sked.fromJson(response.data);
  } on DioException catch (e) {
    print('[ERROR] Dio error: ${e.message}');
    rethrow;
  }
}


Future<void> deleteSked(int skedId) async {
  try {
    await _dio.delete('/skeds/$skedId');
  } catch (e) {
    rethrow;
  }
}


Future<Department> createDepartment(String name) async {
  try {
    final response = await _dio.post('/departments', data: {'name': name});
    return Department.fromJson(response.data);
  } catch (e) {
    rethrow;
  }
}

Future<void> deleteDepartment(int id) async {
  try {
    await _dio.delete('/departments/$id');
  } catch (e) {
    rethrow;
  }
}

Future<Department> updateDepartment(int id, String newName) async {
  try {
    final response =
    await _dio.put('/departments/$id', data: {'name': newName});
    return Department.fromJson(response.data);
  } catch (e) {
    rethrow;
  }
}

Future<List<Employee>> fetchEmployees() async {
  try {
    final response = await _dio.get('/employees');
    return (response.data as List)
        .map((json) => Employee.fromJson(json))
        .toList();
  } catch (e) {
    rethrow;
  }
}

Future<Employee> createEmployee(String name) async {
  try {
    final response = await _dio.post('/employees', data: {'name': name});
    return Employee.fromJson(response.data);
  } catch (e) {
    rethrow;
  }
}

Future<Employee> updateEmployee(int id, String newName) async {
  try {
    final response =
    await _dio.put('/employees/$id', data: {'name': newName});
    return Employee.fromJson(response.data);
  } catch (e) {
    rethrow;
  }
}

Future<void> deleteEmployee(int id) async {
  try {
    await _dio.delete('/employees/$id');
  } catch (e) {
    rethrow;
  }
}

Future<List<Binding>> fetchBindings() async {
  try {
    final response = await _dio.get('/employee-departments');
    return (response.data as List)
        .map((json) => Binding.fromJson(json))
        .toList();
  } catch (e) {
    rethrow;
  }
}

Future<Binding> createBinding({
  required int employeeId,
  required int departmentId,
}) async {
  try {
    final response = await _dio.post(
      '/employee-departments',
      data: {
        'employee': {'id': employeeId},
        'department': {'id': departmentId},
      },
    );
    print('[DEBUG] createBinding response: ${response.data}');
    return Binding.fromJson(response.data);
  } catch (e) {
    print('[ERROR] Failed to create binding: $e');
    rethrow;
  }
}

Future<Binding> updateBinding(int id, {
  required int employeeId,
  required int departmentId,
}) async {
  try {
    final response = await _dio.put(
      '/employee-departments/$id',
      data: {
        'employee': {'id': employeeId},
        'department': {'id': departmentId},
      },
    );
    print('[DEBUG] updateBinding response: ${response.data}');
    return Binding.fromJson(response.data);
  } catch (e) {
    print('[ERROR] Failed to update binding: $e');
    rethrow;
  }
}

Future<void> deleteBinding(int id) async {
  try {
    await _dio.delete('/employee-departments/$id');
  } catch (e) {
    rethrow;
  }
}}
