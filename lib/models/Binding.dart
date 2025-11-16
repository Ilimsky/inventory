import 'Department.dart';
import 'Employee.dart';

class Binding {
  final int id;
  final int employeeId;
  final int departmentId;

  final Employee? employee;
  final Department? department;

  Binding({
    required this.id,
    required this.employeeId,
    required this.departmentId,
    this.employee,
    this.department,
  });

  factory Binding.fromJson(Map<String, dynamic> json) {
    return Binding(
      id: json['id'] ?? 0,
      employeeId: json['employee_id'] ?? 0,
      departmentId: json['department_id'] ?? 0,
      employee: json['employee'] != null ? Employee.fromJson(json['employee']) : null,
      department: json['department'] != null ? Department.fromJson(json['department']) : null,
    );
  }

  Map<String, dynamic> toJsonForSave() {
    return {
      'employee_id': employeeId,
      'department_id': departmentId,
    };
  }
}
