import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' show BarcodeWidget, Barcode;

import '../../models/Sked.dart';


class PdfGenerator {
  static Future<void> generateAndPrintPdf(List<Sked> skeds) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    const itemsPerRow = 4;

    final rows = <List<Sked>>[];
    for (var i = 0; i < skeds.length; i += itemsPerRow) {
      rows.add(skeds.sublist(
        i,
        i + itemsPerRow > skeds.length ? skeds.length : i + itemsPerRow,
      ));
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          pw.Text('QR-коды для инвентаризации',
              style: pw.TextStyle(font: fontBold, fontSize: 20)),
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
                  padding: const pw.EdgeInsets.only(right: 10, bottom: 15),
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Column(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text(sked.skedNumber,
                            style: pw.TextStyle(font: fontBold)),
                        pw.SizedBox(height: 5),
                        BarcodeWidget(
                          data: qrData,
                          barcode: Barcode.qrCode(),
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
          )),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
