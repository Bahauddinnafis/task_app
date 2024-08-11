import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:task_app/controllers/task_controller.dart';
import 'package:task_app/models/task_model.dart';
import 'package:task_app/screens/detail_screen.dart';
import 'package:task_app/screens/setting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller untuk input teks
  final _titleController = TextEditingController();
  final _dateCreatedController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Variable untuk menyimpan tanggal yang dipilih
  DateTime? _selectedDateCreated;
  DateTime? _selectedDueDate;

  // Variable untuk fitur pencarian dan filter
  String _searchQuery = "";
  String _filter = "All";

  @override
  void initState() {
    super.initState();
    // Mengambil data tugas saat widget diinisialisasi
    Provider.of<TaskController>(context, listen: false).fetchTasks();
  }

  // Fungsi untuk fitur pencaran
  void _searchTasks(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  // Fungsi untuk mengatur filter
  void _setFilter(String filter) {
    setState(() {
      _filter = filter;
    });
  }

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, DateTime? selectedDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        if (controller == _dueDateController) {
          _selectedDueDate = picked;
        } else if (controller == _dateCreatedController) {
          _selectedDateCreated = picked;
        }
        controller.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  // Fungsi untuk menampilkan bottom sheet untuk menambah data baru
  void _addTaskSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Description',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _dateCreatedController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Date Created',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onTap: () => _selectDate(
                      context, _dateCreatedController, _selectedDateCreated),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _dueDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Due Date',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onTap: () => _selectDate(
                      context, _dueDateController, _selectedDueDate),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text;
                    final description = _descriptionController.text;

                    if (title.isNotEmpty && description.isNotEmpty) {
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

                      // Reset Value
                      _titleController.clear();
                      _descriptionController.clear();
                      _dateCreatedController.clear();
                      _dueDateController.clear();
                      _selectedDateCreated = null;
                      _selectedDueDate = null;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('ADD TASK'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Fungsi untuk konfirmasi penghapusan data
  Future<void> _confirmDeleteTask(BuildContext context, int taskId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      Provider.of<TaskController>(context, listen: false).deleteTodo(taskId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task deleted successfully'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Task App',
            style: GoogleFonts.bebasNeue(
              textStyle: TextStyle(
                fontSize: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'List Of Task',
                  style: GoogleFonts.bebasNeue(
                    textStyle: TextStyle(
                      fontSize: 36,
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text("All"),
                  selected: _filter == "All",
                  onSelected: (selected) {
                    _setFilter("All");
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('On Progress'),
                  selected: _filter == "On Progress",
                  onSelected: (selected) {
                    _setFilter("On Progress");
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Completed'),
                  selected: _filter == "Completed",
                  onSelected: (selected) {
                    _setFilter("Completed");
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TaskController>(
              builder: (context, todoProvider, child) {
                // Filter dan search
                final searchTodos = todoProvider.todos.where((todo) {
                  // Logika fitur filter dan search
                  final title = todo.title?.toLowerCase() ?? '';
                  final description = todo.description?.toLowerCase() ?? '';
                  final matchesSearch =
                      title.contains(_searchQuery.toLowerCase()) ||
                          description.contains(_searchQuery.toLowerCase());

                  switch (_filter) {
                    case "Completed":
                      return matchesSearch && todo.completed == true;
                    case "On Progress":
                      return matchesSearch && todo.completed == false;
                    default:
                      return matchesSearch;
                  }
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

                // Membuat list daftar task dari API
                return ListView.builder(
                  itemCount: searchTodos.length,
                  itemBuilder: (context, index) {
                    final todo = searchTodos[index];

                    // Warna container sesuai dengan urutan
                    final color = index % 2 == 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(todo: todo),
                              ));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      todo.title ?? '',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      todo.description ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Created: ${todo.dateCreated?.toLocal().toString().split(' ')[0]}',
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Due Date: ${todo.dueDate?.toLocal().toString().split(' ')[0]}',
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.white,
                                    onPressed: () {
                                      _confirmDeleteTask(context, todo.id ?? 0);
                                    },
                                  ),
                                  Checkbox(
                                    value: todo.completed,
                                    onChanged: (bool? value) {
                                      setState(
                                        () {
                                          todo.completed = value ?? false;
                                          Provider.of<TaskController>(context,
                                                  listen: false)
                                              .updateTodo(todo);
                                        },
                                      );
                                    },
                                    checkColor: Colors.white,
                                    fillColor: MaterialStateProperty.all(
                                      Theme.of(context).colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
