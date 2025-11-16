import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../models/User.dart';

class UserProvider extends ChangeNotifier {
  final ApiService apiService;

  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserProvider(this.apiService) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _users = await apiService.fetchUsers();
    } catch (e) {
      _errorMessage = 'Failed to fetch users';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
