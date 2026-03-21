import 'package:flutter/cupertino.dart';
import '../services/api_service.dart';
import '../models/Employee.dart';

class EmployeeProvider extends ChangeNotifier {
  final ApiService apiService;
  List<Employee> _employees = [];
  bool _isLoading = false;
  String? _error;

  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  EmployeeProvider(this.apiService) {
    // debugPrint('[EmployeeProvider] Инициализация провайдера');
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    try {
      // debugPrint('[EmployeeProvider] Начало загрузки сотрудников...');
      _isLoading = true;
      _error = null;
      notifyListeners();

      final stopwatch = Stopwatch()..start();
      _employees = await apiService.fetchEmployees();
      stopwatch.stop();

      // debugPrint('[EmployeeProvider] Загрузка завершена за ${stopwatch.elapsedMilliseconds}ms');
      // debugPrint('[EmployeeProvider] Получено сотрудников: ${_employees.length}');

      if (_employees.isEmpty) {
        // debugPrint('[EmployeeProvider] Внимание: список сотрудников пуст!');
      } else {
        // debugPrint('[EmployeeProvider] Первые 5 сотрудников:');
        for (final employee in _employees.take(5)) {
          debugPrint('  - ${employee.id}: ${employee.name}');
        }
        if (_employees.length > 5) {
          debugPrint('  ... и ещё ${_employees.length - 5}');
        }
      }

      _error = null;
    } catch (e, stackTrace) {
      _error = 'Ошибка загрузки сотрудников: $e';
      // debugPrint('[EmployeeProvider] $_error');
      // debugPrint('[EmployeeProvider] StackTrace: $stackTrace');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      // debugPrint('[EmployeeProvider] Состояние после загрузки:'
      //     '\n- isLoading: $_isLoading'
      //     '\n- error: $_error'
      //     '\n- employees: ${_employees.length}');
    }
  }

  void logCurrentState() {
    // debugPrint('[EmployeeProvider] Текущее состояние:'
    //     '\n- isLoading: $_isLoading'
    //     '\n- error: $_error'
    //     '\n- employees: ${_employees.length}');
    if (_employees.isNotEmpty) {
      // debugPrint('Последний сотрудник в списке:'
      //     ' ID=${_employees.last.id}, Name=${_employees.last.name}');
    }
  }
}