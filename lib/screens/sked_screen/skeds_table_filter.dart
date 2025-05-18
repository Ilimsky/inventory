import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/Sked.dart';
import '../../models/Department.dart';
import '../../models/Job.dart';
import '../../models/Employee.dart';
import '../../providers/DepartmentProvider.dart';
import '../../providers/JobProvider.dart';
import '../../providers/EmployeeProvider.dart';

List<Sked> filterSkeds({
  required BuildContext context,
  required List<Sked> skeds,
  required String searchQuery,
  required DepartmentProvider departmentProvider,
  required JobProvider jobProvider,
  required EmployeeProvider employeeProvider,
}) {
  if (searchQuery.isEmpty) return skeds;

  final dateFormat = DateFormat('dd.MM.yyyy');

  return skeds.where((sked) {
    final department = departmentProvider.departments.firstWhere(
          (d) => d.id == sked.departmentId,
      orElse: () => Department(id: 0, name: ''),
    );
    final job = jobProvider.jobs.firstWhere(
          (j) => j.id == sked.jobId,
      orElse: () => Job(id: 0, name: ''),
    );
    final employee = employeeProvider.employees.firstWhere(
          (e) => e.id == sked.employeeId,
      orElse: () => Employee(id: 0, name: ''),
    );

    final dateReceivedStr = dateFormat.format(sked.dateReceived);

    final query = searchQuery.toLowerCase();
    return sked.skedNumber.toString().contains(query) ||
        dateReceivedStr.toLowerCase().contains(query) ||
        sked.itemName.toLowerCase().contains(query) ||
        sked.measure.toLowerCase().contains(query) ||
        sked.serialNumber.toLowerCase().contains(query) ||
        sked.price.toString().toLowerCase().contains(query) ||
        sked.place.toLowerCase().contains(query) ||
        sked.comments.toLowerCase().contains(query) ||
        department.name.toLowerCase().contains(query) ||
        job.name.toLowerCase().contains(query) ||
        employee.name.toLowerCase().contains(query);
  }).toList();
}