import 'package:flutter/material.dart';
import 'package:inventory_frontend/screens/sked_screen/skeds_table_filter.dart';
import 'package:inventory_frontend/screens/sked_screen/skeds_table_rows.dart';
import 'package:provider/provider.dart';

import '../../models/Sked.dart';
import '../../providers/department_provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/sked_provider.dart';

class SkedsTable extends StatefulWidget {
  final String searchQuery;

  const SkedsTable({super.key, required this.searchQuery});

  @override
  _SkedsTableState createState() => _SkedsTableState();
}

class _SkedsTableState extends State<SkedsTable> {
  int _sortColumnIndex = 0;
  bool _isAscending = true;

  final List<double> _columnWidths = [
    30,   // № п/п
    80,  // Категория
    80,   // Дата
    100,  // Инв. номер
    180,  // Наименование
    120,  // Серийный
    70,   // Кол-во
    70,   // Ед. изм.
    90,   // Стоимость
    100,  // Место
    120,  // Сотрудник
    150,  // Коммент.
    70,   // Наличие
    100   // Действия
  ];

  final List<String> _headers = [
    '№ п/п', 'Категория', 'Дата', 'Инв. номер', 'Наименование', 'Серийный',
    'Кол-во', 'Ед. изм.', 'Стоимость', 'Место', 'Сотрудник', 'Коммент.', 'Наличие', 'Действия'
  ];

  void _handlePagination(int page, int size) {
    final provider = Provider.of<SkedProvider>(context, listen: false);
    final departmentId = provider.currentDepartmentId;

    if (departmentId != null) {
      provider.fetchSkedsByDepartmentPaged(departmentId: departmentId, page: page, size: size);
    } else {
      provider.fetchAllSkedsPaged(page: page, size: size);
    }
  }

  void _handleSort(int columnIndex, bool ascending) {
    final skedProvider = Provider.of<SkedProvider>(context, listen: false);
    final sortField = _getSortField(columnIndex);
    final sortDirection = ascending ? 'asc' : 'desc';
    final departmentId = skedProvider.currentDepartmentId;

    if (departmentId != null) {
      skedProvider.fetchSkedsByDepartmentPaged(
        departmentId: departmentId,
        sort: '$sortField,$sortDirection',
      );
    } else {
      skedProvider.fetchAllSkedsPaged(
        sort: '$sortField,$sortDirection',
      );
    }

    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;
    });
  }

  String _getSortField(int columnIndex) {
    switch (columnIndex) {
      case 0: return 'id';
      case 1: return 'assetCategory';
      case 2: return 'dateReceived';
      case 3: return 'skedNumber';
      case 4: return 'itemName';
      case 5: return 'serialNumber';
      case 6: return 'count';
      case 7: return 'measure';
      case 8: return 'price';
      case 9: return 'place';
      case 10: return 'employee.name';
      default: return 'id';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final totalWidth = _columnWidths.reduce((a, b) => a + b);

    final skeds = context.select<SkedProvider, List<Sked>>((p) => p.skeds);
    final skedProvider = Provider.of<SkedProvider>(context);
    final departmentProvider = Provider.of<DepartmentProvider>(context);
    final employeeProvider = Provider.of<EmployeeProvider>(context);

    final filteredSkeds = filterSkeds(
      context: context,
      skeds: skeds,
      searchQuery: widget.searchQuery,
      departmentProvider: departmentProvider,
      employeeProvider: employeeProvider,
    );

    return Column(
      children: [
        // Шапка таблицы
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            height: 40,
            color: Colors.grey[200],
            width: totalWidth, // Общая ширина всех колонок
            child: Row(
              children: List.generate(
                _headers.length,
                    (i) => SizedBox(
                  width: _columnWidths[i],
                  child: InkWell(
                    onTap: i < 11 ? () => _handleSort(i, true) : null,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Text(
                        _headers[i],
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Тело таблицы
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalWidth, // Общая ширина всех колонок
                child: DataTable(
                  headingRowHeight: 0,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _isAscending,
                  dataRowMinHeight: 30,
                  dataRowMaxHeight: 40,
                  columnSpacing: 0,
                  columns: List.generate(
                    _headers.length,
                        (index) => DataColumn(
                      label: SizedBox(
                        width: _columnWidths[index],
                        child: const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  rows: buildTableRows(
                    context: context,
                    skeds: filteredSkeds,
                    departmentProvider: departmentProvider,
                    employeeProvider: employeeProvider,
                    selectedDate: skedProvider.selectedDate,
                    // Убрали onToggleAvailable
                  ),
                ),
              ),
            ),
          ),
        ),

        // Пагинация
        _buildPaginationControls(skedProvider),
      ],
    );
  }

  Widget _buildPaginationControls(SkedProvider skedProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text('Всего записей: ${skedProvider.totalElements}', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: skedProvider.currentPage > 0
                    ? () => _handlePagination(0, skedProvider.pageSize)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: skedProvider.currentPage > 0
                    ? () => _handlePagination(skedProvider.currentPage - 1, skedProvider.pageSize)
                    : null,
              ),
              Text('${skedProvider.currentPage + 1} / ${skedProvider.totalPages}', style: const TextStyle(fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: skedProvider.currentPage < skedProvider.totalPages - 1
                    ? () => _handlePagination(skedProvider.currentPage + 1, skedProvider.pageSize)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: skedProvider.currentPage < skedProvider.totalPages - 1
                    ? () => _handlePagination(skedProvider.totalPages - 1, skedProvider.pageSize)
                    : null,
              ),
              const SizedBox(width: 16),
              DropdownButton<int>(
                value: skedProvider.pageSize,
                items: [10, 20, 30, 50].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value на странице'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _handlePagination(0, value);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}