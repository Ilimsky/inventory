import 'package:dio/dio.dart';

import '../models/Binding.dart';

class BindingService {
  final Dio _dio;

  BindingService(this._dio);

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
}