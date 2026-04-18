// Экран деталей SKED после сканирования
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/Sked.dart';
import '../providers/sked_provider.dart';
import '../services/auth_service.dart';
import 'MoveSkedScreen.dart';

class SkedDetailMobileScreen extends StatefulWidget {
  final Sked sked;

  const SkedDetailMobileScreen({required this.sked});

  @override
  _SkedDetailMobileScreenState createState() => _SkedDetailMobileScreenState();
}

class _SkedDetailMobileScreenState extends State<SkedDetailMobileScreen> {
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Подписываемся на обновления через существующий WebSocket
    final skedProvider = Provider.of<SkedProvider>(context, listen: false);
    skedProvider.wsService.listenToAvailability(widget.sked.id, (bool newAvailability) {
      if (mounted) {
        setState(() {
          widget.sked.available = newAvailability;
        });
      }
    });
  }

  Future<void> _toggleAvailability(bool newValue) async {
    if (_isUpdating) return;

    setState(() => _isUpdating = true);

    try {
      final skedProvider = Provider.of<SkedProvider>(context, listen: false);

      // Локальное обновление сразу
      setState(() {
        widget.sked.available = newValue;
      });

      // Обновляем через API (это также отправит WebSocket уведомление через updateSked)
      final updatedSked = await skedProvider.updateSked(
          widget.sked.copyWith(available: newValue)
      );

      // Обновляем данные виджета
      setState(() {
        widget.sked.available = updatedSked.available;
      });

    } catch (e) {
      // Откат при ошибке
      setState(() {
        widget.sked.available = !newValue;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка обновления статуса: $e')),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  void _showMoveDialog() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isAdmin && !authService.isSuperAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Доступ запрещен: только для администраторов')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoveSkedScreen(sked: widget.sked),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Детали имущества'),
        actions: [
          if (authService.isAdmin || authService.isSuperAdmin)
            IconButton(
              icon: Icon(Icons.move_to_inbox),
              onPressed: _showMoveDialog,
              tooltip: 'Переместить имущество',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Основная информация
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      widget.sked.available ? Icons.check_circle : Icons.cancel,
                      color: widget.sked.available ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.sked.available ? 'В наличии' : 'Отсутствует',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    if (_isUpdating)
                      CircularProgressIndicator()
                    else
                      Checkbox(
                        value: widget.sked.available,
                        onChanged: (bool? newValue) {
                          if (newValue != null) {
                            _toggleAvailability(newValue);
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Информация об имуществе
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Наименование: ${widget.sked.itemName}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Инвентарный номер: ${widget.sked.skedNumber ?? "Не назначен"}'),
                    Text('Категория: ${widget.sked.assetCategory}'),
                    Text('Количество: ${widget.sked.count} ${widget.sked.measure}'),
                    Text('Серийный номер: ${widget.sked.serialNumber}'),
                    Text('Местоположение: ${widget.sked.place}'),
                    if (widget.sked.comments.isNotEmpty)
                      Text('Комментарии: ${widget.sked.comments}'),
                  ],
                ),
              ),
            ),

            Spacer(),

            // Кнопка возврата к сканированию
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.qr_code_scanner),
                label: Text('Сканировать следующий QR-код'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}