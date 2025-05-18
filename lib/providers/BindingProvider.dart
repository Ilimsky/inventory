import 'package:flutter/material.dart';
import '../api/ApiService.dart';
import '../models/Binding.dart';

class BindingProvider extends ChangeNotifier {
  List<Binding> _bindings = [];
  bool _isLoading = false;

  List<Binding> get bindings => _bindings;
  bool get isLoading => _isLoading;

  // Загрузка привязок сотрудников
  Future<void> fetchBindings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bindings = await ApiService().fetchBindings();
    } catch (e) {
      print('[ERROR] Failed to fetch bindings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // Создание привязки сотрудника к филиалу и должности
  // В BindingProvider
  Future<void> createBinding({
    required int employeeId,
    required int departmentId,
    required int jobId,  // Добавлен параметр jobId
  }) async {
    try {
      final newBinding = await ApiService().createBinding(
        employeeId: employeeId,
        departmentId: departmentId,
        jobId: jobId,  // Передаем jobId
      );
      _bindings.add(newBinding);
      notifyListeners();
    } catch (e) {
      print('[ERROR] Failed to create binding: $e');
    }
  }

  Future<void> updateBinding(
      int id, {
        required int employeeId,
        required int departmentId,
        required int jobId,  // Добавлен параметр jobId
      }) async {
    try {
      final updated = await ApiService().updateBinding(
        id,
        employeeId: employeeId,
        departmentId: departmentId,
        jobId: jobId,  // Передаем jobId
      );
      final index = _bindings.indexWhere((a) => a.id == id);
      if (index != -1) {
        _bindings[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      print('[ERROR] Failed to update binding: $e');
    }
  }



  // Удаление привязки сотрудника
  Future<void> deleteBinding(int id) async {
    try {
      await ApiService().deleteBinding(id);
      _bindings.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      print('[ERROR] Failed to delete binding: $e');
    }
  }
}
