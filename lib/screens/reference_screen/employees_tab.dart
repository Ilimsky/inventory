// lib/tabs/jobs_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/EmployeeProvider.dart';

class EmployeesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  final textController = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Добавить сотрудника'),
                      content: TextField(controller: textController),
                      actions: [
                        TextButton(
                          onPressed: () {
                            if (textController.text.isNotEmpty) {
                              employeeProvider.createEmployee(textController.text);
                              Navigator.pop(context);
                            }
                          },
                          child: Text('Добавить'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: employeeProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: employeeProvider.employees.length,
            itemBuilder: (context, index) {
              final employee = employeeProvider.employees[index];
              return ListTile(
                title: Text(employee.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        final textController = TextEditingController(text: employee.name);
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Редактировать сотрудника'),
                            content: TextField(controller: textController),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  if (textController.text.isNotEmpty) {
                                    employeeProvider.updateEmployee(employee.id, textController.text);
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text('Сохранить'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _showDeleteEmployeeDialog(context, employee.id, employeeProvider),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteEmployeeDialog(BuildContext context, int employeeId, EmployeeProvider employeeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить сотрудника'),
        content: Text('Вы уверены, что хотите удалить этого сотрудника?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              employeeProvider.deleteEmployee(employeeId);
              Navigator.pop(context);
            },
            child: Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}


