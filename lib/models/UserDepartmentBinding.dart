import 'User.dart';
import 'Department.dart';

class UserDepartmentBinding {
  final int id;
  final int userId;
  final int departmentId;
  final User? user;
  final Department? department;

  UserDepartmentBinding({
    required this.id,
    required this.userId,
    required this.departmentId,
    this.user,
    this.department,
  });

  factory UserDepartmentBinding.fromJson(Map<String, dynamic> json) {
    print('Parsing UserDepartmentBinding: $json');

    // Правильно извлекаем userId и departmentId из вложенных объектов
    final userObj = json['user'];
    final departmentObj = json['department'];

    final userId = userObj != null && userObj is Map ? (userObj['id'] as int?) ?? 0 : 0;
    final departmentId = departmentObj != null && departmentObj is Map ? (departmentObj['id'] as int?) ?? 0 : 0;

    return UserDepartmentBinding(
      id: json['id'] ?? 0,
      userId: userId,
      departmentId: departmentId,
      user: userObj != null ? User.fromJson(userObj) : null,
      department: departmentObj != null ? Department.fromJson(departmentObj) : null,
    );
  }

  Map<String, dynamic> toJsonForSave() {
    return {
      'user_id': userId,
      'department_id': departmentId,
    };
  }

  // Добавьте метод toString для отладки
  @override
  String toString() {
    return 'UserDepartmentBinding{id: $id, userId: $userId, departmentId: $departmentId}';
  }
}