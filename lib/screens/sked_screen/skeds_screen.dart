import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_frontend/screens/sked_screen/qr_service/qr_generator.dart';
import 'package:inventory_frontend/screens/sked_screen/print_service/print_service.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../providers/department_provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/sked_provider.dart';
import '../../services/auth_service.dart';
import '../../models/Sked.dart';
import '../create_sked_screen/create_sked_screen.dart';
import '../sked_history_screen.dart';
import 'skeds_table_heading.dart';
import 'skeds_search.dart';

import '../transfer_rights/transfer_rights.dart';

class SkedsScreen extends StatefulWidget {
  @override
  _SkedsScreenState createState() => _SkedsScreenState();
}

class _SkedsScreenState extends State<SkedsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedDepartmentId;
  DateTime? _selectedDate;
  bool _wasPushedFromCreate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DepartmentProvider>(context, listen: false).fetchDepartments();
      Provider.of<SkedProvider>(context, listen: false).initialize();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null && modalRoute.isCurrent && _wasPushedFromCreate) {
      _wasPushedFromCreate = false;
      Future.microtask(() {
        final provider = Provider.of<SkedProvider>(context, listen: false);
        if (provider.currentDepartmentId != null) {
          provider.fetchSkedsByDepartmentPaged(departmentId: provider.currentDepartmentId!);
        } else {
          provider.fetchAllSkedsPaged();
        }
      });
    }
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
      provider.fetchAllSkedsPaged();
    } else {
      provider.fetchSkedsByDepartmentPaged(departmentId: departmentId);
    }
  }

  void _openHistoryScreen(int skedId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SkedHistoryScreen(skedId: skedId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final departmentProvider = Provider.of<DepartmentProvider>(context);
    final departments = departmentProvider.departments;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Инвентаризация'),
            SizedBox(width: 10),
            Consumer<AuthService>(
              builder: (context, authService, child) {
                String roleText = '';
                Color roleColor = Colors.grey;

                if (authService.isSuperAdmin) {
                  roleText = 'Суперадмин';
                  roleColor = Colors.red;
                } else if (authService.isAdmin) {
                  roleText = 'Админ';
                  roleColor = Colors.orange;
                }
                // else if (authService.isUser) {
                //   roleText = 'Пользователь';
                //   roleColor = Colors.blue;
                // }

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    border: Border.all(color: roleColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    roleText,
                    style: TextStyle(
                      fontSize: 12,
                      color: roleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        elevation: 2,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 200,
                  child: SearchSkedsField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                DropdownButton<int?>(
                  hint: Text('Филиал'),
                  value: _selectedDepartmentId,
                  onChanged: _onDepartmentSelected,
                  items: [
                    DropdownMenuItem(value: null, child: Text('Все филиалы')),
                    ...departments.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    _wasPushedFromCreate = true;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CreateSkedScreen()),
                    );
                  },
                  icon: Icon(Icons.add),
                  label: Text('Новая запись'),
                ),

                Consumer<AuthService>(
                  builder: (context, auth, _) {
                    if (!auth.isAdmin && !auth.isSuperAdmin) return const SizedBox.shrink();
                    return OutlinedButton.icon(
                      onPressed: () => showTransferRightsDialog(context),
                      icon: const Icon(Icons.swap_horiz_rounded),
                      label: const Text('Передача прав'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepOrange,
                        side: const BorderSide(color: Colors.deepOrange),
                      ),
                    );
                  },
                ),

                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      Provider.of<SkedProvider>(context, listen: false).selectedDate = picked;
                      setState(() => _selectedDate = picked);
                    }
                  },
                  icon: Icon(Icons.date_range),
                  label: Text(
                    _selectedDate == null
                        ? 'Дата проверки'
                        : DateFormat('dd.MM.yyyy').format(_selectedDate!),
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.print),
                    tooltip: 'Печать или сохранить',
                    onPressed: () async {
                      final provider = Provider.of<SkedProvider>(context, listen: false);
                      final departmentProvider = Provider.of<DepartmentProvider>(context, listen: false);
                      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
                      List<Sked> allSkeds;

                      if (employeeProvider.isLoading) {
                        debugPrint('Сотрудники ещё загружаются, подожди');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Подождите, сотрудники ещё загружаются...')),
                        );
                        return;
                      }

                      if (employeeProvider.employees.isEmpty) {
                        debugPrint('Сотрудники не загружены');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Сотрудники не загружены. Попробуйте позже.')),
                        );
                        return;
                      }

                      try {
                        allSkeds = await provider.fetchAllSkedsRaw(
                          departmentId: _selectedDepartmentId,
                        );
                        allSkeds.sort((a, b) => a.id.compareTo(b.id));

                        String? departmentName;
                        if (_selectedDepartmentId != null) {
                          departmentName = departmentProvider.departments
                              .firstWhere((d) => d.id == _selectedDepartmentId)
                              .name;
                        }

                        final font = await PdfGoogleFonts.robotoRegular();
                        final fontBold = await PdfGoogleFonts.robotoBold();

                        final selected = await showDialog<String>(
                          context: context,
                          builder: (context) => SimpleDialog(
                            title: Text('Выберите действие'),
                            children: [
                              SimpleDialogOption(
                                onPressed: () => Navigator.pop(context, 'print'),
                                child: Text('Печать'),
                              ),
                              SimpleDialogOption(
                                onPressed: () => Navigator.pop(context, 'save'),
                                child: Text('Сохранить как PDF'),
                              ),
                            ],
                          ),
                        );

                        if (selected == 'print') {
                          await PrintService.printPdf(
                            skeds: allSkeds,
                            departmentName: departmentName,
                            selectedDate: _selectedDate,
                            font: font,
                            fontBold: fontBold,
                            employees: employeeProvider.employees,
                          );
                        } else if (selected == 'save') {
                          await PrintService.savePdf(
                            skeds: allSkeds,
                            departmentName: departmentName,
                            selectedDate: _selectedDate,
                            font: font,
                            fontBold: fontBold,
                            employees: employeeProvider.employees,
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ошибка при загрузке данных: $e')),
                        );
                      }
                    }
                ),
                IconButton(
                  icon: Icon(Icons.qr_code),
                  tooltip: 'Генерировать PDF с QR-кодами',
                  onPressed: () async {
                    final provider = Provider.of<SkedProvider>(context, listen: false);
                    List<Sked> allSkeds;

                    try {
                      allSkeds = await provider.fetchAllSkedsRaw(
                        departmentId: provider.currentDepartmentId,
                      );
                      allSkeds.sort((a, b) => a.id.compareTo(b.id));
                      PdfGenerator.generateAndPrintPdf(allSkeds);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка при загрузке данных: $e')),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.history),
                  tooltip: 'Тест истории (откроет историю для первого SKED)',
                  onPressed: () async {
                    final provider = Provider.of<SkedProvider>(context, listen: false);
                    if (provider.skeds.isNotEmpty) {
                      _openHistoryScreen(provider.skeds.first.id);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Нет SKED для просмотра истории')),
                      );
                    }
                  },
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