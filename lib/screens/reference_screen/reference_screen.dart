import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bindings_tab.dart';
import 'departments_tab.dart';
import 'employees_tab.dart';

class ReferenceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Количество вкладок
      child: Scaffold(
        appBar: AppBar(
          title: Text('Справочник'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Привязка'),
              Tab(text: 'Филиалы'),
              Tab(text: 'Сотрудники'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BindingsTab(), // Вкладка для филиалов
            DepartmentsTab(), // Вкладка для филиалов
            EmployeesTab(), // Вкладка для сотрудников
          ],
        ),
      ),
    );
  }
}