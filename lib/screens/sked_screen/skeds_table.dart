import 'package:flutter/material.dart';
import 'package:inventory_frontend/models/Sked.dart';
import 'package:provider/provider.dart';

import '../../providers/SkedProvider.dart';
import '../../providers/DepartmentProvider.dart';
import '../../providers/JobProvider.dart';
import '../../providers/EmployeeProvider.dart';
import 'skeds_table_columns.dart';
import 'skeds_table_rows.dart';
import 'skeds_table_sort.dart';
import 'skeds_table_filter.dart';

class SkedsTable extends StatefulWidget {
  final String searchQuery;

  const SkedsTable({required this.searchQuery});

  @override
  _SkedsTableState createState() => _SkedsTableState();
}

class _SkedsTableState extends State<SkedsTable> {
  int _sortColumnIndex = 0;
  bool _isAscending = true;

  @override
  Widget build(BuildContext context) {
    final skedProvider = Provider.of<SkedProvider>(context);
    final departmentProvider = Provider.of<DepartmentProvider>(context);
    final jobProvider = Provider.of<JobProvider>(context);
    final employeeProvider = Provider.of<EmployeeProvider>(context);

    final filteredSkeds = filterSkeds(
      context: context,
      skeds: skedProvider.skeds,
      searchQuery: widget.searchQuery,
      departmentProvider: departmentProvider,
      jobProvider: jobProvider,
      employeeProvider: employeeProvider,
    );

    return SingleChildScrollView(
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
            onSort: (i, asc) => handleSort(
                i,
                asc,
                skedProvider,
                    (index, ascending) {
                  setState(() {
                    _sortColumnIndex = index;
                    _isAscending = ascending;
                  });
                }
            ),
            jobProvider: jobProvider,
            employeeProvider: employeeProvider,
          ),
          rows: buildTableRows(
            context: context,
            skeds: filteredSkeds,
            departmentProvider: departmentProvider,
            jobProvider: jobProvider,
            employeeProvider: employeeProvider,
          ),
        ),
      ),
    );
  }
}