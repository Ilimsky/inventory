import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;
import '../../../models/Employee.dart';
import '../../../models/Sked.dart';
import 'pdf_builder.dart';

class PdfSaver {
  static Future<void> savePdf({
    required List<Sked> skeds,
    required String? departmentName,
    required DateTime? selectedDate,
    required pw.Font font,
    required pw.Font fontBold,
    required List<Employee> employees,
  }) async {
    try {
      final pdfBytes = await PdfBuilder.buildPdf(
        skeds,
        departmentName: departmentName,
        selectedDate: selectedDate,
        font: font,
        fontBold: fontBold,
        employees: employees,
      );

      if (kIsWeb) {
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = 'Акт инвентаризации_${DateTime.now().toIso8601String()}.pdf';
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/Акт_инвентаризации_${DateTime.now().toIso8601String()}.pdf');
        await file.writeAsBytes(pdfBytes);
        print('PDF сохранен по пути: ${file.path}');
      }
    } catch (e) {
      print('Ошибка при сохранении PDF: $e');
      throw Exception('Не удалось сохранить PDF');
    }
  }
}