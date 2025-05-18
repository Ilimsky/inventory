import 'Department.dart';
import 'Employee.dart';
import 'Job.dart';

class Binding {
  final int id;
  final int employeeId;
  final int departmentId;
  final int jobId;

  final Employee? employee;
  final Department? department;
  final Job? job;

  Binding({
    required this.id,
    required this.employeeId,
    required this.departmentId,
    required this.jobId,
    this.employee,
    this.department,
    this.job,
  });

  factory Binding.fromJson(Map<String, dynamic> json) {
    return Binding(
      id: json['id'] ?? 0,
      employeeId: json['employee_id'] ?? 0,
      departmentId: json['department_id'] ?? 0,
      jobId: json['job_id'] ?? 0,
      employee: json['employee'] != null ? Employee.fromJson(json['employee']) : null,
      department: json['department'] != null ? Department.fromJson(json['department']) : null,
      job: json['job'] != null ? Job.fromJson(json['job']) : null,
    );
  }

  Map<String, dynamic> toJsonForSave() {
    return {
      'employee_id': employeeId,
      'department_id': departmentId,
      'job_id': jobId,
    };
  }
}
