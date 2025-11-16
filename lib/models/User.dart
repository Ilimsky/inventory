class User {
  final int id;
  final String username;
  final Set<String> roles;

  User({required this.id, required this.username, required this.roles});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      roles: Set.from(json['roles'].map((r) => r.toString())),
    );
  }
}