import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/Employee.dart';
import '../../models/Sked.dart';
import 'transfer_act_builder.dart';
import 'transfer_reason.dart';

class TransferActService {
  /// Загружает шрифты, строит PDF и отдаёт байты.
  static Future<Uint8List> generatePdf({
    required List<Sked> skeds,
    required String departmentName,
    required Employee fromEmployee,
    required Employee toEmployee,
    required TransferReason reason,
    required List<Employee> allEmployees,
  }) async {
    final fontData =
        await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final fontBoldData =
        await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    final font = pw.Font.ttf(fontData);
    final fontBold = pw.Font.ttf(fontBoldData);

    return TransferActBuilder.build(
      skeds: skeds,
      departmentName: departmentName,
      fromEmployee: fromEmployee,
      toEmployee: toEmployee,
      transferReason: reason.label,
      font: font,
      fontBold: fontBold,
      allEmployees: allEmployees,
    );
  }

  /// Открывает системный диалог печати / предпросмотра.
  static Future<void> printAct({
    required List<Sked> skeds,
    required String departmentName,
    required Employee fromEmployee,
    required Employee toEmployee,
    required TransferReason reason,
    required List<Employee> allEmployees,
  }) async {
    final bytes = await generatePdf(
      skeds: skeds,
      departmentName: departmentName,
      fromEmployee: fromEmployee,
      toEmployee: toEmployee,
      reason: reason,
      allEmployees: allEmployees,
    );
    await Printing.layoutPdf(onLayout: (_) => bytes);
  }
}
