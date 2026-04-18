// Экран перемещения имущества (только для суперадмина)
import 'package:provider/provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/Sked.dart';
import '../providers/department_provider.dart';
import '../providers/employee_provider.dart';
import '../providers/sked_provider.dart';

class MoveSkedScreen extends StatefulWidget {
  final Sked sked;

  const MoveSkedScreen({required this.sked});

  @override
  _MoveSkedScreenState createState() => _MoveSkedScreenState();
}

class _MoveSkedScreenState extends State<MoveSkedScreen> {
  int? _selectedDepartmentId;
  int? _selectedEmployeeId;
  String _newPlace = '';
  DateTime _newDate = DateTime.now();
  bool _isLoading = false;

  Future<void> _confirmMove() async {
    if (_selectedDepartmentId == null || _selectedEmployeeId == null || _newPlace.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final skedProvider = Provider.of<SkedProvider>(context, listen: false);
      await skedProvider.moveSkedToDepartment(
        skedId: widget.sked.id,
        newDepartmentId: _selectedDepartmentId!,
        newDateReceived: _newDate,
        newPlace: _newPlace,
        newEmployeeId: _selectedEmployeeId!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Имущество успешно перемещено')),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка перемещения: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final departmentProvider = Provider.of<DepartmentProvider>(context);
    final employeeProvider = Provider.of<EmployeeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Перемещение имущества')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Информация о текущем имуществе
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Перемещаемое имущество:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('${widget.sked.itemName} (${widget.sked.skedNumber})'),
                    Text('Текущее местоположение: ${widget.sked.place}'),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Форма перемещения
            Expanded(
              child: ListView(
                children: [
                  // Выбор нового филиала
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Новый филиал *', style: TextStyle(fontWeight: FontWeight.bold)),
                          DropdownButton<int?>(
                            value: _selectedDepartmentId,
                            hint: Text('Выберите филиал'),
                            isExpanded: true,
                            items: departmentProvider.departments.map((dept) {
                              return DropdownMenuItem<int?>(
                                value: dept.id,
                                child: Text(dept.name),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedDepartmentId = value),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Выбор сотрудника
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ответственный сотрудник *', style: TextStyle(fontWeight: FontWeight.bold)),
                          DropdownButton<int?>(
                            value: _selectedEmployeeId,
                            hint: Text('Выберите сотрудника'),
                            isExpanded: true,
                            items: employeeProvider.employees.map((emp) {
                              return DropdownMenuItem<int?>(
                                value: emp.id,
                                child: Text(emp.name),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedEmployeeId = value),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Новое местоположение
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Новое местоположение *', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Введите новое местоположение',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => setState(() => _newPlace = value),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Дата перемещения
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Дата перемещения', style: TextStyle(fontWeight: FontWeight.bold)),
                          ListTile(
                            leading: Icon(Icons.calendar_today),
                            title: Text('${_newDate.day}.${_newDate.month}.${_newDate.year}'),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _newDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => _newDate = date);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Кнопка подтверждения
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmMove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('ПОДТВЕРДИТЬ ПЕРЕМЕЩЕНИЕ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}