import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../models/Employee.dart';
import '../../../models/Sked.dart';
import 'number_to_words.dart';

class PdfBuilder {
  static Future<Uint8List> buildPdf(List<Sked> skeds, {
    String? departmentName,
    DateTime? selectedDate,
    required pw.Font font,
    required pw.Font fontBold,
    required List<Employee> employees,
  }) async {
    // debugPrint('[PdfBuilder] Начало создания PDF');
    // debugPrint('[PdfBuilder] Получено сотрудников: ${employees.length}');
    // debugPrint('[PdfBuilder] Получено SKED-записей: ${skeds.length}');

    // Логирование первых 5 сотрудников
    if (employees.isNotEmpty) {
      // debugPrint('[PdfBuilder] Первые 5 сотрудников:');
      for (var i = 0; i < (employees.length > 5 ? 5 : employees.length); i++) {
        debugPrint('  ${employees[i].id}: ${employees[i].name}');
      }
    }
    final pdf = pw.Document();

    // Настройки шрифтов
    final headerFont = pw.TextStyle(
      font: fontBold,
      fontSize: 12,
    );

    final subheaderFont = pw.TextStyle(
      font: font,
      fontSize: 9,
    );

    final titleFont = pw.TextStyle(
      font: fontBold,
      fontSize: 16,
    );

    final tableHeaderFont = pw.TextStyle(
      font: fontBold,
      fontSize: 8,
    );

    final tableContentFont = pw.TextStyle(
      font: font,
      fontSize: 7,
    );

    final summaryFont = pw.TextStyle(
      font: fontBold,
      fontSize: 10,
    );

    final signatureFont = pw.TextStyle(
      font: font,
      fontSize: 9,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          _buildHeader(departmentName, selectedDate, headerFont, subheaderFont),
          pw.SizedBox(height: 20),
          _buildTitle(titleFont),
          pw.SizedBox(height: 10),
          _buildTable(skeds, tableHeaderFont, tableContentFont, employees),
          pw.SizedBox(height: 10),
          _buildSummary(skeds.length, summaryFont),
          pw.SizedBox(height: 20),
          _buildSignatures(signatureFont),
        ],
      ),
    );

    debugPrint('[PdfBuilder] PDF успешно сформирован');
    return pdf.save();
  }

  static List<pw.TableRow> _buildTableRows(
      List<Sked> skeds,
      pw.TextStyle style,
      List<Employee> employees,
      ) {
    debugPrint('[PdfBuilder] Начало формирования строк таблицы');
    return skeds.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final sked = entry.value;

      debugPrint('[PdfBuilder] Обработка SKED ID: ${sked.id}, employeeId: ${sked.employeeId}');

      // Находим сотрудника или возвращаем "Неизвестный сотрудник"
      final employee = employees.firstWhere(
            (e) {
          debugPrint('[PdfBuilder] Сравнение: employee.id=${e.id} vs sked.employeeId=${sked.employeeId}');
          return e.id == sked.employeeId;
        },
        orElse: () {
          debugPrint('[PdfBuilder] ⚠️ Сотрудник не найден! SKED ID: ${sked.id}, Employee ID: ${sked.employeeId}');
          debugPrint('[PdfBuilder] Доступные ID сотрудников: ${employees.map((e) => e.id).toList()}');
          return Employee(id: -1, name: 'Неизвестный сотрудник (ID: ${sked.employeeId})');
        },
      );

      debugPrint('[PdfBuilder] Найден сотрудник: ${employee.name}');
      return pw.TableRow(
        verticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          _buildTableContent('$index', style),
          _buildTableContent(sked.assetCategory, style),
          _buildTableContent(sked.skedNumber, style),
          _buildTableContent(sked.itemName, style, maxLines: 2),
          _buildTableContent(sked.serialNumber, style),
          _buildTableContent('${sked.count}', style),
          _buildTableContent(sked.measure, style),
          _buildTableContent('${sked.price.toStringAsFixed(2)}', style),
          _buildTableContent(sked.place, style, maxLines: 2),
          _buildTableContent(employee.name, style, maxLines: 2),
          _buildTableContent(sked.available ? 'Да' : '', style),
          _buildTableContent(sked.comments, style, maxLines: 2),
        ],
      );
    }).toList();
  }

  static pw.Widget _buildHeader(
      String? departmentName,
      DateTime? selectedDate,
      pw.TextStyle headerStyle,
      pw.TextStyle subheaderStyle,
      ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildHeaderColumn(
          'ОсДО "Рос Ломбард"',
          'Организация',
          headerStyle,
          subheaderStyle,
        ),
        _buildHeaderColumn(
          departmentName != null ? 'ФРЛ: $departmentName' : 'Филиал не выбран',
          'Структурное подразделение',
          headerStyle,
          subheaderStyle,
        ),
        _buildHeaderColumn(
          selectedDate != null
              ? DateFormat('dd.MM.yyyy').format(selectedDate)
              : 'Дата не выбрана',
          'Дата проверки',
          headerStyle,
          subheaderStyle,
        ),
      ],
    );
  }

  static pw.Widget _buildHeaderColumn(
      String title,
      String subtitle,
      pw.TextStyle headerStyle,
      pw.TextStyle subheaderStyle,
      ) {
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          title,
          style: headerStyle.copyWith(
            decoration: pw.TextDecoration.underline,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          subtitle,
          style: subheaderStyle,
        ),
      ],
    );
  }

  static pw.Widget _buildTitle(pw.TextStyle style) {
    return pw.Align(
      alignment: pw.Alignment.center,
      child: pw.Text('АКТ', style: style),
    );
  }

  static pw.Widget _buildTable(
      List<Sked> skeds,
      pw.TextStyle headerStyle,
      pw.TextStyle contentStyle,
      List<Employee> employees,
      ) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FixedColumnWidth(20),  // №
        1: pw.FixedColumnWidth(40),  // Категория
        2: pw.FixedColumnWidth(40),  // Инв. №
        3: pw.FlexColumnWidth(2),    // Наименование
        4: pw.FixedColumnWidth(50),  // Серийный номер
        5: pw.FixedColumnWidth(30),  // Кол-во
        6: pw.FixedColumnWidth(35),  // Ед. изм.
        7: pw.FixedColumnWidth(50),  // Стоимость
        8: pw.FlexColumnWidth(1),    // Место
        9: pw.FlexColumnWidth(1),    // Ответственный
        10: pw.FixedColumnWidth(35), // Наличие
        11: pw.FlexColumnWidth(1),   // Комментарии
      },
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        _buildTableHeader(headerStyle),
        ..._buildTableRows(skeds, contentStyle, employees),
      ],
    );
  }

  static pw.TableRow _buildTableHeader(pw.TextStyle style) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey300),
      verticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        _buildTableCell('№', style),
        _buildTableCell('Категория', style),
        _buildTableCell('Инв. №', style),
        _buildTableCell('Наименование', style),
        _buildTableCell('Серийный номер', style),
        _buildTableCell('Кол-во', style),
        _buildTableCell('Ед. изм.', style),
        _buildTableCell('Стоимость', style),
        _buildTableCell('Место', style),
        _buildTableCell('Ответственный', style),
        _buildTableCell('Наличие', style),
        _buildTableCell('Комментарии', style),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, pw.TextStyle style) {
    return pw.Padding(
      child: pw.Text(text, style: style),
      padding: const pw.EdgeInsets.all(2),
    );
  }



  static pw.Widget _buildTableContent(
      String text,
      pw.TextStyle style, {
        int? maxLines,
      }) {
    return pw.Padding(
      child: pw.Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: pw.TextOverflow.clip,
      ),
      padding: const pw.EdgeInsets.all(2),
    );
  }

  static pw.Widget _buildSummary(int count, pw.TextStyle style) {
    return pw.Text(
      'Всего по акту $count (${NumberToWords.convert(count)}) ${NumberToWords.getNounForm(count)}',
      style: style,
    );
  }


  // static pw.Widget _buildSignatures(pw.TextStyle style) {
  //   return pw.Column(
  //     children: [
  //       pw.Row(
  //         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //         children: [
  //           // _buildSignatureColumn('Председатель комиссии:', style),
  //           _buildSignatureColumn('_________________________:', style),
  //           // _buildSignatureColumn('Члены комиссии:', style),
  //           _buildSignatureColumn('_________________________:', style),
  //         ],
  //       ),
  //       pw.SizedBox(height: 20),
  //       pw.Row(
  //         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //         children: [
  //           _buildSignatureColumn('_______:', style),
  //           _buildSignatureColumn('_______:', style),
  //         ],
  //       ),
  //     ],
  //   );
  // }
  //
  // static pw.Widget _buildSignatureColumn(String title, pw.TextStyle style) {
  //   return pw.Column(
  //     crossAxisAlignment: pw.CrossAxisAlignment.start,
  //     children: [
  //       pw.Text(title),
  //       pw.Text('(должность)', style: style),
  //       pw.Text('(подпись)', style: style),
  //     ],
  //   );
  // }

  static pw.Widget buildSignatureLine({
    required String positionAndName,
    required pw.TextStyle style,
    double lineWidthPosition = 180,
    double lineWidthSignature = 150,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // Линия для должности и ФИО
            pw.Container(
              width: lineWidthPosition,
              child: pw.Divider(thickness: 1),
            ),
            // Линия для подписи
            pw.Container(
              width: lineWidthSignature,
              child: pw.Divider(thickness: 1),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // Должность и ФИО текстом под линией
            pw.Container(
              width: lineWidthPosition,
              child: pw.Text(positionAndName, style: style),
            ),
            // Подпись текстом под линией
            pw.Container(
              width: lineWidthSignature,
              alignment: pw.Alignment.centerRight,
              child: pw.Text('подпись', style: style),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSignatures(pw.TextStyle style) {
    return pw.Column(
      children: [
        buildSignatureLine(
          positionAndName: 'Должность, Ф.И.О.',
          style: style,
        ),
        pw.SizedBox(height: 30),
        buildSignatureLine(
          positionAndName: 'Должность, Ф.И.О.',
          style: style,
        ),
        pw.SizedBox(height: 30),
        buildSignatureLine(
          positionAndName: 'Должность, Ф.И.О.',
          style: style,
        ),
        pw.SizedBox(height: 30),
        buildSignatureLine(
          positionAndName: 'Должность, Ф.И.О.',
          style: style,
        ),
      ],
    );
  }

}