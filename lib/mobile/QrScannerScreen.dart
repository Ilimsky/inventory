import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../providers/sked_provider.dart';
import '../services/auth_service.dart';
import '../models/Sked.dart';
import 'MobileLoginScreen.dart';
import 'SkedDetailMobileScreen.dart';

// QrScannerScreen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'SkedDetailMobileScreen.dart';

class QrScannerScreen extends StatefulWidget {
  @override
  _QrScannerScreenState createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isLoading = false;
  String _lastScannedCode = '';

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && !_isLoading) {
      final String barcode = barcodes.first.rawValue ?? '';

      // Предотвращаем повторное сканирование того же кода
      if (barcode == _lastScannedCode) return;

      _lastScannedCode = barcode;
      _processScannedBarcode(barcode);
    }
  }

  Future<void> _processScannedBarcode(String barcode) async {
    setState(() => _isLoading = true);

    try {
      print('🔍 Сканирован QR-код: "$barcode"');

      final skedProvider = Provider.of<SkedProvider>(context, listen: false);
      final allSkeds = await skedProvider.fetchAllSkedsRaw();

      print('📋 Загружено ${allSkeds.length} записей SKED');

      // Выводим все skedNumber для отладки
      for (var sked in allSkeds.take(5)) { // Показываем первые 5
        print('SKED: ${sked.skedNumber} - ${sked.itemName}');
      }

      // Улучшенный поиск - пробуем разные варианты
      Sked? scannedSked = _findSkedByBarcode(allSkeds, barcode);

      if (scannedSked != null) {
        print('✅ Найден SKED: ${scannedSked.itemName} (${scannedSked.skedNumber})');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SkedDetailMobileScreen(sked: scannedSked!),
          ),
        );
      } else {
        print('❌ SKED не найден для кода: "$barcode"');
        _showErrorDialog(
            'SKED не найден',
            'QR-код "$barcode" не соответствует ни одной записи.\n\nПроверьте:\n1. Правильность QR-кода\n2. Наличие записи в системе'
        );
      }
    } catch (e) {
      print('❌ Ошибка обработки QR-кода: $e');
      _showErrorDialog('Ошибка', 'Не удалось загрузить данные: $e');
    } finally {
      setState(() => _isLoading = false);
      // Сбрасываем последний сканированный код через 3 секунды
      Future.delayed(Duration(seconds: 3), () {
        _lastScannedCode = '';
      });
    }
  }

  Sked? _findSkedByBarcode(List<Sked> skeds, String barcode) {
    // Очищаем код от возможных пробелов и лишних символов
    String cleanBarcode = barcode.trim();

    // Пробуем разные варианты поиска
    for (var sked in skeds) {
      // 1. Точное совпадение
      if (sked.skedNumber == cleanBarcode) {
        return sked;
      }

      // 2. Совпадение без учета регистра
      if (sked.skedNumber.toLowerCase() == cleanBarcode.toLowerCase()) {
        return sked;
      }

      // 3. Если в QR есть URL, извлекаем номер
      if (cleanBarcode.contains('/') && sked.skedNumber.isNotEmpty) {
        // Пробуем извлечь номер из URL
        var parts = cleanBarcode.split('/');
        for (var part in parts) {
          if (part.trim() == sked.skedNumber) {
            return sked;
          }
        }
      }

      // 4. Ищем частичное совпадение
      if (sked.skedNumber.contains(cleanBarcode) || cleanBarcode.contains(sked.skedNumber)) {
        return sked;
      }
    }

    return null;
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Метод для тестирования с известным QR-кодом
  // void _testWithKnownCode() {
  //   final testCode = 'TEST123'; // Замените на реальный тестовый код
  //   _processScannedBarcode(testCode);
  // }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Сканирование QR-кодов'),
        actions: [
          // Кнопка для тестирования (можно убрать после отладки)
          // IconButton(
          //   icon: Icon(Icons.bug_report),
          //   onPressed: _testWithKnownCode,
          //   tooltip: 'Тест с известным кодом',
          // ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MobileLoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onBarcodeDetected,
          ),

          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Обработка QR-кода...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // Overlay с инструкцией
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.black54,
              child: Column(
                children: [
                  Text(
                    'Наведите камеру на QR-код имущества',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Убедитесь, что код четко виден в рамке',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}