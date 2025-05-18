class Sked {
  final int id;
  final int departmentId;
  final int jobId;
  final int employeeId;

  DateTime dateReceived;
  final int skedNumber;
  final String itemName;
  final String serialNumber;
  final int count;
  String measure;
  final double price;
  String place;
  final String comments;
  final String? approvalDate;
  final double? approvedAmount;

  Sked({
    required this.id,
    required this.skedNumber,
    required this.departmentId,
    required this.jobId,
    required this.employeeId,
    required this.dateReceived,
    required this.itemName,
    required this.serialNumber,
    required this.count,
    required this.measure,
    required this.price,
    required this.place,
    required this.comments,
    this.approvalDate,
    this.approvedAmount,
  });

  factory Sked.fromJson(Map<String, dynamic> json) {
    return Sked(
      id: json['id'],
      skedNumber: json['skedNumber'],
      departmentId: json['departmentId'],
      jobId: json['jobId'],
      employeeId: json['employeeId'],
      dateReceived: DateTime.parse(json['dateReceived']),
      itemName: json['itemName'],
      serialNumber: json['serialNumber'],
      count: json['count'],
      measure: json['measure'],
      price: json['price'],
      place: json['place'],
      comments: json['comments'],
      approvalDate: json['approvalDate'],
      approvedAmount: json['approvedAmount']?.toDouble(),
    );
  }
}
