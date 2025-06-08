import 'package:flutter/material.dart';
import 'package:inventory_frontend/models/sked.dart';

class SkedDetailScreen extends StatelessWidget {
  final Sked sked;

  const SkedDetailScreen({required this.sked});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Детали имущества')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Наименование: ${sked.itemName}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Инвентарный номер: ${sked.skedNumber}'),
            Text('Количество: ${sked.count} ${sked.measure}'),
            Text('Серийный номер: ${sked.serialNumber}'),
            Text('Цена: ${sked.price} руб.'),
            if (sked.comments.contains('Перемещено'))
              Text('Статус: Перемещено', style: TextStyle(color: Colors.red)),
            // Добавьте другие поля по необходимости
          ],
        ),
      ),
    );
  }
}