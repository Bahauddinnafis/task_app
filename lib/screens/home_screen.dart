import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:task_app/controllers/task_controller.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/screens/setting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _titleController = TextEditingController();
  final _dateCreatedController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDateCreated;
  DateTime? _selectedDueDate;

  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    Provider.of<TaskController>(context, listen: false).fetchTasks();
  }

  void _searchTasks(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, DateTime? selectedDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(
        () {
          selectedDate = picked;
          controller.text = "${picked.toLocal()}"
              .split(' ')[0]; // Tampilkan tanggal dalam format yyyy-MM-dd
        },
      );
    }
  }

  void _addTaskSheet() {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add New Task',
                  style: GoogleFonts.bebasNeue(
                    textStyle: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Task Title'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: _dateCreatedController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Date Created'),
                  onTap: () => _selectDate(
                      context, _dateCreatedController, _selectedDateCreated),
                ),
                TextField(
                  controller: _dueDateController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Due Date'),
                  onTap: () => _selectDate(
                      context, _dueDateController, _selectedDueDate),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text;
                    final dateCreated = _dateCreatedController.text;
                    final dueDate = _dueDateController.text;
                    final description = _descriptionController.text;

                    if (title.isNotEmpty &&
                        dateCreated.isNotEmpty &&
                        dueDate.isNotEmpty &&
                        description.isNotEmpty) {
                      final userId =
                          Provider.of<TaskController>(context, listen: false)
                              .userId;
                      final newTodo = Todo(
                        userId: userId,
                        id: DateTime.now().millisecondsSinceEpoch,
                        title: title,
                        completed: false,
                        dateCreated: _selectedDateCreated ?? DateTime.now(),
                        dueDate: _selectedDueDate ?? DateTime.now(),
                        description: description,
                      );

                      Provider.of<TaskController>(context, listen: false)
                          .addTodo(newTodo);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add Task'),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'To-Do List',
            style: GoogleFonts.bebasNeue(
              textStyle: TextStyle(
                fontSize: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigasi ke SettingScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'List Of To-Do',
                  style: GoogleFonts.bebasNeue(
                    textStyle: TextStyle(
                      fontSize: 36,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.filter_list_alt,
                    color: Theme.of(context).colorScheme.primary,
                    size: 36,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: _searchTasks,
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<TaskController>(
              builder: (context, todoProvider, child) {
                // Filter fitur search
                final searchTodos = todoProvider.todos.where((todo) {
                  final title = todo.title?.toLowerCase() ?? '';
                  final description = todo.description?.toLowerCase() ?? '';

                  return title.contains(_searchQuery.toLowerCase()) ||
                      description.contains(_searchQuery.toLowerCase());
                }).toList();

                // Jika tidak ada tugas yang sesuai dengan pencarian, tampilkan pesan
                if (searchTodos.isEmpty) {
                  return Center(
                    child: Text(
                      'No tasks match your search.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: todoProvider.todos.length,
                  itemBuilder: (context, index) {
                    final todo = todoProvider.todos[index];

                    // Warna card sesuai dengan urutan
                    final color = index % 2 == 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: color,
                        child: ListTile(
                          title: Text(todo.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${todo.description}"),
                              Text(
                                "Date Created: ${todo.dateCreated?.toLocal().toString().split(' ')[0] ?? 'Unknown'}",
                              ),
                              Text(
                                "Due Date: ${todo.dueDate?.toLocal().toString().split(' ')[0] ?? 'Unknown'}",
                              ),
                            ],
                          ),
                          trailing: Checkbox(
                            value: todo.completed,
                            onChanged: (value) {
                              todoProvider.updateTodo(
                                Todo(
                                  userId: todo.userId,
                                  id: todo.id,
                                  title: todo.title,
                                  completed: value!,
                                  dateCreated: todo.dateCreated,
                                  dueDate: todo.dueDate,
                                ),
                              );
                            },
                          ),
                          onLongPress: () {
                            todoProvider.deleteTodo(todo.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Task deleted successfully'),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTaskSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
