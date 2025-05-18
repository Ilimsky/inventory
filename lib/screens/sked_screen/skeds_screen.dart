import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/DepartmentProvider.dart';
import '../../providers/SkedProvider.dart';
import 'skeds_table.dart';
import 'skeds_search.dart';

class SkedsScreen extends StatefulWidget {
  @override
  _SkedsScreenState createState() => _SkedsScreenState();
}

class _SkedsScreenState extends State<SkedsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedDepartmentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DepartmentProvider>(context, listen: false)
          .fetchDepartments();
      Provider.of<SkedProvider>(context, listen: false).fetchAllSkeds();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onDepartmentSelected(int? departmentId) {
    setState(() => _selectedDepartmentId = departmentId);
    final provider = Provider.of<SkedProvider>(context, listen: false);

    if (departmentId == null) {
      provider.fetchAllSkeds();
    } else {
      provider.fetchSkedsByDepartment(departmentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final departmentProvider = Provider.of<DepartmentProvider>(context);
    final departments = departmentProvider.departments;

    return Scaffold(
      appBar: AppBar(title: Text('Отчеты')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // 🔍 Поиск
                Expanded(
                  child: SearchSkedsField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                SizedBox(width: 10),
                // 🏢 Фильтр по филиалу
                DropdownButton<int?>(
                  hint: Text('Филиал'),
                  value: _selectedDepartmentId,
                  onChanged: _onDepartmentSelected,
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Все'),
                    ),
                    ...departments.map(
                      (d) => DropdownMenuItem(
                        value: d.id,
                        child: Text(d.name),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<SkedProvider>(
              builder: (context, skedProvider, child) {
                if (skedProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }
                return SkedsTable(searchQuery: _searchQuery);
              },
            ),
          ),
        ],
      ),
    );
  }
}
