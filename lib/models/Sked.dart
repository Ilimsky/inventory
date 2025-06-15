import 'package:intl/intl.dart';

class Sked {
  final int id;
  final int departmentId;
  final int employeeId;
  final String assetCategory;
  DateTime dateReceived;
  final String skedNumber;
  final String itemName;
  final String serialNumber;
  final int count;
  String measure;
  final double price;
  String place;
  final String comments;
  bool isWrittenOff;

  bool available;

  Sked({
    required this.id,
    required this.skedNumber,
    required this.departmentId,
    required this.employeeId,
    required this.assetCategory,
    required this.dateReceived,
    required this.itemName,
    required this.serialNumber,
    required this.count,
    required this.measure,
    required this.price,
    required this.place,
    required this.comments,
    bool? isWrittenOff,
    required bool available,

  }) : isWrittenOff = isWrittenOff ?? false,
       available = available ?? false;

  factory Sked.fromJson(Map<String, dynamic> json) {
    return Sked(
      id: json['id'],
      skedNumber: json['skedNumber'] as String? ?? '',
      departmentId: json['departmentId'],
      employeeId: json['employeeId'],
      assetCategory: json['assetCategory'] as String? ?? '',
      dateReceived: DateTime.parse(json['dateReceived']),
      itemName: json['itemName'] as String? ?? '',
      serialNumber: json['serialNumber'] as String? ?? '',
      count: json['count'],
      measure: json['measure'] as String? ?? '',
      price: (json['price'] ?? 0).toDouble(),
      place: json['place'] as String? ?? '',
      comments: json['comments'] as String? ?? '',
      isWrittenOff: json['isWrittenOff'] as bool? ?? false,
      available: json['available'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skedNumber': skedNumber,
      'departmentId': departmentId,
      'employeeId': employeeId,

      'assetCategory': assetCategory,
      'dateReceived': DateFormat('yyyy-MM-dd').format(dateReceived),
      'itemName': itemName,
      'serialNumber': serialNumber,
      'count': count,
      'measure': measure,
      'price': price,
      'place': place,
      'comments': comments,
      'isWrittenOff': isWrittenOff,
      'available': available,

    };
  }


}
