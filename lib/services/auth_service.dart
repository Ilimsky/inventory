import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier {
  final Dio _dio = Dio();
  String? _token;
  String? _username;
  Set<String> _roles = {};

  Dio get dioInstance => _dio;

  bool get isAuthenticated => _token != null;

  String? get username => _username;

  Set<String> get roles => _roles;

  String? get token => _token;

  bool get isSuperAdmin => hasRole('ROLE_SUPERADMIN');
  bool get isAdmin => hasRole('ROLE_ADMIN') || isSuperAdmin;
  bool get isUser => hasRole('ROLE_USER') || isAdmin || isSuperAdmin;
  bool get canEditReports => isAdmin || isSuperAdmin;
  bool get canDeleteReports => isSuperAdmin;

  AuthService() {
    _dio.options.baseUrl = 'http://localhost:8060/api';
    // _dio.options.baseUrl = 'http://10.0.2.2:8060/api';
    // _dio.options.baseUrl = 'http://10.31.51.206:8060/api';
    // _dio.options.baseUrl = 'https://inventory-3z06.onrender.com/api';
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.responseType = ResponseType.json; // Добавляем
    _dio.options.validateStatus = (status) {
      return status! < 500;
    };

    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    addAuthInterceptor();
  }

  Future<void> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'username': username, 'password': password},
      );
      _token = response.data['token'];
      _username = response.data['username'];
      _roles = Set<String>.from(response.data['roles']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('username', _username!);
      await prefs.setStringList('roles', _roles.toList());

      notifyListeners();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Login failed');
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  Future<void> autoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('token');
      final savedUsername = prefs.getString('username');
      final savedRoles = prefs.getStringList('roles');

      if (savedToken != null && savedUsername != null && savedRoles != null) {
        _token = savedToken;
        _username = savedUsername;
        _roles = Set<String>.from(savedRoles);

        try {
          await _dio.get(
            '/validate',
            options: Options(headers: {'Authorization': 'Bearer $_token'}),
          );

          notifyListeners();
        } on DioException {
          await logout();
        }
      } else {
      }
    } catch (e, stackTrace) {
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await _dio.post(
          '/logout',
          options: Options(headers: {'Authorization': 'Bearer $_token'}),
        );
      }
    } catch (e) {
    } finally {
      _token = null;
      _username = null;
      _roles = {};

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('username');
      await prefs.remove('roles');

      notifyListeners();
    }
  }

  bool hasRole(String role) => _roles.contains(role);

  void addAuthInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await logout();
          }
          return handler.next(error);
        },
      ),
    );
  }
}
