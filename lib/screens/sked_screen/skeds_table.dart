import 'package:flutter/material.dart';
import 'package:inventory_frontend/models/Sked.dart';
import 'package:provider/provider.dart';

import '../../providers/SkedProvider.dart';
import '../../providers/DepartmentProvider.dart';
import '../../providers/EmployeeProvider.dart';
import 'skeds_table_columns.dart';
import 'skeds_table_rows.dart';
import 'skeds_table_sort.dart';
import 'skeds_table_filter.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';


class SkedsTable extends StatefulWidget {
  final String searchQuery;

  const SkedsTable({required this.searchQuery});

  @override
  _SkedsTableState createState() => _SkedsTableState();
}

class _SkedsTableState extends State<SkedsTable> {
  int _sortColumnIndex = 0;
  bool _isAscending = true;

  void _handlePagination(int page, int size) {
    final provider = Provider.of<SkedProvider>(context, listen: false);
    final departmentId = provider.currentDepartmentId;

    if (departmentId != null) {
      provider.fetchSkedsByDepartmentPaged(departmentId: departmentId, page: page, size: size);
    } else {
      provider.fetchAllSkedsPaged(page: page, size: size);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skeds = context.select<SkedProvider, List<Sked>>((p) => p.skeds);
    final skedProvider = Provider.of<SkedProvider>(context, listen: false);

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
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _isAscending,
                headingRowHeight: 40,
                dataRowMinHeight: 30,
                dataRowMaxHeight: 40,
                columnSpacing: 1,
                columns: buildTableColumns(
                  context: context,
                  onSort: (i, asc) {
                    final sortField = _getSortField(i);
                    final sortDirection = asc ? 'asc' : 'desc';
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
                      _sortColumnIndex = i;
                      _isAscending = asc;
                    });
                  },
                  employeeProvider: employeeProvider,
                ),
                rows: buildTableRows(
                  context: context,
                  skeds: filteredSkeds,
                  departmentProvider: departmentProvider,
                  employeeProvider: employeeProvider,
                ),
              ),
            ),
          ),
        ),
        _buildPaginationControls(skedProvider),
      ],
    );
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

  Widget _buildPaginationControls(SkedProvider skedProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            'Всего записей: ${skedProvider.totalElements}',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.first_page),
                onPressed: skedProvider.currentPage > 0
                    ? () => _handlePagination(0, skedProvider.pageSize)
                    : null,
              ),
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: skedProvider.currentPage > 0
                    ? () => _handlePagination(skedProvider.currentPage - 1, skedProvider.pageSize)
                    : null,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${skedProvider.currentPage + 1} / ${skedProvider.totalPages}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: skedProvider.currentPage < skedProvider.totalPages - 1
                    ? () => _handlePagination(skedProvider.currentPage + 1, skedProvider.pageSize)
                    : null,
              ),
              IconButton(
                icon: Icon(Icons.last_page),
                onPressed: skedProvider.currentPage < skedProvider.totalPages - 1
                    ? () => _handlePagination(skedProvider.totalPages - 1, skedProvider.pageSize)
                    : null,
              ),
              SizedBox(width: 16),
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
