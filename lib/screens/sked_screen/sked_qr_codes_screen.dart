import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/Sked.dart';

class SkedQrCodesScreen extends StatelessWidget {
  final List<Sked> skeds;

  const SkedQrCodesScreen({required this.skeds});

  Future<void> _generateAndPrintPdf(BuildContext context) async {
    final pdf = pw.Document();

    // Создаем таблицу для PDF
    final table = pw.Table(
      border: pw.TableBorder.all(),
      children: [
        // Заголовки таблицы
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('№', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Наименование', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Серийный номер', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('QR-код', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        // Данные таблицы
        ...skeds.map((sked) {
          final qrData = 'Sked ID: ${sked.id}, №: ${sked.skedNumber}, Item: ${sked.itemName}';
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Text(sked.skedNumber.toString()),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Text(sked.itemName),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Text(sked.serialNumber),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.BarcodeWidget(
                  data: qrData,
                  barcode: pw.Barcode.qrCode(),
                  width: 40,
                  height: 40,
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Header(text: 'QR-коды Sked'),
              pw.SizedBox(height: 20),
              table,
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR-коды Sked'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () => _generateAndPrintPdf(context),
            tooltip: 'Генерировать PDF',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: skeds.length,
        itemBuilder: (context, index) {
          final sked = skeds[index];
          final qrData = 'Sked ID: ${sked.id}, №: ${sked.skedNumber}, Item: ${sked.itemName}';

          return ListTile(
            title: Text(sked.itemName),
            subtitle: Text('Серийный номер: ${sked.serialNumber}'),
            trailing: QrImageView(
              data: qrData,
              size: 80,
            ),
          );
        },
      ),
    );
  }
}