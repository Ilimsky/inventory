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
  bool numberReleased;

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
    required bool numberReleased,
  })  : isWrittenOff = isWrittenOff ?? false,
        available = available ?? false,
        numberReleased = numberReleased ?? false;

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
      numberReleased: json['numberReleased'] as bool? ?? false,
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
      'numberReleased': numberReleased,
    };
  }

  Sked copyWith({
    int? id,
    int? departmentId,
    int? employeeId,
    String? assetCategory,
    DateTime? dateReceived,
    String? skedNumber,
    String? itemName,
    String? serialNumber,
    int? count,
    String? measure,
    double? price,
    String? place,
    String? comments,
    bool? isWrittenOff,
    bool? available,
    bool? numberReleased,
  }) {
    return Sked(
      id: id ?? this.id,
      skedNumber: skedNumber ?? this.skedNumber,
      departmentId: departmentId ?? this.departmentId,
      employeeId: employeeId ?? this.employeeId,
      assetCategory: assetCategory ?? this.assetCategory,
      dateReceived: dateReceived ?? this.dateReceived,
      itemName: itemName ?? this.itemName,
      serialNumber: serialNumber ?? this.serialNumber,
      count: count ?? this.count,
      measure: measure ?? this.measure,
      price: price ?? this.price,
      place: place ?? this.place,
      comments: comments ?? this.comments,
      isWrittenOff: isWrittenOff ?? this.isWrittenOff,
      available: available ?? this.available,
      numberReleased: numberReleased ?? this.numberReleased,
    );
  }
}
