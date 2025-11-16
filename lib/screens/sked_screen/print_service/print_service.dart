import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../models/Employee.dart';
import '../../../models/Sked.dart';
import 'pdf_builder.dart';
import 'pdf_printer.dart';
import 'pdf_saver.dart';

class PrintService {
  static Future<void> printPdf({
    required List<Sked> skeds,
    required String? departmentName,
    required DateTime? selectedDate,
    required pw.Font font,
    required pw.Font fontBold,
    required List<Employee> employees,
  }) async {
    await PdfPrinter.printPdf(
      skeds: skeds,
      departmentName: departmentName,
      selectedDate: selectedDate,
      font: font,
      fontBold: fontBold,
      employees: employees,
    );
  }

  static Future<void> savePdf({
    required List<Sked> skeds,
    required String? departmentName,
    required DateTime? selectedDate,
    required pw.Font font,
    required pw.Font fontBold,
    required List<Employee> employees,
  }) async {
    await PdfSaver.savePdf(
      skeds: skeds,
      departmentName: departmentName,
      selectedDate: selectedDate,
      font: font,
      fontBold: fontBold,
      employees: employees,
    );
  }
}