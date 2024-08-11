import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:task_app/controllers/task_controller.dart';
import 'package:task_app/models/task_model.dart';

class DetailScreen extends StatefulWidget {
  final Todo todo;

  const DetailScreen({super.key, required this.todo});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Controller untuk input teks
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Variable untuk menyimpan tanggal
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    // Inisialisasi nilai awal dari controller dan tanggal
    _titleController.text = widget.todo.title ?? '';
    _descriptionController.text = widget.todo.description ?? '';
    _selectedDueDate = widget.todo.dueDate;
  }

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail',
          style: GoogleFonts.bebasNeue(
            textStyle: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TextField untuk judul
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            // TextField untuk deskripsi
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 8),
            // TextField untuk due date
            TextField(
              readOnly: true,
              controller: TextEditingController(
                  text: _selectedDueDate != null
                      ? _selectedDueDate!.toLocal().toString().split(' ')[0]
                      : ''),
              decoration: InputDecoration(
                labelText: 'Due Date',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Tombol untuk menyimpan perubahan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Menyimpan perubahan dan kembali ke layar sebelumnya
                  widget.todo.title = _titleController.text;
                  widget.todo.description = _descriptionController.text;
                  widget.todo.dueDate = _selectedDueDate!;

                  Provider.of<TaskController>(context, listen: false)
                      .updateTodo(widget.todo);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Save Changes',
                  style: GoogleFonts.bebasNeue(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
