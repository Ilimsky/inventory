import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:universal_html/html.dart' as html;

import '../../models/Sked.dart';

import 'package:pdf/widgets.dart' as pw;

import 'dart:io';

class PrintService {
  static Future<Uint8List> buildPdf(List<Sked> skeds) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          // Заголовок документа
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text('АКТ ИНВЕНТАРИЗАЦИИ',
                style: pw.TextStyle(font: fontBold, fontSize: 16)),
          ),
          pw.SizedBox(height: 10),

          // Основание для проведения инвентаризации
          pw.Row(
            children: [
              pw.Text('Основание для проведения инвентаризации: ',
                  style: pw.TextStyle(font: fontBold)),
              pw.Text('приказ, постановление, распоряжение',
                  style: pw.TextStyle(font: font, decoration: pw.TextDecoration.underline)),
            ],
          ),
          pw.SizedBox(height: 20),

          // Информация об организации
          pw.Row(
            children: [
              pw.Text('Организация: ', style: pw.TextStyle(font: fontBold)),
              pw.Text('ОсДО "Рос Ломбард"', style: pw.TextStyle(font: font)),
            ],
          ),
          pw.Row(
            children: [
              pw.Text('Структурное подразделение: ', style: pw.TextStyle(font: fontBold)),
              pw.Text('ломбард №20 г. Ош', style: pw.TextStyle(font: font)),
            ],
          ),
          pw.SizedBox(height: 10),

          // Номер документа и дата
          pw.Row(
            children: [
              pw.Text('Номер документа: ', style: pw.TextStyle(font: fontBold)),
              pw.Text('2', style: pw.TextStyle(font: font)),
              pw.SizedBox(width: 20),
              pw.Text('Дата составления: ', style: pw.TextStyle(font: fontBold)),
              pw.Text('2025-06-05', style: pw.TextStyle(font: font)),
            ],
          ),
          pw.SizedBox(height: 20),

          // Основная таблица с товарно-материальными ценностями
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FixedColumnWidth(30),  // Номер по порядку
              1: pw.FixedColumnWidth(60),  // Категория
              2: pw.FixedColumnWidth(60),  // Инв. номер
              3: pw.FlexColumnWidth(2),    // Наименование
              4: pw.FixedColumnWidth(60),  // Серийный номер
              5: pw.FixedColumnWidth(40),  // Количество
              6: pw.FixedColumnWidth(40),  // Единица измерения
              7: pw.FixedColumnWidth(60),  // Стоимость
              8: pw.FlexColumnWidth(1),    // Месторасположение
              9: pw.FlexColumnWidth(1),    // Ответственный
              10: pw.FixedColumnWidth(40), // Наличие
              11: pw.FlexColumnWidth(1),   // Комментарии
            },
            children: [
              // Заголовок таблицы
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Text('№', style: pw.TextStyle(font: fontBold)),
                  pw.Text('Категория', style: pw.TextStyle(font: fontBold)),
                  pw.Text('Инв. №', style: pw.TextStyle(font: fontBold)),
                  pw.Text('Наименование', style: pw.TextStyle(font: fontBold)),
                  pw.Text('Серийный номер', style: pw.TextStyle(font: fontBold)),
                  pw.Text('Кол-во', style: pw.TextStyle(font: fontBold)),
                  pw.Text('Ед. изм.', style: pw.TextStyle(font: fontBold)),
                  pw.Text('Стоимость', style: pw.TextStyle(font: fontBold)),
                  pw.Text('Место', style: pw.TextStyle(font: fontBold)),
                  pw.Text('Ответственный', style: pw.TextStyle(font: fontBold)),
                  pw.Text('Наличие', style: pw.TextStyle(font: fontBold)),
                  pw.Text('Комментарии', style: pw.TextStyle(font: fontBold)),
                ],
              ),
              // Данные из списка skeds
              ...skeds.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final sked = entry.value;
                return pw.TableRow(
                  children: [
                    pw.Text('$index', style: pw.TextStyle(font: font)),
                    pw.Text(sked.assetCategory, style: pw.TextStyle(font: font)),
                    pw.Text(sked.skedNumber, style: pw.TextStyle(font: font)),
                    pw.Text(sked.itemName, style: pw.TextStyle(font: font)),
                    pw.Text(sked.serialNumber, style: pw.TextStyle(font: font)),
                    pw.Text('${sked.count}', style: pw.TextStyle(font: font)),
                    pw.Text(sked.measure, style: pw.TextStyle(font: font)),
                    pw.Text('${sked.price.toStringAsFixed(2)}', style: pw.TextStyle(font: font)),
                    pw.Text(sked.place, style: pw.TextStyle(font: font)),
                    pw.Text('ID ${sked.employeeId}', style: pw.TextStyle(font: font)),
                    pw.Text(sked.available ? 'Да' : 'Нет', style: pw.TextStyle(font: font)),
                    pw.Text(sked.comments, style: pw.TextStyle(font: font)),
                  ],
                );
              }).toList(),

            ],
          ),
          pw.SizedBox(height: 10),

          // Итоговая информация
          pw.Text('Всего по акту ${skeds.length} (${_numberToWords(skeds.length)}) наименования.',
              style: pw.TextStyle(font: fontBold)),
          pw.SizedBox(height: 20),

          // Подписи
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Председатель комиссии:'),
                  pw.Text('(должность)', style: pw.TextStyle(font: font)),
                  pw.Text('(подпись)', style: pw.TextStyle(font: font)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Члены комиссии:'),
                  pw.Text('(должность)', style: pw.TextStyle(font: font)),
                  pw.Text('(подпись)', style: pw.TextStyle(font: font)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Сдал:'),
                  pw.Text('(должность)', style: pw.TextStyle(font: font)),
                  pw.Text('(подпись)', style: pw.TextStyle(font: font)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Принял:'),
                  pw.Text('(должность)', style: pw.TextStyle(font: font)),
                  pw.Text('(подпись)', style: pw.TextStyle(font: font)),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // Вспомогательная функция для преобразования числа в слова
  static String _numberToWords(int number) {
    // Упрощенная реализация - можно заменить на более полную
    final units = ['', 'один', 'два', 'три', 'четыре', 'пять', 'шесть', 'семь', 'восемь', 'девять'];
    final teens = ['десять', 'одиннадцать', 'двенадцать', 'тринадцать', 'четырнадцать', 'пятнадцать', 'шестнадцать', 'семнадцать', 'восемнадцать', 'девятнадцать'];
    final tens = ['', 'десять', 'двадцать', 'тридцать', 'сорок', 'пятьдесят', 'шестьдесят', 'семьдесят', 'восемьдесят', 'девяносто'];
    final hundreds = ['', 'сто', 'двести', 'триста', 'четыреста', 'пятьсот', 'шестьсот', 'семьсот', 'восемьсот', 'девятьсот'];

    if (number == 0) return 'ноль';

    String result = '';

    if (number >= 100) {
      result += hundreds[number ~/ 100] + ' ';
      number %= 100;
    }

    if (number >= 20) {
      result += tens[number ~/ 10] + ' ';
      number %= 10;
    } else if (number >= 10) {
      result += teens[number - 10] + ' ';
      number = 0;
    }

    if (number > 0) {
      result += units[number] + ' ';
    }

    return result.trim() + (number % 10 == 1 && number != 11 ? 'наименование' : 'наименований');
  }

  static Future<void> printPdf(List<Sked> skeds) async {
    try {
      final pdfBytes = await buildPdf(skeds);
      await Printing.layoutPdf(
        onLayout: (format) => pdfBytes,
      );
    } catch (e) {
      print('Ошибка при печати: $e');
      throw Exception('Не удалось выполнить печать');
    }
  }


  static Future<void> savePdf(List<Sked> skeds) async {
    try {
      final pdfBytes = await buildPdf(skeds);

      if (kIsWeb) {
        // Для веб-версии используем download
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = 'Отчет инвентаризации_${DateTime.now().toIso8601String()}.pdf';
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      } else {
        // Для мобильных/десктоп платформ используем path_provider
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/Отчет_инвентаризации_${DateTime.now().toIso8601String()}.pdf');
        await file.writeAsBytes(pdfBytes);
        print('PDF сохранен по пути: ${file.path}');
      }
    } catch (e) {
      print('Ошибка при сохранении PDF: $e');
      throw Exception('Не удалось сохранить PDF');
    }
  }
}
