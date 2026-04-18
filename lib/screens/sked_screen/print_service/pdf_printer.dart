import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../models/Employee.dart';
import '../../../models/Sked.dart';
import 'pdf_builder.dart';

class PdfPrinter {
  static Future<void> printPdf({
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
      await Printing.layoutPdf(onLayout: (format) => pdfBytes);
    } catch (e) {
      print('Ошибка при печати: $e');
      throw Exception('Не удалось выполнить печать');
    }
  }
}