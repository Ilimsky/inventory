import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/Binding.dart';

class BindingProvider extends ChangeNotifier {
  final ApiService apiService;
  List<Binding> _bindings = [];
  bool _isLoading = false;
  String? _errorMessage;

  BindingProvider(this.apiService);

  List<Binding> get bindings => _bindings;
  bool get isLoading => _isLoading;

  Future<void> fetchBindings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bindings = await apiService.fetchBindings();
    } catch (e) {
      print('[ERROR] Failed to fetch bindings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
