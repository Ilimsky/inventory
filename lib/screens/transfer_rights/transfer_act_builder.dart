import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../models/Employee.dart';
import '../../../models/Sked.dart';
import '../sked_screen/print_service/number_to_words.dart';

/// Генерирует АКТ ПРИЁМА-ПЕРЕДАЧИ МЦ.
///
/// Обязательные поля:
///   - [departmentName] — филиал (структурное подразделение)
///   - дата: намеренно оставляется пустой строкой для ручного заполнения
class TransferActBuilder {
  static Future<Uint8List> build({
    required List<Sked> skeds,
    required String departmentName,
    required Employee fromEmployee,
    required Employee toEmployee,
    required String transferReason,
    required pw.Font font,
    required pw.Font fontBold,
    required List<Employee> allEmployees,
  }) async {
    final pdf = pw.Document();

    // ── стили ────────────────────────────────────────────────────────────
    final styleOrg = pw.TextStyle(font: fontBold, fontSize: 11);
    final styleSub = pw.TextStyle(font: font, fontSize: 8);
    final styleTitle = pw.TextStyle(font: fontBold, fontSize: 15);
    final styleSubtitle = pw.TextStyle(font: font, fontSize: 9);
    final styleTh = pw.TextStyle(font: fontBold, fontSize: 8);
    final styleTd = pw.TextStyle(font: font, fontSize: 7);
    final styleSum = pw.TextStyle(font: fontBold, fontSize: 10);
    final styleSig = pw.TextStyle(font: font, fontSize: 9);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        build: (ctx) => [
          _header(departmentName, styleOrg, styleSub),
          pw.SizedBox(height: 18),
          _title(styleTitle, styleSubtitle, transferReason),
          pw.SizedBox(height: 14),
          _parties(fromEmployee, toEmployee, styleOrg, styleSub),
          pw.SizedBox(height: 10),
          _table(skeds, allEmployees, styleTh, styleTd),
          pw.SizedBox(height: 10),
          _summary(skeds, styleSum),
          pw.SizedBox(height: 24),
          _signatures(fromEmployee, toEmployee, styleSig),
        ],
      ),
    );

    return pdf.save();
  }

  // ── шапка ──────────────────────────────────────────────────────────────

  static pw.Widget _header(
    String departmentName,
    pw.TextStyle bold,
    pw.TextStyle light,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        _headerCell('ОсДО «Рос Ломбард»', 'Организация', bold, light),
        _headerCell('ФРЛ: $departmentName', 'Структурное подразделение', bold, light),
        // Поле даты оставляем пустым — заполняется вручную
        _headerCell('«____» ____________ 20___ г.', 'Дата составления акта', bold, light),
      ],
    );
  }

  static pw.Widget _headerCell(
    String value,
    String label,
    pw.TextStyle bold,
    pw.TextStyle light,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          value,
          style: bold.copyWith(decoration: pw.TextDecoration.underline),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 2),
        pw.Text(label, style: light, textAlign: pw.TextAlign.center),
      ],
    );
  }

  // ── заголовок акта ────────────────────────────────────────────────────

  static pw.Widget _title(
    pw.TextStyle title,
    pw.TextStyle subtitle,
    String reason,
  ) {
    return pw.Column(
      children: [
        pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Text('АКТ ПРИЁМА-ПЕРЕДАЧИ', style: title),
        ),
        pw.SizedBox(height: 4),
        pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Text(
            'материальных ценностей ($reason)',
            style: subtitle,
          ),
        ),
      ],
    );
  }

  // ── стороны ───────────────────────────────────────────────────────────

  static pw.Widget _parties(
    Employee from,
    Employee to,
    pw.TextStyle bold,
    pw.TextStyle light,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('ПЕРЕДАЁТ:', style: bold),
                pw.SizedBox(height: 2),
                pw.Text(from.name, style: light),
              ],
            ),
          ),
          pw.Container(
            width: 0.5,
            height: 36,
            color: PdfColors.grey400,
            margin: const pw.EdgeInsets.symmetric(horizontal: 12),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('ПРИНИМАЕТ:', style: bold),
                pw.SizedBox(height: 2),
                pw.Text(to.name, style: light),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── таблица МЦ ────────────────────────────────────────────────────────

  static pw.Widget _table(
    List<Sked> skeds,
    List<Employee> employees,
    pw.TextStyle th,
    pw.TextStyle td,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(18),   // №
        1: const pw.FixedColumnWidth(38),   // Категория
        2: const pw.FixedColumnWidth(44),   // Инв. №
        3: const pw.FlexColumnWidth(2),     // Наименование
        4: const pw.FixedColumnWidth(52),   // Серийный
        5: const pw.FixedColumnWidth(28),   // Кол-во
        6: const pw.FixedColumnWidth(32),   // Ед. изм.
        7: const pw.FixedColumnWidth(50),   // Стоимость
        8: const pw.FlexColumnWidth(1),     // Место
        9: const pw.FixedColumnWidth(30),   // Наличие
      },
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        _tableHeader(th),
        ..._tableRows(skeds, employees, td),
      ],
    );
  }

  static pw.TableRow _tableHeader(pw.TextStyle s) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
      children: [
        _cell('№', s),
        _cell('Категория', s),
        _cell('Инв. №', s),
        _cell('Наименование', s),
        _cell('Серийный номер', s),
        _cell('Кол-во', s),
        _cell('Ед. изм.', s),
        _cell('Стоимость', s),
        _cell('Место нахождения', s),
        _cell('Наличие', s),
      ],
    );
  }

  static List<pw.TableRow> _tableRows(
    List<Sked> skeds,
    List<Employee> employees,
    pw.TextStyle s,
  ) {
    return skeds.asMap().entries.map((e) {
      final i = e.key + 1;
      final sk = e.value;
      final price = sk.price > 0
          ? NumberFormat('#,##0.00', 'ru').format(sk.price)
          : '—';
      return pw.TableRow(
        decoration: pw.BoxDecoration(
          color: i.isEven ? PdfColors.grey100 : PdfColors.white,
        ),
        children: [
          _cell('$i', s),
          _cell(sk.assetCategory, s),
          _cell(sk.skedNumber.isNotEmpty ? sk.skedNumber : '—', s),
          _cell(sk.itemName, s),
          _cell(sk.serialNumber.isNotEmpty ? sk.serialNumber : '—', s),
          _cell('${sk.count}', s),
          _cell(sk.measure, s),
          _cell(price, s),
          _cell(sk.place.isNotEmpty ? sk.place : '—', s),
          _cell(sk.available ? 'Да' : 'Нет', s),
        ],
      );
    }).toList();
  }

  static pw.Widget _cell(String text, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2),
      child: pw.Text(
        text,
        style: style,
        maxLines: 3,
        overflow: pw.TextOverflow.clip,
      ),
    );
  }

  // ── итог ──────────────────────────────────────────────────────────────

  static pw.Widget _summary(List<Sked> skeds, pw.TextStyle s) {
    final count = skeds.length;
    final totalValue = skeds.fold<double>(0, (sum, sk) => sum + sk.price * sk.count);
    final formatted = NumberFormat('#,##0.00', 'ru').format(totalValue);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Итого передано: $count '
          '(${NumberToWords.convert(count)}) '
          '${NumberToWords.getNounForm(count)}',
          style: s,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Общая стоимость: $formatted сом',
          style: s,
        ),
      ],
    );
  }

  // ── подписи ───────────────────────────────────────────────────────────

  static pw.Widget _signatures(
    Employee from,
    Employee to,
    pw.TextStyle s,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        _sigBlock('Передал', from.name, s),
        _sigBlock('Принял', to.name, s),
      ],
    );
  }

  static pw.Widget _sigBlock(String role, String name, pw.TextStyle s) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(role, style: s.copyWith(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(name, style: s),
        pw.SizedBox(height: 20),
        pw.Container(width: 200, child: pw.Divider(thickness: 0.8)),
        pw.Text('подпись / дата', style: s.copyWith(fontSize: 8)),
      ],
    );
  }
}
