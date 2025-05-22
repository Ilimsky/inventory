import 'package:flutter/cupertino.dart';
import '../api/ApiService.dart';
import '../models/Sked.dart';

class SkedProvider extends ChangeNotifier {
  List<Sked> _skeds = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _currentDepartmentId;

  List<Sked> get skeds => _skeds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get currentDepartmentId => _currentDepartmentId;

  Future<void> fetchSkedsByDepartment(int departmentId) async {
    if (_isLoading || _currentDepartmentId == departmentId) return;

    try {
      _startLoading();
      _currentDepartmentId = departmentId;

      final response = await ApiService().fetchSkedsByDepartment(departmentId);
      _skeds = response;
      _clearError();
    } catch (e) {
      _handleError('Failed to load skeds for department $departmentId', e);
    } finally {
      _stopLoading();
    }
  }

  Future<void> fetchAllSkeds() async {
    if (_isLoading) return;

    try {
      _startLoading();
      _currentDepartmentId = null;

      final response = await ApiService().fetchAllSkeds();
      _skeds = response;
      _clearError();
    } catch (e) {
      _handleError('Failed to load all skeds', e);
    } finally {
      _stopLoading();
    }
  }


  Future<Sked> createSked({
    required int departmentId,
    required int employeeId,
    required DateTime dateReceived,
    required String itemName,
    required String serialNumber,
    required int count,
    required String place,
    required String measure,
    required double price,
    required String comments,
  }) async {
    try {
      _startLoading();

      final newSked = await ApiService().createSked(
        departmentId: departmentId,
        employeeId: employeeId,
        dateReceived: dateReceived,
        itemName: itemName,
        serialNumber: serialNumber,
        count: count,
        measure: measure,
        price: price,
        place: place,
        comments: comments,
      );

      _skeds.add(newSked);
      _clearError();
      notifyListeners();

      return newSked;
    } catch (e) {
      _handleError('Failed to create sked', e);
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  Future<Sked> updateSked(
      int skedId, {
        required int skedNumber,
        required int departmentId,
        required int employeeId,
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
      _startLoading();

      final updatedSked = await ApiService().updateSked(
        skedId,
        skedNumber: skedNumber,
        departmentId: departmentId,
        employeeId: employeeId,
        dateReceived: dateReceived,
        itemName: itemName,
        serialNumber: serialNumber,
        count: count,
        measure: measure,
        price: price,
        place: place,
        comments: comments,
      );

      final index = _skeds.indexWhere((sked) => sked.id == skedId);
      if (index != -1) {
        _skeds[index] = updatedSked;
      }
      _clearError();
      notifyListeners();

      return updatedSked;
    } catch (e) {
      _handleError('Failed to update sked $skedId', e);
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  Future<void> deleteSked(int skedId) async {
    try {
      _startLoading();
      await ApiService().deleteSked(skedId);
      _skeds.removeWhere((sked) => sked.id == skedId);
      _clearError();
      notifyListeners();
    } catch (e) {
      _handleError('Failed to delete sked $skedId', e);
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  void clearSkeds() {
    _skeds.clear();
    _currentDepartmentId = null;
    notifyListeners();
  }

  void _startLoading() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _handleError(String message, dynamic error) {
    _errorMessage = message;
    debugPrint('Error: $message, $error');
  }

  void clearError() {
    _skeds = [];
    notifyListeners();
  }
}