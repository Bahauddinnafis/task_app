class Todo {
  final int userId;
  final int id;
  final String title;
  final bool completed;
  final DateTime? dateCreated;
  final DateTime? dueDate;
  final String? description;

  Todo({
    required this.userId,
    required this.id,
    required this.title,
    required this.completed,
    this.dateCreated,
    this.dueDate,
    this.description,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      completed: json['completed'],
      dateCreated: json['dateCreated'] != null
          ? DateTime.parse(json['dateCreated'])
          : null,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      description: json['description']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'completed': completed,
      'dateCreated': dateCreated?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'description': description,
    };
  }
}
