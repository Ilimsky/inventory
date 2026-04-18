// api_service_sked.dart

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../models/Sked.dart';
import '../models/SkedHistory.dart';
import '../screens/sked_screen/pagination_response.dart';

class SkedService {
  final Dio _dio;

  SkedService(this._dio);

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
        'available': available,
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
          'available': available,
        },
      );
      return Sked.fromJson(response.data);
    } catch (e) {
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
      if (response.statusCode != 200) {
        throw Exception('Error: ${response.statusCode} - ${response.data}');
      }
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

  Future<void> releaseSkedNumber(int skedId) async {
    try {
      await _dio.post('/skeds/$skedId/release-number');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> writeOffSked(int skedId, String reason) async {
    try {
      await _dio.post(
        '/skeds/$skedId/write-off',
        data: {'reason': reason},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SkedHistory>> getSkedHistory(int skedId) async {
    try {
      final response = await _dio.get('/skeds/$skedId/history');
      return (response.data as List)
          .map((json) => SkedHistory.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Sked> transferSked(int skedId, int newDepartmentId, String reason) async {
    try {
      final response = await _dio.post(
        '/skeds/$skedId/transfer',
        data: {
          'newDepartmentId': newDepartmentId,
          'reason': reason,
        },
      );
      return Sked.fromJson(response.data);
    } on DioException catch (e) {
      print('[ERROR] Dio error: ${e.message}');
      rethrow;
    }
  }
}