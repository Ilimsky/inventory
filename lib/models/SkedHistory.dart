import 'dart:convert';

class SkedHistory {
  final int id;
  final int? skedId; // Измените на nullable
  final String actionType;
  final DateTime actionDate;
  final String performedBy;
  final String reason;
  final Map<String, dynamic>? previousData;
  final Map<String, dynamic>? newData;

  SkedHistory({
    required this.id,
    this.skedId, // Теперь nullable
    required this.actionType,
    required this.actionDate,
    required this.performedBy,
    required this.reason,
    this.previousData,
    this.newData,
  });

  factory SkedHistory.fromJson(Map<String, dynamic> json) {
    return SkedHistory(
      id: json['id'],
      // Безопасное извлечение skedId из разных форматов
      skedId: _parseSkedId(json),
      actionType: json['actionType'],
      actionDate: DateTime.parse(json['actionDate']),
      performedBy: json['performedBy'],
      reason: json['reason'],
      previousData: _parseJsonData(json['previousData']),
      newData: _parseJsonData(json['newData']),
    );
  }

  // Вспомогательный метод для извлечения skedId
  static int? _parseSkedId(Map<String, dynamic> json) {
    // Пробуем разные варианты
    if (json['skedId'] != null) {
      return json['skedId'] as int;
    }
    if (json['sked'] != null && json['sked'] is Map) {
      return json['sked']['id'] as int?;
    }
    return null; // Если не нашли - возвращаем null
  }

  // Вспомогательный метод для парсинга JSON данных
  static Map<String, dynamic>? _parseJsonData(dynamic data) {
    if (data == null) return null;

    if (data is String) {
      // Если данные пришли как JSON строка - парсим
      try {
        return Map<String, dynamic>.from(json.decode(data));
      } catch (e) {
        print('Error parsing JSON data: $e');
        return null;
      }
    } else if (data is Map) {
      // Если данные уже в виде Map
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // Геттер для отображения типа действия
  String get actionTypeDisplay {
    switch (actionType) {
      case 'CREATE': return 'Создание';
      case 'UPDATE': return 'Изменение';
      case 'TRANSFER': return 'Перемещение';
      case 'WRITE_OFF': return 'Списание';
      default: return actionType;
    }
  }
}