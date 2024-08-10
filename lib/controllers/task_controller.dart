import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:task_app/models/task_model.dart';

class TaskController with ChangeNotifier {
  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  int _userId = 0;
  int get userId => _userId;

  void setUserId(int id) {
    _userId = id;
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    try {
      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/todos'));
      if (response.statusCode == 200) {
        final List<dynamic> todoJson = json.decode(response.body);
        _todos = todoJson.map(
          (json) {
            return Todo(
              userId: json['userId'],
              id: json['id'],
              title: json['title'],
              completed: json['completed'],
              dateCreated: DateTime.now(), // Dikarenakan pada endpoint API tidak memiliki "dateCreated" maka dijadikan nilai default.
              dueDate: DateTime.now().add(
                const Duration(days: 7),
              ), // Dikarenakan pada endpoint API tidak memiliki "dateCreated" maka dijadikan nilai default dan default untuk "dueDate" selama 7 hari.
              description: json['description']
            );
          },
        ).toList();
        notifyListeners();
        print("Data fetched successfully: ${_todos.length} items");
      } else {
        print('Failed to load todos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  void addTodo(Todo todo) {
    _todos.add(todo);
    notifyListeners();
  }

  void updateTodo(Todo todo) {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = todo;
      notifyListeners();
    }
  }

  void deleteTodo(int id) {
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }
}
