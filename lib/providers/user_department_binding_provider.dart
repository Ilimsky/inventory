import 'package:flutter/cupertino.dart';

import '../services/api_service.dart';
import '../models/UserDepartmentBinding.dart';

class UserDepartmentBindingProvider extends ChangeNotifier {
  final ApiService apiService;
  List<UserDepartmentBinding> _bindings = [];
  bool _isLoading = false;

  List<UserDepartmentBinding> get bindings => _bindings;
  bool get isLoading => _isLoading;

  UserDepartmentBindingProvider(this.apiService);

  Future<void> fetchBindings() async {
    // print('Fetching bindings');
    _isLoading = true;
    notifyListeners();
    try {
      _bindings = await apiService.fetchUserDepartmentBindings();
      // print('Bindings fetched: ${_bindings.length} bindings');
    } catch (e) {
      // print('[ERROR] Failed to fetch user department bindings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}