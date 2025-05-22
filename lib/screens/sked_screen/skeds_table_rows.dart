import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_frontend/screens/sked_screen/skeds_dialogs.dart';

import '../../models/Sked.dart';
import '../../models/Department.dart';
import '../../models/Employee.dart';
import '../../providers/DepartmentProvider.dart';
import '../../providers/EmployeeProvider.dart';

List<DataRow> buildTableRows({
  required BuildContext context,
  required List<Sked> skeds,
  required DepartmentProvider departmentProvider,
  required EmployeeProvider employeeProvider,
}) {
  final dateFormat = DateFormat('dd.MM.yyyy');

  return skeds.asMap().entries.map((entry) {
    final sked = entry.value;
    final rowNumber = entry.key + 1; // Нумерация с 1

    final department = departmentProvider.departments.firstWhere(
          (d) => d.id == sked.departmentId,
      orElse: () => Department(id: 0, name: 'Неизвестно'),
    );

    final employee = employeeProvider.employees.firstWhere(
          (e) => e.id == sked.employeeId,
      orElse: () => Employee(id: 0, name: 'Неизвестно'),
    );

    return DataRow(cells: [
      _buildDataCell(rowNumber.toString(), 20, 1),
      _buildDataCell(sked.assetCategory, 80, 1),
      _buildDataCell(dateFormat.format(sked.dateReceived), 65, 1),
      _buildDataCell('${department.name}/${sked.skedNumber.toString().padLeft(6, '0')}', 70, 1),
      _buildDataCell(sked.itemName, 180, 4),
      _buildDataCell(sked.serialNumber, 120, 1),
      _buildDataCell(sked.count.toString(), 30, 1),
      _buildDataCell(sked.measure, 30, 1),
      _buildDataCell(sked.price.toString(), 70, 1),
      _buildDataCell(sked.place.toString(), 70, 1),
      _buildDataCell(employee.name, 120, 1),
      _buildDataCell(sked.comments, 150, 3),
      _buildActionsCell(context, sked, department, employee),
    ]);
  }).toList();
}

DataCell _buildDataCell(String text, double width, int maxLines) {
  return DataCell(Container(
    width: width,
    child: Text(
      text,
      style: TextStyle(fontSize: 12),
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines,
      textAlign: TextAlign.center,
      softWrap: true,
    ),
  ));
}

DataCell _buildActionsCell(
    BuildContext context,
    Sked sked,
    Department department,
    Employee employee,
    ) {
  return DataCell(
    Container(
      width: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.edit, size: 16),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () => showEditSkedDialog(context, sked),
          ),
          IconButton(
            icon: Icon(Icons.delete, size: 16),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () => showDeleteSkedDialog(context, sked.id),
          ),
        ],
      ),
    ),
  );
}