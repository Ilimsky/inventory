import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../api/ApiService.dart';
import '../models/Department.dart';
import '../models/Sked.dart';
import 'DepartmentProvider.dart';

class SkedProvider extends ChangeNotifier {
  late final DepartmentProvider departmentProvider;

  SkedProvider({required this.departmentProvider});

  List<Sked> _skeds = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _currentDepartmentId;

  // Пагинационные параметры
  int _currentPage = 0;
  int _totalPages = 0;
  int _totalElements = 0;
  int _pageSize = 20;
  String? _currentSort;

  List<Sked> get skeds => _skeds;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int? get currentDepartmentId => _currentDepartmentId;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;

  int get totalElements => _totalElements;

  int get pageSize => _pageSize;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await fetchAllSkedsPaged(page: 0, size: 20);
    _isInitialized = true;
  }

  Future<void> fetchAllSkedsPaged({
    int? page,
    int? size,
    String? sort,
  }) async {
    if (_isLoading) return;

    try {
      _startLoading();
      _currentDepartmentId = null;

      final response = await ApiService().fetchAllSkedsPaged(
        page: page ?? _currentPage,
        size: size ?? _pageSize,
        sort: sort ?? _currentSort,
      );

      _skeds = response.content;
      _totalPages = response.totalPages;
      _totalElements = response.totalElements;
      _currentPage = response.number;
      _pageSize = response.size;
      _currentSort = sort;

      _clearError();
    } catch (e) {
      _handleError('Failed to load all skeds', e);
      _skeds = [];
    } finally {
      _stopLoading();
      notifyListeners(); // переместили сюда
    }
  }

  Future<void> fetchSkedsByDepartmentPaged({
    required int departmentId,
    int? page,
    int? size,
    String? sort,
  }) async {
    if (_isLoading) return;

    try {
      _startLoading();
      _currentDepartmentId = departmentId;

      final response = await ApiService().fetchSkedsByDepartmentPaged(
        departmentId: departmentId,
        page: page ?? _currentPage,
        size: size ?? _pageSize,
        sort: sort ?? _currentSort,
      );

      _skeds = response.content;
      _totalPages = response.totalPages;
      _totalElements = response.totalElements;
      _currentPage = response.number;
      _pageSize = response.size;
      _currentSort = sort;

      _clearError();
      print("DEPT $departmentId | Total: $_totalElements | Page: $_currentPage/$_totalPages");

    } catch (e) {
      _handleError('Failed to load skeds for department $departmentId', e);
    } finally {
      _stopLoading();
      notifyListeners();
    }
  }

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
  }) async {
    try {
      _startLoading();

      final updatedSked = await ApiService().updateSked(
        skedId,
        skedNumber: skedNumber,
        departmentId: departmentId,
        employeeId: employeeId,
        assetCategory: assetCategory,
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
      // Можно добавить fallback данные или логику восстановления
      _skeds = []; // Очищаем список при ошибке
    } finally {
      _stopLoading();
    }
  }

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

  Future<Sked> createSked({
    required int departmentId,
    required int employeeId,
    required String assetCategory,
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
        assetCategory: assetCategory,
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

  Future<Sked> moveSkedToDepartment({
    required int skedId,
    required int newDepartmentId,
    required DateTime newDateReceived,
    required String newPlace,
    required int newEmployeeId,
  }) async {
    try {
      _startLoading();

      final sked = _skeds.firstWhere((s) => s.id == skedId);

      // Проверка на повторное перемещение
      if (sked.comments.contains('Перемещено в')) {
        throw Exception('Это имущество уже было перемещено ранее!');
      }

      final departments = departmentProvider.departments;

      final fromDepartment = departments.firstWhere(
        (d) => d.id == sked.departmentId,
        orElse: () =>
            Department(id: sked.departmentId, name: 'ID ${sked.departmentId}'),
      );

      final toDepartment = departments.firstWhere(
        (d) => d.id == newDepartmentId,
        orElse: () =>
            Department(id: newDepartmentId, name: 'ID $newDepartmentId}'),
      );

      // Создаём новую запись с обновлёнными данными
      final movedSked = await ApiService().createSked(
        departmentId: newDepartmentId,
        employeeId: newEmployeeId,
        // Новый сотрудник
        assetCategory: sked.assetCategory,
        dateReceived: newDateReceived,
        // Новая дата
        itemName: sked.itemName,
        serialNumber: sked.serialNumber,
        count: sked.count,
        measure: sked.measure,
        price: sked.price,
        place: newPlace,
        // Новое местоположение
        comments: 'Перемещено из ${fromDepartment.name}. ${sked.comments}',
      );

      // Обновляем исходную запись
      final updatedSked = await ApiService().updateSked(
        skedId,
        skedNumber: sked.skedNumber,
        departmentId: sked.departmentId,
        employeeId: sked.employeeId,
        assetCategory: sked.assetCategory,
        dateReceived: sked.dateReceived,
        itemName: sked.itemName,
        serialNumber: sked.serialNumber,
        count: sked.count,
        measure: sked.measure,
        price: sked.price,
        place: sked.place,
        comments: 'Перемещено в ${toDepartment.name}. ${sked.comments}',
      );

      // Обновляем локальные данные
      final index = _skeds.indexWhere((s) => s.id == skedId);
      if (index != -1) {
        _skeds[index] = updatedSked;
      }
      _skeds.add(movedSked);

      _clearError();
      notifyListeners();
      return movedSked;
    } catch (e) {
      _handleError('Ошибка перемещения SKED $skedId: $e', e);
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  Future<Sked> writeOffSked({
    required int skedId,
    required String writeOffReason,
  }) async {
    try {
      _startLoading();

      final sked = _skeds.firstWhere((s) => s.id == skedId);

      final updatedSked = await ApiService().updateSked(
        skedId,
        skedNumber: sked.skedNumber,
        departmentId: sked.departmentId,
        employeeId: sked.employeeId,
        assetCategory: sked.assetCategory,
        dateReceived: sked.dateReceived,
        itemName: sked.itemName,
        serialNumber: sked.serialNumber,
        count: sked.count,
        measure: sked.measure,
        price: sked.price,
        place: sked.place,
        comments: 'Списано. Причина: $writeOffReason. ${sked.comments}',
      );

      // Явно устанавливаем isWrittenOff в true
      updatedSked.isWrittenOff = true;

      final index = _skeds.indexWhere((s) => s.id == skedId);
      if (index != -1) {
        _skeds[index] = updatedSked;
      }

      _clearError();
      notifyListeners();
      return updatedSked;
    } catch (e) {
      _handleError('Ошибка списания SKED $skedId: $e', e);
      rethrow;
    } finally {
      _stopLoading();
    }
  }
}
