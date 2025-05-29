import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../api/ApiService.dart';
import '../../models/Department.dart';
import '../../models/Employee.dart';
import '../../models/Sked.dart';
import '../../providers/DepartmentProvider.dart';
import '../../providers/EmployeeProvider.dart';
import '../../providers/SkedProvider.dart';

void showEditSkedDialog(BuildContext context, Sked sked) {
  final skedProvider = Provider.of<SkedProvider>(context, listen: false);

  // Контроллеры для текстовых полей
  final skedNumberController =
      TextEditingController(text: sked.skedNumber.toString());
  final assetCategoryController = TextEditingController(text: sked.assetCategory);
  final dateReceivedController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(sked.dateReceived));
  final itemNameController = TextEditingController(text: sked.itemName);
  final countController = TextEditingController(text: sked.count.toString());
  final serialNumberController = TextEditingController(text: sked.serialNumber);
  final measureController = TextEditingController(text: sked.measure);
  final priceController = TextEditingController(text: sked.price.toString());
  final placeController = TextEditingController(text: sked.place);
  final commentsController = TextEditingController(text: sked.comments);

  // Значения для выпадающих списков
  int? selectedDepartmentId = sked.departmentId;
  int? selectedEmployeeId = sked.employeeId;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text('Редактировать отчет'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<List<Department>>(
                  future: ApiService().fetchDepartments(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return DropdownButtonFormField<int>(
                      value: selectedDepartmentId,
                      items: snapshot.data!.map((department) {
                        return DropdownMenuItem<int>(
                          value: department.id,
                          child: Text(department.name),
                        );
                      }).toList(),
                      onChanged: null,
                          // (value) => setState(() => selectedDepartmentId = value),
                      decoration: InputDecoration(labelText: 'Отдел'),
                    );
                  },
                ),

                TextField(
                  controller: assetCategoryController,
                  decoration: InputDecoration(labelText: 'Категория'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: dateReceivedController,
                  decoration: InputDecoration(
                    labelText: 'Дата внесение',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: sked.dateReceived,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      dateReceivedController.text =
                          DateFormat('yyyy-MM-dd').format(date);
                    }
                  },
                ),
                TextField(
                  controller: itemNameController,
                  decoration: InputDecoration(labelText: 'Наименование'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: serialNumberController,
                  decoration: InputDecoration(labelText: 'Серийный номер'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: countController,
                  decoration: InputDecoration(labelText: 'Кол-во'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: measureController,
                  decoration: InputDecoration(labelText: 'Ед. изм.'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Стоимость'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: placeController,
                  decoration: InputDecoration(labelText: 'Местоположение'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                FutureBuilder<List<Employee>>(
                  future: ApiService().fetchEmployees(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return DropdownButtonFormField<int>(
                      value: selectedEmployeeId,
                      items: snapshot.data!.map((employee) {
                        return DropdownMenuItem<int>(
                          value: employee.id,
                          child: Text(employee.name),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => selectedEmployeeId = value),
                      decoration: InputDecoration(labelText: 'Сотрудник'),
                    );
                  },
                ),
                TextField(
                  controller: commentsController,
                  decoration: InputDecoration(labelText: 'Комментарии'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                skedProvider.updateSked(
                  sked.id,
                  skedNumber: skedNumberController.text,
                  departmentId: selectedDepartmentId!,
                  employeeId: selectedEmployeeId!,
                  assetCategory: assetCategoryController.text,
                  dateReceived: DateFormat('yyyy-MM-dd')
                      .parse(dateReceivedController.text),
                  itemName: itemNameController.text,
                  count: int.parse(countController.text),
                  place: placeController.text,
                  serialNumber: serialNumberController.text,
                  measure: measureController.text,
                  price: double.parse(priceController.text),
                  comments: commentsController.text,
                );
                Navigator.pop(context);
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    ),
  );
}

void showDeleteSkedDialog(BuildContext context, int skedId) {
  final skedProvider = Provider.of<SkedProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Удалить отчет'),
      content: Text('Вы уверены, что хотите удалить этот отчет?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            skedProvider.deleteSked(skedId);
            Navigator.pop(context);
          },
          child: Text('Удалить', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

void showMoveSkedDialog(BuildContext context, Sked sked) {
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

void showWriteOffDialog(BuildContext context, int skedId) {
  final reasonController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Списание имущества'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Укажите причину списания:'),
            SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Причина списания',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Введите причину списания')),
                );
                return;
              }

              try {
                final skedProvider = Provider.of<SkedProvider>(context, listen: false);
                await skedProvider.writeOffSked(
                  skedId: skedId,
                  writeOffReason: reasonController.text,
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка при списании: $e')),
                );
              }
            },
            child: Text('Списать', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

void showWriteOffDetailsDialog(BuildContext context, Sked sked) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Информация о списании'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Наименование: ${sked.itemName}'),
            Text('Инвентарный номер: ${sked.skedNumber}'),
            Divider(),
            Text('Причина списания:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(sked.comments.split('Причина:').last.trim()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть'),
          ),
        ],
      );
    },
  );
}