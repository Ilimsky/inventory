import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_frontend/screens/sked_screen/skeds_dialogs.dart';
import 'package:provider/provider.dart';

import '../../models/Sked.dart';
import '../../models/Department.dart';
import '../../models/Employee.dart';
import '../../providers/DepartmentProvider.dart';
import '../../providers/EmployeeProvider.dart';
import '../../providers/SkedProvider.dart';

List<DataRow> buildTableRows({
  required BuildContext context,
  required List<Sked> skeds,
  required DepartmentProvider departmentProvider,
  required EmployeeProvider employeeProvider,
  required DateTime? selectedDate,
  required VoidCallback onToggleAvailable,
}) {
  final dateFormat = DateFormat('dd.MM.yyyy');

  return skeds.asMap().entries.map((entry) {
    final sked = entry.value;
    final rowNumber = entry.key + 1;
    final isMoved = sked.comments.contains('Перемещено в');
    final isWrittenOff = sked.isWrittenOff || (sked.comments?.contains('Списано') ?? false);

    final department = departmentProvider.departments.firstWhere(
          (d) => d.id == sked.departmentId,
      orElse: () => Department(id: 0, name: 'Неизвестно'),
    );

    final employee = employeeProvider.employees.firstWhere(
          (e) => e.id == sked.employeeId,
      orElse: () => Employee(id: 0, name: 'Неизвестно'),
    );

    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (isWrittenOff) {
            return Colors.red.withOpacity(0.3);
          } else if (isMoved) {
            return Colors.orange.withOpacity(0.2);
          }
          return null;
        },
      ),
      cells: [
        _buildDataCell(rowNumber.toString(), 20, 1, isMoved, isWrittenOff),
        _buildDataCell(sked.assetCategory, 80, 1, isMoved, isWrittenOff),
        _buildDataCell(dateFormat.format(sked.dateReceived), 65, 1, isMoved, isWrittenOff),
        _buildDataCell(sked.skedNumber, 70, 1, isMoved, isWrittenOff),
        _buildDataCell(sked.itemName, 180, 4, isMoved, isWrittenOff),
        _buildDataCell(sked.serialNumber, 120, 1, isMoved, isWrittenOff),
        _buildDataCell(sked.count.toString(), 30, 1, isMoved, isWrittenOff),
        _buildDataCell(sked.measure, 30, 1, isMoved, isWrittenOff),
        _buildDataCell(sked.price.toString(), 70, 1, isMoved, isWrittenOff),
        _buildDataCell(sked.place.toString(), 70, 1, isMoved, isWrittenOff),
        _buildDataCell(employee.name, 120, 1, isMoved, isWrittenOff),
        _buildDataCell(sked.comments, 150, 3, isMoved, isWrittenOff),
        DataCell(
          Checkbox(
            value: sked.available,
            onChanged: selectedDate != null
                ? (val) async {
              if (val == null) return;

              try {
                final provider = Provider.of<SkedProvider>(context, listen: false);
                final updatedSked = Sked(
                  id: sked.id,
                  skedNumber: sked.skedNumber,
                  departmentId: sked.departmentId,
                  employeeId: sked.employeeId,
                  assetCategory: sked.assetCategory,
                  dateReceived: sked.dateReceived,
                  itemName: sked.itemName,
                  serialNumber: sked.serialNumber,
                  count: sked.count,
                  measure: sked.measure,
                  price: sked.price,
                  place: sked.place,
                  comments: sked.comments,
                  available: val,
                );

                await provider.updateSked(updatedSked);
              } catch (e) {
                print('[Checkbox] Failed to update availability: $e');
              }
            }
                : null,
          ),
        ),

        _buildActionsCell(context, sked, department, employee, isWrittenOff),
      ],
    );
  }).toList();
}



DataCell _buildDataCell(String text, double width, int maxLines, bool isMoved, bool isWrittenOff) {
  return DataCell(Container(
    width: width,
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: isWrittenOff
            ? Colors.red
            : isMoved ? Colors.orange : null,
        decoration: isWrittenOff ? TextDecoration.lineThrough : null,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines,
      textAlign: TextAlign.center,
      softWrap: true,
    ),
  ));
}

// В функции _buildActionsCell
DataCell _buildActionsCell(
    BuildContext context,
    Sked sked,
    Department department,
    Employee employee,
    bool isWrittenOff,
    ) {
  return DataCell(
    Container(
      width: isWrittenOff ? 40 : 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min, // Добавляем это
        children: isWrittenOff
            ? [
          IconButton(
            icon: Icon(Icons.assignment, size: 14), // Уменьшаем размер
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () => showWriteOffDetailsDialog(context, sked),
          ),
        ]
            : [
          IconButton(
            icon: Icon(Icons.edit, size: 14),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () => showEditSkedDialog(context, sked),
          ),
          IconButton(
            icon: Icon(Icons.move_to_inbox, size: 14),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () => showMoveSkedDialog(context, sked),
          ),
          IconButton(
            icon: Icon(Icons.money_off, size: 14, color: Colors.red),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () => showWriteOffDialog(context, sked.id),
          ),
          IconButton(
            icon: Icon(Icons.delete, size: 14),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Удалить запись?'),
                  content: Text('Вы уверены, что хотите удалить ${sked.itemName}?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Нет')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Да')),
                  ],
                ),
              );

              if (confirm == true) {
                final provider = Provider.of<SkedProvider>(context, listen: false);
                await provider.deleteSked(sked.id);
                // Не нужно вручную вызывать markNeedsBuild(),
                // notifyListeners() в provider уже должен обновить UI
              }
            },
          ),
        ],
      ),
    ),
  );
}