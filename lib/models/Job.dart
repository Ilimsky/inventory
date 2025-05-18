class Job {
  final int id;
  final String name;

  Job({required this.id, required this.name});

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? 0,  // Default value if null
      name: json['name'] ?? 'Не указано',  // Default value if null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}