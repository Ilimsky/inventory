import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../models/Department.dart';
import '../../providers/DepartmentProvider.dart';
import '../../providers/SkedProvider.dart';
import '../../models/Sked.dart';
import '../create_sked_screen.dart';
import '../reference_screen/reference_screen.dart';
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

  Future<void> _generateAndPrintPdf(List<Sked> skeds) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    // Constants for layout
    const itemsPerRow = 4;
    const maxRowsPerPage = 7; // Adjust based on your layout needs
    const itemsPerPage = itemsPerRow * maxRowsPerPage;

    // Track page number manually
    int pageNumber = 0;

    // Split skeds into chunks for each page
    for (var i = 0; i < skeds.length; i += itemsPerPage) {
      final pageSkeds = skeds.sublist(
        i,
        i + itemsPerPage > skeds.length ? skeds.length : i + itemsPerPage,
      );
      pageNumber++;

      // Split pageSkeds into rows of 4 items each
      final rows = <List<Sked>>[];
      for (var j = 0; j < pageSkeds.length; j += itemsPerRow) {
        rows.add(pageSkeds.sublist(
          j,
          j + itemsPerRow > pageSkeds.length ? pageSkeds.length : j + itemsPerRow,
        ));
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('QR-коды для инвентаризации',
                    style: pw.TextStyle(font: fontBold, fontSize: 20)),
                pw.Text('Страница $pageNumber',
                    style: pw.TextStyle(font: font, fontSize: 12)),
                pw.SizedBox(height: 10),
                ...rows.map((row) => pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: row.map((sked) {
                    final qrData = '''
Инвентарный номер: ${sked.skedNumber}
Наименование: ${sked.itemName}
Серийный номер: ${sked.serialNumber}
ID: ${sked.id}
''';
                    return pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(right: 10, bottom: 15),
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(),
                            borderRadius: pw.BorderRadius.circular(5),
                          ),
                          padding: pw.EdgeInsets.all(10),
                          child: pw.Column(
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Text(sked.skedNumber,
                                  style: pw.TextStyle(font: fontBold)),
                              pw.SizedBox(height: 5),
                              pw.BarcodeWidget(
                                data: qrData,
                                barcode: pw.Barcode.qrCode(),
                                width: 80,
                                height: 80,
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(sked.itemName,
                                  style: pw.TextStyle(font: font)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )).toList(),
              ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
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
                    DropdownMenuItem(value: null, child: Text('Все')),
                    ...departments.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.qr_code),
                  tooltip: 'Генерировать PDF с QR-кодами',
                  onPressed: () {
                    final skeds = Provider.of<SkedProvider>(context, listen: false).skeds;
                    _generateAndPrintPdf(skeds);
                  },
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
                  label: Text('Создать отчет'),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReferenceScreen()),
                  ),
                  icon: Icon(Icons.book),
                  label: Text('Справочник'),
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
                  tooltip: 'Печать отчета',
                  onPressed: () {
                    final skeds = Provider.of<SkedProvider>(context, listen: false).skeds;
                    _generateAndPrintPdf(skeds);
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

