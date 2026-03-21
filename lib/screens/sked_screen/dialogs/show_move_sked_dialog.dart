import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/Sked.dart';
import '../../../providers/department_provider.dart';
import '../../../providers/employee_provider.dart';
import '../../../providers/sked_provider.dart';
import '../../../services/auth_service.dart';

void showMoveSkedDialog(BuildContext context, Sked sked) {
  final authService = Provider.of<AuthService>(context, listen: false);
  // Проверка прав доступа
  if (!authService.isAdmin && !authService.isSuperAdmin) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Доступ запрещен: перемещение доступно только администраторам')),
    );
    return;
  }

  final departmentProvider = Provider.of<DepartmentProvider>(context, listen: false);
  final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);

  // Значения по умолчанию
  int? selectedDepartmentId;
  DateTime newDate = DateTime.now();
  String newPlace = sked.place;
  int? selectedEmployeeId = sked.employeeId;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Переместить имущество'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    hint: Text('Выберите новый филиал'),
                    value: selectedDepartmentId,
                    onChanged: (value) => setState(() => selectedDepartmentId = value),
                    items: departmentProvider.departments
                        .where((d) => d.id != sked.departmentId)
                        .map((d) => DropdownMenuItem(
                      value: d.id,
                      child: Text(d.name),
                    ))
                        .toList(),
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: newDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => newDate = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Дата перемещения',
                      ),
                      child: Text(DateFormat('dd.MM.yyyy').format(newDate)),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Новое местоположение',
                    ),
                    initialValue: newPlace,
                    onChanged: (value) => newPlace = value,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    hint: Text('Ответственный сотрудник'),
                    value: selectedEmployeeId,
                    onChanged: (value) => setState(() => selectedEmployeeId = value),
                    items: employeeProvider.employees
                        .map((e) => DropdownMenuItem(
                      value: e.id,
                      child: Text(e.name),
                    ))
                        .toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedDepartmentId != null && selectedEmployeeId != null) {
                    Navigator.pop(context);
                    try {
                      await Provider.of<SkedProvider>(context, listen: false)
                          .moveSkedToDepartment(
                        skedId: sked.id,
                        newDepartmentId: selectedDepartmentId!,
                        newDateReceived: newDate,
                        newPlace: newPlace,
                        newEmployeeId: selectedEmployeeId!,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  }
                },
                child: Text('Подтвердить перемещение'),
              ),
            ],
          );
        },
      );
    },
  );
}