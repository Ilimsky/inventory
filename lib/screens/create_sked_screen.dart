import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/Employee.dart';
import '../models/Department.dart';
import '../providers/DepartmentProvider.dart';
import '../providers/EmployeeProvider.dart';
import '../providers/SkedProvider.dart';

class CreateSkedScreen extends StatefulWidget {
  @override
  _CreateSkedScreenState createState() => _CreateSkedScreenState();
}

class _CreateSkedScreenState extends State<CreateSkedScreen> {
  int? selectedDepartmentId;
  Department? selectedDepartment;
  int? selectedEmployeeId;
  Employee? selectedEmployee;
  DateTime? selectedDateReceived;
  DateTime? selectedDateCreated;
  String selectedCategory = 'ОСиМБП';
  String selectedMeasure = 'шт.';
  String selectedPlace = 'Клиентская';


  // Контроллеры для текстовых полей
  // final TextEditingController _assetCategoryController = TextEditingController();
  final TextEditingController _dateReceivedController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _dateApprovedController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();
  // final TextEditingController _measureController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  // final TextEditingController _placeController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  // Состояние для отображения полей просмотра
  bool _showViewFields = false;

  // Список строк для отображения
  final List<Map<String, String>> _viewFields = [];

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    void Function(DateTime) onDateSelected,
  ) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      setState(() {
        onDateSelected(selectedDate); // обновляем нужную переменную
        controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  @override
  void dispose() {
    _dateReceivedController.dispose();
    _itemNameController.dispose();
    _countController.dispose();
    _dateApprovedController.dispose();
    _serialNumberController.dispose();
    // _measureController.dispose();
    _priceController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final departmentProvider = Provider.of<DepartmentProvider>(context);
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final skedProvider = Provider.of<SkedProvider>(context);


    return Scaffold(
      appBar: AppBar(
        title: Text('Создать отчет'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                      DropdownButton<int>(
                        hint: Text('Филиал', style: TextStyle(fontSize: 14)),
                        value: selectedDepartmentId,
                        onChanged: (newId) {
                          setState(() {
                            selectedDepartmentId = newId;
                            selectedDepartment = departmentProvider.departments
                                .firstWhere((dept) => dept.id == newId);
                          });
                        },
                        items: departmentProvider.departments.map((dept) {
                          return DropdownMenuItem(
                            value: dept.id,
                            child:
                                Text(dept.name, style: TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                // SizedBox(width: 10),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Категория',
                          labelStyle: TextStyle(fontSize: 14),
                          border: InputBorder.none,
                        ),
                        value: selectedCategory,
                        items: ['ОСиМБП', 'Техника', 'Проверочный инвентарь']
                            .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            style: TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),

                    ),
                  ),
                ),
                // SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () =>
                        _selectDate(context, _dateReceivedController, (date) {
                      selectedDateReceived = date;
                    }),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AbsorbPointer(
                          // Отключаем возможность редактирования текста
                          child: TextField(
                            controller: _dateReceivedController,
                            decoration: InputDecoration(
                              labelText: 'Дата внесения',
                              labelStyle: TextStyle(fontSize: 14),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // SizedBox(width: 10), // Отступ между элементами
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _itemNameController,
                        decoration: InputDecoration(
                          labelText: 'Наименование',
                          labelStyle: TextStyle(fontSize: 14),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 14),
                        keyboardType: TextInputType.number, // Для ввода чисел
                      ),
                    ),
                  ),
                ),
                // SizedBox(width: 10), // Отступ между элементами
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _serialNumberController,
                        decoration: InputDecoration(
                          labelText: 'Серийный номер',
                          labelStyle: TextStyle(fontSize: 14),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                // SizedBox(width: 10), // Отступ между элементами
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _countController,
                        decoration: InputDecoration(
                          labelText: 'Кол-во',
                          labelStyle: TextStyle(fontSize: 14),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Ед. изм.',
                          labelStyle: TextStyle(fontSize: 14),
                          border: InputBorder.none,
                        ),
                        value: selectedMeasure,
                        items: ['шт.', 'пачка', 'литр']
                            .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            style: TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMeasure = value!;
                          });
                        },
                      ),

                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Стоимость',
                          labelStyle: TextStyle(fontSize: 14),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Отступ между элементами
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Местоположение',
                          labelStyle: TextStyle(fontSize: 14),
                          border: InputBorder.none,
                        ),
                        value: selectedPlace,
                        items: ['Клиентская', 'Операционная', 'Хранилище', 'Прихожая', 'Директорская', 'Кухня', 'Балкон']
                            .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            style: TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPlace = value!;
                          });
                        },
                      ),

                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<int>(
                        hint: Text('Сотрудник', style: TextStyle(fontSize: 14)),
                        value: selectedEmployeeId,
                        onChanged: (newId) {
                          setState(() {
                            selectedEmployeeId = newId;
                            selectedEmployee = employeeProvider.employees
                                .firstWhere((employee) => employee.id == newId);
                          });
                        },
                        items: employeeProvider.employees.map((employee) {
                          return DropdownMenuItem(
                            value: employee.id,
                            child: Text(employee.name,
                                style: TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _commentsController,
                        decoration: InputDecoration(
                          labelText: 'Комментарии',
                          labelStyle: TextStyle(fontSize: 14),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Отступ между элементами

            // Кнопки "Создать отчет" и "Просмотр" в один ряд
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedDepartmentId != null &&
                          selectedEmployeeId != null &&
                          selectedDateReceived != null) {
                        try {
                          await skedProvider.createSked(
                            departmentId: selectedDepartmentId!,
                            employeeId: selectedEmployeeId!,
                            assetCategory: selectedCategory,
                            dateReceived: selectedDateReceived!,
                            itemName: _itemNameController.text,
                            count: int.tryParse(_countController.text) ?? 0,
                            serialNumber: _serialNumberController.text,
                            measure: selectedMeasure,
                            price: double.tryParse(_priceController.text) ?? 0.0,
                            place: selectedPlace,
                            comments: _commentsController.text,
                          );

                          // После создания обновляем список отчетов для выбранного филиала
                          await skedProvider.fetchSkedsByDepartment(selectedDepartmentId!);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Отчет успешно создан!')),
                          );
                          // Очищаем поля
                          _clearFields();
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ошибка: $error')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Заполните все обязательные поля!')),
                        );
                      }
                    },
                    child: Text('Создать отчет'),
                  ),
                ),
                SizedBox(width: 10), // Отступ между кнопками
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showViewFields =
                            !_showViewFields; // Переключаем отображение полей
                        if (_showViewFields) {
                          // Добавляем текущие значения в список для отображения
                          _viewFields.add({
                            'Категория': selectedCategory ?? 'Не выбрано',
                            'Филиал': selectedDepartment?.name ?? 'Не выбран',
                            'Дата внесения': _dateReceivedController.text,
                            'Наименование': _itemNameController.text,
                            'Серийный номер': _serialNumberController.text,
                            'Кол-во': _countController.text,
                            'Ед. изм.': selectedMeasure,
                            'Стоимость': _priceController.text,
                            'Местоположение': selectedPlace,
                            'Сотрудник': selectedEmployee?.name ?? 'Не выбран',
                            'Комментарии': _commentsController.text,
                          });
                        }
                      });
                    },
                    child: Text('Просмотр'),
                  ),
                ),
              ],
            ),

            // Отображение полей просмотра
            if (_showViewFields)
              Column(
                children: _viewFields.map((field) {
                  return _buildViewRow(field);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _clearFields() {
    setState(() {
      selectedDepartmentId = null;
      selectedEmployeeId = null;
      selectedDateReceived = null;
      // selectedCategory = null;
      _dateReceivedController.clear();
      _itemNameController.clear();
      _countController.clear();
      _dateApprovedController.clear();
      _serialNumberController.clear();
      // _measureController.clear();
      _priceController.clear();
      // _placeController.clear();
      _commentsController.clear();
    });
  }

  // Метод для создания строки просмотра
  Widget _buildViewRow(Map<String, String> field) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          // Поля в строке
          Expanded(
            child: Row(
              children: field.entries.map((entry) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          entry.value,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Иконка "Удалить"
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteDialog(
                  field); // Показываем диалоговое окно для подтверждения удаления
            },
          ),
        ],
      ),
    );
  }

  // Метод для отображения диалогового окна удаления
  void _showDeleteDialog(Map<String, String> field) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Удалить запись?'),
          content: Text('Вы уверены, что хотите удалить эту запись?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Закрыть диалоговое окно
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _viewFields.remove(field); // Удаляем строку из списка
                });
                Navigator.pop(context); // Закрыть диалоговое окно
              },
              child: Text('Удалить', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
