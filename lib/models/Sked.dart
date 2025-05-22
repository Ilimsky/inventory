import 'package:intl/intl.dart';

class Sked {
  final int id;
  final int departmentId;
  final int employeeId;

  final String assetCategory;
  DateTime dateReceived;
  final int skedNumber;
  final String itemName;
  final String serialNumber;
  final int count;
  String measure;
  final double price;
  String place;
  final String comments;

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
  });

  factory Sked.fromJson(Map<String, dynamic> json) {
    return Sked(
      id: json['id'],
      skedNumber: json['skedNumber'],
      departmentId: json['departmentId'],
      employeeId: json['employeeId'],
      assetCategory: json['assetCategory'],
      dateReceived: DateTime.parse(json['dateReceived']),
      itemName: json['itemName'],
      serialNumber: json['serialNumber'],
      count: json['count'],
      measure: json['measure'],
      price: json['price'].toDouble(),
      place: json['place'],
      comments: json['comments'],
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
    };
  }
}
