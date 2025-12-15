// lib/models/task.dart

class Task {
  final int id;
  final int userId;
  final String title;
  final String description;
  final DateTime deadline;
  String status;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      title: json['title'] as String,
      description: json['description'] as String,
      deadline: DateTime.parse(json['deadline']),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
