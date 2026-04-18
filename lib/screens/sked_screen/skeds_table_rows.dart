import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/Sked.dart';
import '../../models/Department.dart';
import '../../models/Employee.dart';
import '../../providers/department_provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/sked_provider.dart';
import '../../services/auth_service.dart';
import 'dialogs/show_move_sked_dialog.dart';
import 'dialogs/show_write_off_details_dialog.dart';
import 'dialogs/show_edit_sked_dialog.dart';

DataCell _buildDataCell(
    String text, double width, int maxLines, bool isMoved, bool isDeleted) {
  return DataCell(
    Container(
      width: width,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: isDeleted
              ? Colors.grey
              : isMoved
              ? Colors.orange
              : null,
          decoration: isDeleted ? TextDecoration.lineThrough : null,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: maxLines,
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    ),
  );
}

DataCell _buildAvailabilityCell(
    BuildContext context, Sked sked, DateTime? selectedDate) {
  final provider = Provider.of<SkedProvider>(context, listen: false);

  return DataCell(
    Consumer<SkedProvider>(
      builder: (context, provider, child) {
        return Checkbox(
          value: sked.available,
          onChanged: selectedDate != null
              ? (val) async {
            if (val == null) return;

            // Локальное мгновенное обновление через провайдер
            provider.updateSkedLocally(sked.id, available: val);

            try {
              // Асинхронное обновление на сервере
              await provider.updateSked(sked.copyWith(available: val));
            } catch (e) {
              // Откат при ошибке
              provider.updateSkedLocally(sked.id, available: !val);
              debugPrint('Ошибка обновления: $e');
            }
          }
              : null,
        );
      },
    ),
  );
}

List<DataRow> buildTableRows({
  required BuildContext context,
  required List<Sked> skeds,
  required DepartmentProvider departmentProvider,
  required EmployeeProvider employeeProvider,
  required DateTime? selectedDate,
}) {
  final dateFormat = DateFormat('dd.MM.yyyy');

  return skeds.asMap().entries.map((entry) {
    final sked = entry.value;
    final rowNumber = entry.key + 1;
    final isMoved = sked.comments?.contains('Перемещено в') ?? false;

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
          if (isMoved) {
            return Colors.orange.withOpacity(0.2);
          }
          return null;
        },
      ),
      cells: [
        _buildDataCell(rowNumber.toString(), 12, 1, isMoved, false),
        _buildDataCell(sked.assetCategory, 50, 1, isMoved, false),
        _buildDataCell(
            dateFormat.format(sked.dateReceived), 55, 1, isMoved, false),
        _buildDataCell(sked.skedNumber, 55, 1, isMoved, false),
        _buildDataCell(sked.itemName, 150, 4, isMoved, false),
        _buildDataCell(sked.serialNumber, 80, 1, isMoved, false),
        _buildDataCell(sked.count.toString(), 20, 1, isMoved, false),
        _buildDataCell(sked.measure, 20, 1, isMoved, false),
        _buildDataCell(sked.price.toString(), 60, 1, isMoved, false),
        _buildDataCell(sked.place, 70, 1, isMoved, false),
        _buildDataCell(employee.name, 80, 1, isMoved, false),
        _buildDataCell(sked.comments, 100, 3, isMoved, false),
        _buildAvailabilityCell(context, sked, selectedDate),
        _buildActionsCell(context, sked, department, employee),
      ],
    );
  }).toList();
}

DataCell _buildActionsCell(
    BuildContext context,
    Sked sked,
    Department department,
    Employee employee,
    ) {
  final provider = Provider.of<SkedProvider>(context, listen: false);
  final isMoved = sked.comments?.contains('Перемещено в') ?? false;
  final authService = Provider.of<AuthService>(context, listen: false);

  // Проверки прав доступа
  final canEdit = authService.isAdmin || authService.isSuperAdmin;
  final canMove = authService.isAdmin || authService.isSuperAdmin;
  final canWriteOff = authService.isSuperAdmin;
  final canDelete = authService.isSuperAdmin;

  return DataCell(
    Container(
      width: 140, // Увеличили ширину для дополнительной кнопки
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Иконка деталей
          IconButton(
            icon: Icon(Icons.assignment, size: 14),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () => null,
            // onPressed: () => showWriteOffDetailsDialog(context, sked),
          ),

          // Кнопка редактирования
          if (canEdit)
            IconButton(
              icon: Icon(Icons.edit, size: 14),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: () => showEditSkedDialog(context, sked),
            ),

          // Кнопка перемещения
          if (canMove)
            IconButton(
              icon: Icon(Icons.move_to_inbox, size: 14),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: () => showMoveSkedDialog(context, sked),
            ),

          // Кнопка списания (УДАЛЕНИЯ с причиной)
          if (canWriteOff)
            IconButton(
              icon: Icon(Icons.money_off, size: 14, color: Colors.red),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: () async {
                final reason = await showWriteOffDialog(context, sked.id);
                if (reason != null) {
                  // Списание = Физическое удаление с причиной
                  await provider.deleteSked(sked.id);
                }
              },
            ),

          // Кнопка НЕМЕДЛЕННОГО УДАЛЕНИЯ (без причины)
          if (canDelete)
            IconButton(
              icon: Icon(Icons.delete, size: 14, color: Colors.red[700]),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Удалить актив?'),
                    content: Text(
                        'Вы уверены, что хотите удалить "${sked.itemName}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text('Удалить'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await provider.deleteSked(sked.id);
                }
              },
            ),
        ],
      ),
    ),
  );
}

// Диалог списания с указанием причины
Future<String?> showWriteOffDialog(BuildContext context, int skedId) async {
  final reasonController = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Списать актив'),
      content: TextField(
        controller: reasonController,
        decoration: InputDecoration(
            labelText: 'Причина списания',
            hintText: 'Например: Износ, поломка, утрата...'),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            if (reasonController.text.isNotEmpty) {
              Navigator.pop(ctx, reasonController.text);
            }
          },
          child: Text('Списать'),
        ),
      ],
    ),
  );
}
