class Todo {
  int? userId;
  int? id;
  String? title;
  bool completed;
  DateTime dateCreated;
  DateTime dueDate;
  String? description;

  Todo({
    this.userId,
    this.id,
    this.title,
    this.completed = false,
    DateTime? dateCreated,
    DateTime? dueDate,
    this.description,
  })  : dateCreated = dateCreated ?? DateTime.now(),
        dueDate = dueDate ?? DateTime.now();

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
        userId: json['userId'],
        id: json['id'],
        title: json['title'],
        completed: json['completed'],
        dateCreated: json['dateCreated'] != null
            ? DateTime.parse(json['dateCreated'])
            : null,
        dueDate:
            json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        description: json['description']);
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
