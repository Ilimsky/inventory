import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../api/ApiService.dart';
import '../../models/Department.dart';
import '../../models/Employee.dart';
import '../../models/Sked.dart';
import '../../providers/SkedProvider.dart';

void showEditSkedDialog(BuildContext context, Sked sked) {
  final skedProvider = Provider.of<SkedProvider>(context, listen: false);

  // Контроллеры для текстовых полей
  final skedNumberController =
      TextEditingController(text: sked.skedNumber.toString());
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
                  skedNumber: int.parse(skedNumberController.text),
                  departmentId: selectedDepartmentId!,
                  employeeId: selectedEmployeeId!,
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
