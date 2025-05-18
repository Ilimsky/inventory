import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/JobProvider.dart';
import '../../providers/EmployeeProvider.dart';

List<DataColumn> buildTableColumns({
  required BuildContext context,
  required Function(int, bool) onSort,
  required JobProvider jobProvider,
  required EmployeeProvider employeeProvider,
}) {
  return [
    DataColumn(
      label: _buildColumnLabel('№ п/п', 20),
      onSort: (i, asc) => onSort(i, asc),
    ),
    DataColumn(
      label: _buildColumnLabel('Дата занесения', 65),
      onSort: (i, asc) => onSort(i, asc),
    ),
    DataColumn(
      label: _buildColumnLabel('Инвентарный номер ', 70),
      onSort: (i, asc) => onSort(i, asc),
    ),
    DataColumn(
      label: _buildColumnLabel('Наименование', 180),
      onSort: (i, asc) => onSort(i, asc),
    ),
    DataColumn(
      label: _buildColumnLabel('Серийный номер', 120),
      onSort: (i, asc) => onSort(i, asc),
    ),
    DataColumn(
      label: _buildColumnLabel('Кол-во', 30),
      onSort: (i, asc) => onSort(i, asc),
    ),
    DataColumn(
      label: _buildColumnLabel('Ед. изм.', 30),
      onSort: (i, asc) => onSort(i, asc),
    ),
    DataColumn(
      label: _buildColumnLabel('Стоимость', 70),
      onSort: (i, asc) => onSort(i, asc),
    ),
    DataColumn(
      label: _buildColumnLabel('Местоположение', 70),
      onSort: (i, asc) => onSort(i, asc),
    ),
    DataColumn(
      label: _buildColumnLabel('Должность', 120),
      onSort: (i, asc) => onSort(i, asc),
    ),
    DataColumn(
      label: _buildColumnLabel('Сотрудник', 120),
      onSort: (i, asc) => onSort(i, asc),
    ),
    DataColumn(
      label: _buildColumnLabel('Комментарии', 150),
      onSort: (i, asc) => onSort(i, asc),
    ),
    DataColumn(
      label: _buildColumnLabel('Действия', 60),
    ),
  ];
}

Widget _buildColumnLabel(String text, double width) {
  return Container(
    width: width,
    child: Text(
      text,
      style: TextStyle(fontSize: 10),
      softWrap: true,
      overflow: TextOverflow.visible,
      maxLines: 2,
      textAlign: TextAlign.center,
    ),
  );
}
