import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // ДОБАВЬТЕ ЭТОТ ИМПОРТ

import '../models/SkedHistory.dart';
import '../providers/sked_provider.dart';

class SkedHistoryScreen extends StatelessWidget {
  final int skedId;

  const SkedHistoryScreen({super.key, required this.skedId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('История SKED #$skedId'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Обновляем экран
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SkedHistoryScreen(skedId: skedId),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<SkedHistory>>(
        future: Provider.of<SkedProvider>(context, listen: false)
            .getSkedHistory(skedId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ошибка загрузки истории: ${snapshot.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SkedHistoryScreen(skedId: skedId),
                        ),
                      );
                    },
                    child: Text('Попробовать снова'),
                  ),
                ],
              ),
            );
          }

          final historyList = snapshot.data ?? [];

          if (historyList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('История не найдена', style: TextStyle(fontSize: 18)),
                  Text('По этому SKED еще не было операций',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final history = historyList[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: _getActionIcon(history.actionType),
                  title: Text(
                    _getActionTitle(history.actionType),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${DateFormat('dd.MM.yyyy HH:mm').format(history.actionDate)}'),
                      Text('Выполнил: ${history.performedBy}'),
                      if (history.reason.isNotEmpty)
                        Text('Причина: ${history.reason}'),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showHistoryDetails(context, history);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Icon _getActionIcon(String actionType) {
    switch (actionType) {
      case 'CREATE':
        return Icon(Icons.add, color: Colors.green);
      case 'UPDATE':
        return Icon(Icons.edit, color: Colors.blue);
      case 'TRANSFER':
        return Icon(Icons.move_to_inbox, color: Colors.orange);
      case 'WRITE_OFF':
        return Icon(Icons.delete, color: Colors.red);
      default:
        return Icon(Icons.history, color: Colors.grey);
    }
  }

  String _getActionTitle(String actionType) {
    switch (actionType) {
      case 'CREATE':
        return 'Создание';
      case 'UPDATE':
        return 'Изменение';
      case 'TRANSFER':
        return 'Перемещение';
      case 'WRITE_OFF':
        return 'Списание';
      default:
        return actionType;
    }
  }

  void _showHistoryDetails(BuildContext context, SkedHistory history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Детали операции'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Тип: ${_getActionTitle(history.actionType)}'),
              SizedBox(height: 8),
              Text(
                  'Дата: ${DateFormat('dd.MM.yyyy HH:mm').format(history.actionDate)}'),
              SizedBox(height: 8),
              Text('Пользователь: ${history.performedBy}'),
              SizedBox(height: 8),
              Text('Причина: ${history.reason}'),
              if (history.previousData != null) ...[
                SizedBox(height: 16),
                Text('До изменения:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(history.previousData.toString(),
                    style: TextStyle(fontSize: 12)),
              ],
              if (history.newData != null) ...[
                SizedBox(height: 16),
                Text('После изменения:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(history.newData.toString(),
                    style: TextStyle(fontSize: 12)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
